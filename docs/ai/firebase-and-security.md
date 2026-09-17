# Firebase and security

## Configuration

- **Client settings** come from `.env` at compile time
  (`--dart-define-from-file=.env`), read through
  `lib/infrastructure/core/environment.dart`. `main()` stops with the missing
  keys if the flag was not passed.
  - `lib/firebase_options.dart` reads `Environment` and never holds literal
    values.
  - `.env.example` lists every key; a test keeps it equal to `Environment`.
- **Local and git-ignored, never force-added:** `.env`, `firebase.json`,
  `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`,
  `functions/.env`.
- `flutter analyze` and `flutter test` need no `.env`.
- `test/architecture/no_hardcoded_client_config_test.dart` fails on API keys,
  app ids, OAuth client ids or a database id written into `lib/`.

## Firestore is a named database

The project has no `(default)` database.
- Always build the instance with
  `FirebaseFirestore.instanceFor(app: …, databaseId: Environment.firestoreDatabaseId)`.
  `FirebaseFirestore.instance` points at a database that does not exist.
- CLI commands need `--database <id>`, and the local `firebase.json` names the
  database under `firestore`.

## Data model

| Path | Holds | Who can read |
|---|---|---|
| `users/{uid}` | `username`, `imageUrl`, `description`. No email address. | Any signed-in user (username search) |
| `users/{uid}/private/encryption` | The user's wrapped key bundle | The owner |
| `users/{uid}/fcmTokens/{token}` | `platform`, `updatedAt` | The owner |
| `presence/{uid}` | `state` (`online`/`offline`), `lastSeenAt` (server time) | The owner and their friends (accepted friend request); never listed |
| `chats/{pairId}/typing/{uid}` | `typingAt` (server time) | The two people; each writes only their own |
| `groups/{groupId}/typing/{uid}`, `groups/{groupId}/reads/{uid}` | The same fields as in a chat; a read marker's message is one of the group's | Members only; each writes only their own while a member, and deletes it any time |
| `chats/{pairId}/reads/{uid}` | `messageId`, `messageSentAt` (that message's send time, which the rules check), `readAt` (server time). Only while the user shares read receipts | The two people; each writes and deletes only their own |
| `groups/{groupId}` | `memberIds`, `invitedIds`, `invitedBy` (who added each invited person), `adminIds`, `onlyAdminsAdd`, `profile` (the name and photo, encrypted under the current generation; any member sets it), `keyGenerations` sealed to members and the invited, `currentKeyGeneration`, the encrypted `lastMessage`, `createdAt` (server time). The id is `group-` and a random UUID | Members and the invited; only the invited person moves themselves to members or leaves the invited |
| `groups/{groupId}/sharedKeys/{uid}` | `sharedBy`, `generations`: earlier generations of the group key sealed to someone added with the group's history, written with their invitation | Only that person |
| `groups/{groupId}/history/{uid}` | `sharedBy`, `since`, `key` (the history key sealed to that person as generation 0): the grant of a copied last day or week, written with the invitation | Only that person |
| `groups/{groupId}/history/{uid}/messages/{id}` | A message from the window encrypted again under the history key, with the original's id, `senderId` and `serverTimeStamp` | Only that person, once a member |
| `groups/{groupId}/messages/{id}` | The encrypted message, as in a chat, or an event (`kind: 'event'`, `type`, `senderId`, `subjectId` for events about someone, `on` for the only-admins switch), accepted only beside the change it describes. Its sender edits or deletes it as in a chat (`isMessageEdit` / `isMessageDeletion`, shared), and the group's `lastMessage` follows (`followsGroupLastMessage`); events never change | Members only |
| `groups/{groupId}/reactions/{messageId}_{uid}` | As in a chat, under the group's current generation, never to an event | Members only; each writes their own, the message's sender removes all when deleting |
| `users/{uid}/chatRequests/{chatId}` | `state` (`accepted` or `deleted`), `at` (server time). What the user did about a chat from someone who is not their friend; the sender is never told | The owner only (and the functions, with the Admin SDK) |
| `users/{uid}/settings/messaging` | `allowFromAnyone`. Whether people who are not friends may reach the user at all | The owner only (and the functions, with the Admin SDK) |
| `users/{uid}/blocks/{blockedUid}` | `blockedSince` (server time, while blocked), `earlier` (past blocks, at most 100). A block is silent: what a blocked person sends is stored as usual and hidden by the blocker's app; the notification functions skip it | The owner only (and the functions, with the Admin SDK) |
| `reports/{id}` | `reporterId`, `reportedId`, `chatId`, `reason` (literal), `messages` (at most 5, readable, only if the reporter ticked it), `createdAt` | Nobody from the app; the owner reviews them in the Firebase console |
| `userKeys/{uid}` | Public key, key version | Any signed-in user |
| `usernames/{name}` | `uid`: the uniqueness index | Anyone can get one; no listing |
| `friendRequests/{pairId}` | Sender, receiver, sorted `participantIds`, status | The two people |
| `chats/{pairId}` | Participants, sorted `participantIds`, key generations, current generation, encrypted last message | The two people |
| `chats/{pairId}/messages/{id}` | Sender, encrypted `content`, timestamps, `isEdited`. A deleted one keeps only `senderId`, `serverTimeStamp` and `deleted: true` | The two people; only the sender edits or deletes |
| `chats/{pairId}/reactions/{messageId}_{uid}` | `messageId`, `userId`, `messageSentAt` (the message's send time), encrypted `content` of a fixed length | The two people; each writes their own, and the message's sender also deletes them with the message |
| Storage `placeholders/…` | Shared placeholder avatar (public read, no client writes) | Anyone |
| Storage `user_images/{uid}.jpg` | Profile photo | Signed-in users; only the owner writes |
| Storage `group_media/{groupId}/{fileId}` | A group's photo or GIF, encrypted. Storage rules cannot read the named database, so membership is not checked: `get` only (no list) by the exact name, which must be a random v4 UUID; uploads pinned to their `uploader`, same size limit. `cleanUpDeletedGroup` deletes the folder with the group | Anyone signed in who has the name |
| Storage `chat_media/{chatId}/{fileId}` | A photo or GIF of a chat, encrypted (never readable by the server), never replaced; its `uploader` metadata lets only them delete it | The two people |

## Rules: principles the code depends on

1. **Field lists are exact.** Writes use `keys().hasOnly(<fields>())`. The
   lists must match the data transfer objects' JSON keys, which tests check
   (`chat_fields_match_rules_test.dart`, `profile_fields_test.dart`,
   `bundle_fields_match_rules_test.dart`). A new field needs the DTO, the rules
   and the test changed together. Removing a field an older app version still
   writes breaks that version, so such fields stay allowed and are marked as
   legacy.
2. **Rules are not filters.** A list query must be scoped the way the rules
   require (`participantIds arrayContains <uid>`). An unscoped query is denied
   even when every document would pass.
3. **A get rule must be decidable from the path.** Repositories
   `transaction.get` pair documents that may not exist yet, and a get rule that
   reads `resource` denies that read. Chats and friend requests check
   `uid in id.split('_')` instead.
   `test/architecture/firestore_rules_allow_reading_missing_docs_test.dart`
   guards this.
4. **Deterministic ids.** A chat or friend request between two people is one
   document, `compositeId`. The rules require sorted `participantIds` and
   `id == participantIds.join('_')`. Queries inside a transaction are not
   tracked for conflicts, which is why ids are deterministic.
5. **Same-write checks use `getAfter`,** for example a profile and its username
   claim, or a first message and its chat.
6. **Encrypted content only.** Messages and last messages must be encrypted
   content (`isEncryptedContent`, format versions 1 and 2, with size limits),
   under the chat's current key generation. Key generations only grow by one.
7. **Stored text is literal.** Status strings and similar values are written as
   literals, never derived from class names or `toString()`, which obfuscation
   changes.
8. **Indexes.** Queries that need a composite index are tied to
   `firestore.indexes.json` by `firestore_indexes_match_queries_test.dart`. A
   missing index only fails at runtime.
9. **Only the sender changes a message, in two ways.** An edit replaces
   `content`, under the key generation the message was sent with, within 20
   minutes of sending (the app offers 15; `messageEditSaveWindow`), counted
   from `serverTimeStamp`, which the create rule requires to be the time of the
   write, so a client cannot date a message ahead. A deletion
   leaves exactly `deletedFields()` and is final. The chat's `lastMessage`
   changes with it through `followsLastMessage()`, a `getAfter` of the
   message; it is the last branch of the chat update rule, so an ordinary send
   does not pay for that read. `chat_fields_match_rules_test.dart` ties the
   window, the kept fields and the reaction format to the app.

After deploying rules, wait about two minutes before probing them. When probing
over REST, use `:runQuery`; a plain list `GET` can be denied where the SDK's
query is allowed.

## Deploying

Deploys change production. Ask the project owner before running one.

```
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only storage          # not storage:rules
firebase deploy --only functions
```

Rules that still accept everything the released app writes can be deployed
before the app change is merged, and must be when the new app cannot work
without them. Make that backward compatibility explicit in the pull request.

## End-to-end encryption: invariants

The full design is [docs/e2ee.md](../e2ee.md). What every change must keep:

- **Plaintext stays on the device.** The server never receives message text, a
  reply quote, a search query or keys.
- **Message metadata goes inside the payload.** A message's ciphertext holds a
  JSON payload (format version 2): `{text, replyTo?, attachments?}`. New data
  from the sender goes there, as a new field (readers pass over fields they do
  not know) or in a new version. Data someone else adds, such as a reaction,
  goes in a document of its own, encrypted the same way under its own
  associated-data label (`routes_chat/v1/reaction`). Never a plaintext
  Firestore field.
- **One format for all messages.** Every new message uses the same format
  version, so the version does not reveal what kind of message it is.
- **Versions are bound.** Each format version has its own associated-data
  label (`routes_chat/v<version>/message`), so relabelling a message fails
  authentication. Readers keep decrypting older versions.
- **The format is shared.** A second, independent implementation (Node)
  produces the interop test vectors. A format change is a new version, never an
  edit.
- **Nothing sensitive in logs:** no keys, decrypted text, search queries or
  tokens. States and value objects that hold such data override `toString()`.
- **Push notifications** carry the sender's name and the chat id, never text.
- **Links:** only `http`, `https` and `mailto` links are made. Opening one
  asks first, warns about `http` and look-alike site names, and uses the
  browser's own in-app tab. No link previews are fetched.

## Cloud Functions

- `functions/index.js` has `notifyNewMessage`, a Firestore trigger on
  `chats/{chatId}/messages/{messageId}` in the named database. The database id
  is a parameter read from `functions/.env`.
- `notifyNewGroupMessage` (on `groups/{groupId}/messages/{messageId}`) tells
  the other members "New message in a group", skipping events and anyone who
  blocked the sender; `notifyGroupInvitation` (on writes to `groups/{groupId}`)
  tells each newly invited person who added them. Neither sends text or the
  encrypted group name. Data `{type: 'groupMessage' | 'groupInvitation',
  groupId}`, read by `appNotificationFrom`.
- `cleanUpDeletedGroup` (on deleting `groups/{groupId}`, which the last
  member's leaving does) deletes everything under the group with
  `recursiveDelete`: messages and events, reactions, `sharedKeys`, `history`
  and its copies, `typing`, `reads`, and the Storage folder
  `group_media/{groupId}/`. Nobody could read them without the group. The id
  must be a group's (`functions/cleanup.js`), and it retries on failure.
- `functions/notify.js` holds the pure helpers (recipients, payload, dead
  tokens), tested with `npm test` (`node --test`). CI runs them as the
  "functions test" job.
- Only tokens FCM reports as permanently invalid are deleted.
