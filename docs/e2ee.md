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
- **Version 1 messages**, sent before replies, encrypt the text alone (UTF-8,
  not JSON), with `routes_chat/v1/message` in place of
  `routes_chat/v2/message`. They still decrypt. Each version has its own
  associated data, so changing a message's version makes it fail to decrypt
  rather than read another way.
- **Associated data** is each of those strings as UTF-8, prefixed with its
  length in bytes as a 32-bit big-endian integer.
- **Opened chat keys** stay in memory for the session only. A message that does
  not decrypt is shown as "This message could not be decrypted." rather than
  hiding the chat.

## What is stored

| Where | Contents | Readable by |
|---|---|---|
| `users/{uid}/private/encryption` | KDF params and salt, the master key wrapped twice (by passphrase and by recovery key), the private key wrapped by the master key, the public key, the key version | The owner only |
| `userKeys/{uid}` | The public key and the key version | Any signed-in user |
| `chats/{chatId}` | Every generation of the chat key, sealed for each participant; the current generation; the encrypted last message | The chat's participants |
| `chats/{chatId}/messages/{id}` | The encrypted message | The chat's participants |
| Storage `chat_media/{chatId}/{fileId}` | An encrypted photo or GIF | The chat's participants |

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
- Message length. Ciphertext is as long as the text and any quote, so the server can estimate how long a message is. It also sees how many photos a message has and roughly how big each is.
- A malicious chat partner, who can read everything sent to them.
- Replacing a user's public key through the server. A future improvement is
  showing a safety number that two people can compare.
- A weak passphrase, which makes the wrapped copy in Firestore guessable
  offline. Argon2id slows guessing down but cannot fix a short passphrase.
