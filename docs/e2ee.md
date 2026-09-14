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

chat key (random, 32 bytes, one per chat) ── sealed to each participant's public key
message text and last-message preview ──AES-256-GCM(chat key)──▶ ciphertext
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
     data is `routes_chat/v1/chat-key`, the chat id and the participant's id.
  The sender's own copy is sealed to their unlocked key pair rather than to
  the public key read from Firestore.
- **Each message** is encrypted with AES-256-GCM under the chat key. The
  associated data is `routes_chat/v1/message`, the chat id, the message id and
  the sender id, so ciphertext cannot be moved to another message, chat or
  sender. The chat's last message is the same ciphertext as the message.
- **Associated data** is each of those strings as UTF-8, prefixed with its
  length in bytes as a 32-bit big-endian integer.
- **Opened chat keys** stay in memory for the session only. A message that does
  not decrypt is shown as "This message could not be decrypted." rather than
  hiding the chat.

## What is stored

| Where | Contents | Readable by |
|---|---|---|
| `users/{uid}/private/encryption` | KDF params and salt, the master key wrapped twice (by passphrase and by recovery key), the private key wrapped by the master key, the public key | The owner only |
| `userKeys/{uid}` | The public key | Any signed-in user |
| `chats/{chatId}` | The chat key sealed for each participant, and the encrypted last message | The chat's participants |
| `chats/{chatId}/messages/{id}` | The encrypted message | The chat's participants |

Stored formats, every value base64:
- a message's `content`: `{v: 1, nonce, cipherText, mac}`, a 12-byte nonce and
  a 16-byte tag;
- a chat's `chatKeys`: participant id to `{ephemeralPublicKey, nonce,
  cipherText, mac}`.

Security rules reject a message or last message whose content is not in the
encrypted format, so an outdated or modified client cannot write plaintext.
They also allow only the fields the app stores, keep `chatKeys` unchanged once
the chat exists, and require one sealed key per participant.

## Flows

- **First sign-in anywhere:** set up encryption. The user chooses a passphrase,
  the app creates the keys, shows the recovery key once, and asks the user to
  type part of it back before continuing.
- **Sign-in on a new device, or after signing out:** unlock with the passphrase.
- **Forgot the passphrase:** unlock with the recovery key, choose a new
  passphrase, and receive a new recovery key. The old one stops working.
- **Change the passphrase:** re-wraps the master key. It needs no re-encryption
  of any message.
- **Lost both:** reset encryption. This creates new keys; earlier messages stay
  unreadable, and existing chats need their keys re-shared.
- **Sign-out:** removes the master key from the device.

## What this does not protect against

- A compromised or unlocked phone with the app installed.
- Metadata: who talks to whom, when, and how often. The server sees chat
  membership and timestamps.
- A malicious chat partner, who can read everything sent to them.
- Replacing a user's public key through the server. A future improvement is
  showing a safety number that two people can compare.
- A weak passphrase, which makes the wrapped copy in Firestore guessable
  offline. Argon2id slows guessing down but cannot fix a short passphrase.
