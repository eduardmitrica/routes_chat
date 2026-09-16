# End-to-end encryption

Message text and the chat list preview are encrypted on the device, so the
server (Firestore, Cloud Functions, FCM, and anyone with access to the project)
only ever stores ciphertext. Usernames, profiles and the friend graph stay
readable: search and the security rules depend on them.

## Secrets a user has

| Secret | Who knows it | Stored anywhere? |
|---|---|---|
| **Passphrase** | The user | Never. Only a key derived from it is used, and only on the device. |
| **Recovery key** | The user (shown once at setup) | Never. |
| **Master key** | The device, after unlocking | Only in the device's secure storage (Android Keystore, iOS Keychain), and only until sign-out. |

The login password is not involved. Email/password and Google users set the
same kind of passphrase, so a Firebase password reset never affects message
history.

## Key hierarchy

```
passphrase ──Argon2id(salt, params)──▶ passphrase KEK ─┐
                                                        ├─ wrap ─▶ master key (random, 32 bytes)
recovery key ──HKDF-SHA256─────────▶ recovery KEK ────┘                │
                                                                        └─ wrap ─▶ X25519 private key
X25519 public key ─────────────────────────────────── published for chat partners

chat key (random, 32 bytes, one per chat per key generation) ── sealed to each participant's public key
message text and any reply quote, last-message preview ──AES-256-GCM(chat key)──▶ ciphertext
```

- **Wrapping** uses AES-256-GCM with a random 96-bit nonce, so a wrong passphrase
  or recovery key fails authentication instead of producing garbage.
- **Argon2id** parameters (memory, iterations, parallelism) and the salt are
  stored with the wrapped keys, so they can be raised later without breaking
  existing users. The derivation runs in a background isolate.
- **The recovery key** is 160 random bits, shown as eight groups of four base32
  characters (for example `ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ23-4567`). It is
  already high-entropy, so a fast KDF (HKDF) is enough for it.
- **A chat key** is made by whoever sends the first message, and sealed to
  each participant (the sender included):
  1. A fresh ephemeral X25519 key pair agrees a shared secret with the
     participant's public key. An all-zero secret, which a low-order public
     key gives, is refused.
  2. HKDF-SHA256 turns it into a sealing key. The salt is 32 zero bytes (RFC
     5869's default, spelled out). The info is `routes_chat/v1/chat-key/kek`,
     then the ephemeral public key, then the participant's public key.
  3. AES-256-GCM encrypts the chat key under the sealing key. The associated
     data is `routes_chat/v1/chat-key`, the chat id, the key generation, the
     participant's id and the version of the participant's keys.
  The sender's own copy is sealed to their unlocked key pair rather than to
  the public key read from Firestore.
- **Key generations.** A chat's first key is generation 1. Each user's keys
  have a version: 1 at setup, one more after each reset. A user whose own
  sealed key in the current generation is for an older version of their keys
  has reset them, and cannot open it. Their app then adds the next generation,
  a new chat key sealed to both participants' current keys. Generations are
  only ever added, so earlier messages keep the key they were sent under.
- **Each message** is encrypted with AES-256-GCM under the chat key of the
  chat's current generation. What it encrypts is JSON as UTF-8: `{text}`,
  and for a reply also `replyTo: {id, senderId, text}`, the message it
  answers and the start of that message's text (at most 100 UTF-16 code
  units, never cut inside a character, then an ellipsis). Every message is
  written this way, so the server cannot tell a reply from any other
  message, and a quote still shows once the original cannot be read. The
  associated data is `routes_chat/v2/message`, the chat id, the key
  generation, the message id and the sender id, so ciphertext cannot be moved
  to another message, chat, generation or sender. The chat's last message is
  the same ciphertext as the message.
- **Photos and GIFs** are encrypted on the phone with AES-256-GCM, each with
  a random 32-byte key of its own. The associated data is
  `routes_chat/v2/file`, the chat id and the file id. The stored file is the
  12-byte nonce, the ciphertext and the 16-byte tag, at
  `chat_media/<chat id>/<file id>` in Storage. The message's payload lists
  each file under `attachments`: `{id, kind: "photo" | "gif", width, height,
  size, key, thumb?}`, where `thumb` is a JPEG about 40 pixels across. The keys
  and previews therefore travel inside the message's encryption, and Storage
  holds only files it cannot read. Photos are re-encoded on the phone as JPEG,
  at most 2048 pixels on the shorter side, which also drops metadata such as
  where they were taken; GIFs are sent as they are. A reply to a photo carries
  its preview as `replyTo.thumb`.
- **Edits** encrypt the whole payload again (the new text, the quote and the
  attachments) with a new nonce, under the key generation the message was sent
  with, and set `isEdited`. Only the sender can edit, for 15 minutes after
  sending.
- **Deleting a message** first deletes its photos from Storage, then removes
  its encrypted content, and with it the keys of those photos, then deletes
  the reactions to it. What stays is who sent it, when, and `deleted: true`,
  so replies to it still have something to point at. A reply carries its own
  copy of the quote inside its ciphertext, which the sender of the reply
  encrypted; the app shows "This message was deleted" in place of that quote
  once it has loaded the original.
- **Reactions** are one document per person per message, at
  `chats/<chat id>/reactions/<message id>_<user id>`. The emoji is encrypted
  with AES-256-GCM under the chat's current key generation, as JSON
  `{emoji, pad}` padded with spaces to 128 bytes, so every reaction is as long
  whatever the emoji. The associated data is `routes_chat/v1/reaction`, the
  chat id, the key generation, the message id and the reactor's id; the stored
  content has `v: 1`. The document also holds the message id, the reactor's id
  and when the message was sent, so a chat can watch the reactions to the
  messages it has loaded.
- **The emojis offered first when reacting** are the ones the user reacts with
  and sends most, counted on the phone only, in a file encrypted like drafts
  (below). The emoji picker's own list of recent emojis, which it would keep
  unencrypted, is off.
- **Unsent drafts and messages on their way** stay on the phone until they
  are sent, in the app's support directory under `local_chats/<uid>/`. Each
  file is encrypted with AES-256-GCM under a random 32-byte key kept in the
  phone's secure storage (Keychain, Keystore), with the file's name as the
  associated data, so a copy of the app's files reads nothing and one file
  cannot pass for another. A photo's file key is kept there before the photo
  is uploaded, so an upload repeated after a lost connection uses the key its
  message records. Signing out deletes these files and their key.
- **Version 1 messages**, sent before replies, encrypt the text alone (UTF-8,
  not JSON), with `routes_chat/v1/message` in place of
  `routes_chat/v2/message`. They still decrypt. Each version has its own
  associated data, so changing a message's version makes it fail to decrypt
  rather than read another way.
- **Associated data** is each of those strings as UTF-8, prefixed with its
  length in bytes as a 32-bit big-endian integer.
- **Groups** (up to 32 people) work like a one-to-one chat with more
  sealed keys: each generation of a group's key is sealed to every member and
  to everyone invited, and messages, the last message and replies are
  encrypted exactly as in a chat, with the group's id in the associated data.
  A group's id is `group-` and a random UUID, and groups are kept in
  `groups/{groupId}` so versions of the app from before groups never see
  them. Whoever starts a group is its only member and admin; everyone they
  add is invited, and joins only from their own phone: automatically when the
  person who added them is a friend, otherwise by tapping Join. The security
  rules cannot loop over a list, so they could not check that everyone added
  is a friend, and no one else's phone may put someone in a group. Invited
  people hold the key from the start, so joining needs nobody else online,
  but the rules let only members read messages.
- **When people join or leave a group**, its key is replaced: the first
  member's phone to see that the current generation is sealed to other
  people than are in the group adds the next one, sealed to exactly the
  members and the invited, and the rules refuse any message until it exists.
  Someone taken out, or who left, keeps the keys they had but gets no later
  one; someone who leaves never makes the next key themselves. Whoever adds
  someone chooses how much history they get: nothing before they were added,
  or everything the adder can read, in which case every earlier generation
  the adder can open is sealed to the newcomer and stored in
  `groups/{groupId}/sharedKeys/{uid}`, readable only by them and written in
  the same batch as the invitation. The last 24 hours or 7 days cannot be
  shared that way, since a key opens everything sent under it, so those are
  copied instead: the adder's phone makes a new history key, seals it to the
  newcomer as generation 0 (which no real generation is) in
  `groups/{groupId}/history/{uid}` with the time the window starts, then
  decrypts each message of the window it can read and encrypts its payload
  again under the history key into `history/{uid}/messages/{messageId}`,
  keeping the message's id, sender and time. The newcomer's app opens a copy
  wherever the original does not open for them. The rules check that each
  copy matches a real message from the window, but not what it says: the
  newcomer trusts whoever added them for the copied text. Each write invites one person and must
  record the writer as who invited them, since an invitation recorded as a
  friend's would make the newcomer's phone join by itself. All admins are
  equal; a group always keeps one, and when its only admin leaves, whoever
  has been a member longest becomes one.
- **A group's name and photo** are its `profile`, encrypted with the
  group's key: AES-256-GCM over JSON `{name, photo?}` (the photo a JPEG of at
  most 256 pixels a side, in base64), purpose `routes_chat/v1/group-profile`
  and associated data `[groupId, generation]`, stored as
  `{v: 1, e, nonce, cipherText, mac}`. Any member may set it, only under the
  group's current generation. When a member's app finds it under an older
  generation, it encrypts it again under the current one, so people who
  joined later can read it.
- **Group events** ("Ana added Radu") are message documents with no content:
  `{kind: 'event', type, senderId, subjectId?, on?, serverTimeStamp}`. They
  name who did what to whom, which the group document already shows in
  plaintext (members, admins, whether only admins add); they never hold the
  new name. Each is written in the same batch as its change, and the rules
  accept one only if that change really happens in that write, made by its
  sender. Versions of the app from before events leave these documents out.
- **The safety number** of two people is worked out from both public keys,
  so they can check that the keys they hold are each other's and not ones put
  in their place by the server. Each side's half is `SHA-512` of
  `0x00`, the version byte, their public key and their user id, hashed 5200
  times more with the key appended each time; the first 30 bytes of the result
  are read as six numbers of five digits. The two halves are joined, the
  smaller first, so both phones show the same 60 digits. The QR code carries
  `routes_chat/safety-number/v1/<60 digits>`, which the other phone compares
  with its own; nothing secret is in it. The user's own half uses the public
  key from the bundle on this device rather than the published copy, so a
  swapped published key shows up as a number the other side does not see.
  Whom the user verified is kept only on the phone, encrypted like drafts, so
  the server never learns it; when a number is no longer the one that was
  checked, the chat says so.
- **Opened chat keys** stay in memory for the session only. A message that does
  not decrypt is shown as "This message could not be decrypted." rather than
  hiding the chat.

## What is stored

| Where | Contents | Readable by |
|---|---|---|
| `users/{uid}/private/encryption` | KDF params and salt, the master key wrapped twice (by passphrase and by recovery key), the private key wrapped by the master key, the public key, the key version | The owner only |
| `userKeys/{uid}` | The public key and the key version | Any signed-in user |
| `chats/{chatId}` | Every generation of the chat key, sealed for each participant; the current generation; the encrypted last message | The chat's participants |
| `chats/{chatId}/messages/{id}` | The encrypted message, and whether it was edited; once deleted, only who sent it and when | The chat's participants |
| `chats/{chatId}/reactions/{messageId}_{uid}` | One person's encrypted reaction to a message, the ids, and when the message was sent | The chat's participants |
| Storage `chat_media/{chatId}/{fileId}` | An encrypted photo or GIF, and who uploaded it; only they can delete it, for a message they gave up sending | The chat's participants |

Stored formats (keys, nonces, ciphertext and tags as base64):
- a message's `content`: `{v: 2, e: <key generation>, nonce, cipherText, mac}`
  (`v: 1` for messages sent before replies),
  with a 12-byte nonce and a 16-byte tag;
- a chat's `keyGenerations`: generation number to `{createdBy, sealedKeys}`,
  where `sealedKeys` maps each participant's id to `{ephemeralPublicKey,
  nonce, cipherText, mac, keyVersion}`; and `currentKeyGeneration`.

Security rules reject a message or last message whose content is not in the
encrypted format, so an outdated or modified client cannot write plaintext.
They also:
- allow only the fields the app stores;
- require one sealed key per participant;
- allow a chat's key generations only to grow by one, made by the writer;
- accept messages only under the current generation;
- let only a message's sender edit it, within 20 minutes of sending, or
  delete it, which leaves only who sent it and when, for good;
- accept a reaction only as its reactor's own, encrypted at the fixed length,
  under the current generation, to a message that is not deleted;
- allow a key reset only as the next key version, with the bundle and the
  published key written together, within 5 minutes of signing in.

## Flows

- **First sign-in anywhere:** set up encryption. The user chooses a passphrase,
  the app creates the keys, shows the recovery key once, and asks the user to
  type part of it back before continuing.
- **Sign-in on a new device, or after signing out:** unlock with the passphrase.
- **Forgot the passphrase:** unlock with the recovery key, choose a new
  passphrase, and receive a new recovery key. The old one stops working.
- **Change the passphrase:** re-wraps the master key. It needs no re-encryption
  of any message.
- **Lost both:** reset encryption, from the recovery key screen.
  1. The app explains that earlier messages become unreadable for good, on
     every device.
  2. The user chooses a new passphrase.
  3. The user signs in again: the password for email accounts, Google again
     for Google accounts.
  4. The app creates keys with the next key version and shows the new
     recovery key.
  5. Each chat gets a new key generation as the user's chat list loads. The
     chat partner sees "… reset their encryption keys" in the chat.

  Partners never re-share old chat keys. Anyone who took over the account
  could reset the keys too, and would then receive the whole history. The
  user's earlier messages show as one line saying they cannot be read.
- **Sign-out:** removes the master key from the device.

## What this does not protect against

- A compromised or unlocked phone with the app installed.
- Metadata: who talks to whom, when, and how often. The server sees chat membership and timestamps.
- Message length. Ciphertext is as long as the text and any quote, so the server can estimate how long a message is. It also sees how many photos a message has, roughly how big each is, and who uploaded each (which the rules need to let only the uploader delete a file).
- Activity. While people share it, the server sees when someone types in a chat (`chats/{chatId}/typing/{uid}`), when their app is on screen (`presence/{uid}`), and which message they have read up to and when (`chats/{chatId}/reads/{uid}`), never what they type or read. Which chats are unread is kept only on the phone, encrypted like drafts. Push notifications carry the sender's name and the chat, never message text.
- Changes as events. The server sees when a message is edited or deleted, and
  when someone reacts to which message, never the new text or which emoji.
- Taking back what the other person already has. Deleting a message removes it
  from the server, but it may have been seen, copied, or kept in a phone's
  offline cache until that phone next connects.
- Reports. A report can share the last 5 messages of a chat in readable form, but only when its author ticks that, with a warning; they are stored in `reports`, which no app can read, for the project owner to review. The server cannot check them against the ciphertext, so they are the reporter's word.
- Who someone blocked, from the server. A block (`users/{uid}/blocks/{uid}`) is private to the blocker and hidden from the blocked person, but the server sees it. What a blocked person sends is still stored, encrypted, and the blocker's app keeps it out of sight.
- A malicious chat partner, who can read everything sent to them.
- In a group, someone invited who has not joined. They cannot read the
  messages, but they can read the group itself, which holds the encrypted last
  message and the key sealed to them, so a modified app could read that one
  message. The rules also check the shape of only the creator's own sealed key
  in a new group, since they cannot loop; a malformed key for someone else
  only locks that person out.
- Replacing a user's public key through the server, unless the two people
  compare their safety number. The app shows one per chat and warns when it
  changes for someone who was verified, but it cannot tell a key reset from a
  key that was swapped: only comparing can.
- A weak passphrase, which makes the wrapped copy in Firestore guessable
  offline. Argon2id slows guessing down but cannot fix a short passphrase.
