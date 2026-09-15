# Features

Where each feature lives, from domain to screen, and the tests that cover it.
Paths are relative to `lib/` unless they start with `test/`.

## Sign-in and registration

- **Domain:** `domain/authentication/` (facade interface, sign-in and
  registration failures, `SignInMethod`), `domain/shared/user/` (`User`,
  value objects, username rules).
- **Application:** `application/authentication/` (`AuthenticationBloc`,
  `SignInFormBloc`, `RegisterFormBloc`).
- **Infrastructure:** `infrastructure/authentication/authentication_facade.dart`,
  `infrastructure/shared/user/` (profile repository, `UserUtils`,
  `CurrentUserSession`), `infrastructure/core/google_sign_in_initializer.dart`.
- **Presentation:** `presentation/sign_in/`, `presentation/register/`,
  `presentation/splash/`.
- **Rules:** a username is claimed in `usernames/{name}` in the same write as
  the profile. Registration checks that index while signed out, never `users`.
  Google sign-in gives a random username the user can change.

## End-to-end encryption

- **Spec:** [docs/e2ee.md](../e2ee.md).
- **Domain:** `domain/encryption/` (passphrase and recovery-key value objects,
  failures, repository interface).
- **Application:** `application/encryption/encryption_bloc.dart`. Its phases
  are set-up, show recovery key, unlock, recovery, new passphrase and key reset.
- **Infrastructure:** `infrastructure/encryption/` (`ChatCipher`,
  `ChatKeyring`, `UserKeyManager`, `KeyBundle`, `FirebaseEncryptionRepository`).
- **Presentation:** `presentation/encryption/encryption_gate_page.dart` and
  its widgets, shown between sign-in and home.
- **Tests:** `test/infrastructure/encryption/`, including
  `chat_cipher_interop_test.dart`. Its test vectors come from a separate Node
  implementation of the format; if it fails, stored messages would stop
  decrypting.

## Chats list

- `application/chats/chats_watcher/`, `infrastructure/chats/chat_repository.dart`,
  `infrastructure/chats/chat_data_transfer_object.dart`,
  `presentation/home/chats/` (list, friend search bar).
- A chat between two people has the id `compositeId([a, b])` (sorted uids
  joined by `_`). The chat document holds the key generations and the encrypted
  last message; the list decrypts it for the preview.

## Chat screen

The page is `presentation/home/chats/widgets/chat_page.dart`.

| Part | Code | Tests |
|---|---|---|
| Messages, 30 at a time, older pages on scroll | `MessagesWatcherBloc`, `MessageRepository.watchLatestForChatWithId` / `getPageBefore` | `test/application/chats/messages_watcher_bloc_test.dart` |
| Search in the chat, on the device, loading older pages | `MessagesWatcherBloc` (`searchChanged`), `domain/chats/messages/message_search.dart` | same, plus `test/domain/chats/message_search_test.dart` |
| Replies (quote inside the encrypted payload) | `MessageQuote`, `ChatBarBloc` (`replyStarted`), `message_payloads.dart`, `MessageBubble`, `SwipeToReply`, `MessageComposer` | `chat_bar_reply_test.dart`, `message_quote_test.dart`, `message_payloads_test.dart`, widget tests |
| Editing a message: the sender's own, for 15 minutes, marked "edited" | `message_changes.dart` (`messageEditWindow`, `canBeEditedBy`), `ChatBarBloc` (`editStarted`: the edit happens in the composer while the draft waits), `MessageRepository.editMessage` (encrypted again under the message's key generation, with the chat's last message), `MessageComposer` (edit strip), `MessageBubble` ("edited") | `chat_bar_edit_test.dart`, `message_changes_test.dart`, `edit_delete_react_widgets_test.dart` |
| Deleting a message for everyone, leaving a placeholder | `MessageActorBloc` (`deleteRequested`), `MessageRepository.deleteMessage` (photos first, then the message emptied to `deletedFields`, then its reactions), `MessageBubble` placeholder, `MessageQuote.following` (quotes of it say it was deleted) | `message_actor_bloc_test.dart`, `messages_watcher_changes_test.dart`, `message_data_transfer_object_test.dart` |
| Reactions: one per person, encrypted | `MessageReaction`, `MessageActorBloc` (`reactionPicked`: the same emoji takes it back), `MessageRepository.watchReactions` / `react` (`chats/{chatId}/reactions/{messageId}_{uid}`), `ChatCipher.encryptReaction`, `MessagesWatcherBloc` (watches from the oldest message loaded), `MessageReactions`, the reactions sheet in `chat_page.dart` | `message_actor_bloc_test.dart`, `messages_watcher_changes_test.dart`, `reaction_cipher_test.dart` |
| Quick reactions learned from the user, no fixed set | `emoji_usage.dart` (`emojisIn`, `EmojiUsage`: counts that halve every week), `EmojiPreferencesStore` (in `LocalVault`), `ChatBarBloc` (counts the emojis sent), `ReactionBar`, `emoji_picker_sheet.dart` (`emoji_picker_flutter`, its own recents off) | `emoji_usage_test.dart`, `edit_delete_react_widgets_test.dart` |
| Jump to the message a reply quotes | `MessagesWatcherEvent.messageRevealRequested`, `MessageReveal` | `messages_watcher_bloc_test.dart` |
| Links: detection, confirmation, opening | `domain/chats/messages/message_links.dart`, `LinkifiedText`, `open_link_dialog.dart`, `url_launcher` (in-app browser tab) | `message_links_test.dart`, `message_links_widget_test.dart`, `open_link_dialog_test.dart` |
| Photos and GIFs: choosing, encrypting, carousel, full screen | `message_attachment.dart` (limits), `IMediaRepository` / `MediaRepository` (prepare, load, memory cache), `AttachmentStore` (encrypt, Storage), `ChatBarBloc` (`mediaPicked`), `MessageComposer`, `AttachmentGallery`, `EncryptedImage`, `MediaViewerPage` | `chat_bar_media_test.dart`, `media_repository_test.dart`, `chat_cipher_file_test.dart`, `attachment_gallery_test.dart`, `message_composer_media_test.dart` |
| Saving a photo or GIF to the phone | `MediaRepository.saveToPhotos`, `PhotoLibrary` / `GalPhotoLibrary` (`gal`), the save button in `MediaViewerPage`, "Save photo" in the long-press menu | `media_repository_test.dart` (saving), `media_viewer_save_test.dart` |
| Messages on their way: kept on the phone, sent in order, retried | `MessageOutbox` (per-chat queue, growing pauses, retry now on reconnect and on resume), `OutgoingMessage`, `IOutboxRepository`, `OutgoingMessageBubble`, `NetworkMonitor`, `HomePage` (`resume`, `retryNow`) | `message_outbox_test.dart`, `outgoing_message_bubble_test.dart`, `chat_bar_draft_test.dart` |
| Files of a message given up, deleted from Storage | `MessageOutbox.discard`, `IMessageRepository.deleteAttachment`, `storage.rules` (uploader deletes) | `message_outbox_test.dart`, `storage_rules_match_media_limits_test.dart` |
| Typing indicator | `ChatBarBloc` (says typing at most every 3 s, stopped after a 5 s pause, on send, on leaving), `ChatActivityBloc` (shows it 6 s after each word, ignores marks older than 30 s), `IPresenceRepository` / `FirestorePresenceRepository` (`chats/{chatId}/typing/{uid}`), `_ChatTitle` in `chat_page.dart`, `activity_label.dart` | `chat_bar_typing_test.dart`, `chat_activity_bloc_test.dart`, `activity_label_test.dart`, `presence_rules_match_repository_test.dart` |
| Online / last seen | `PresenceReporter` (on screen: online every 45 s; off screen: offline; sharing off: deleted), `HomePage` lifecycle, `ChatActivityBloc` (online within 90 s), `presence/{uid}` (friends only), `AuthenticationBloc` (deleted on sign-out) | `presence_reporter_test.dart`, `chat_activity_bloc_test.dart`, `sign_out_order_test.dart`, `presence_rules_match_repository_test.dart` |
| Read receipts: "Seen" under the user's newest message | `ChatActivityBloc` (`messagesShown`: says how far the user read while sharing, only further; watches the other person's marker), `IPresenceRepository.markRead` / `watchReadUpTo` / `clearReads` (`chats/{chatId}/reads/{uid}`), `chat_page.dart` (reports on new messages and on resume, `_SeenLabel`), `PresenceReporter` (deletes markers when switched off) | `chat_activity_read_receipts_test.dart`, `presence_reporter_reads_test.dart`, `presence_rules_match_repository_test.dart` |
| Unread chats and times in the chat list | `ChatReads` / `IChatReads` (how far each chat was read, on the phone, whatever is shared), `ChatReadsStore` (in `LocalVault`), `ChatsWatcherBloc` (`unreadChatIds`), `ChatsList` (bold, dot, `chat_list_time.dart`) | `chat_reads_test.dart`, `chat_reads_store_test.dart`, `chats_watcher_unread_test.dart`, `chat_list_time_test.dart` |
| Privacy settings (typing, online, read receipts), both ways | `PrivacyBloc` (hydrated, implements `IPrivacySettingsReader`), `PrivacySwitches` in Profile | `privacy_bloc_test.dart` |
| Notifications: tap opens the chat or friend requests, banner while open, channels | `INotificationEvents` / `FirebaseNotificationEvents` (`appNotificationFrom`), `HomePage` (`_open`, `_showBanner`), `OpenChat`, `MainActivity.kt` channels, manifest default channel, `functions/notify.js` (`CHANNELS`, `notificationFor`, `friendRequestNotificationFor`), `functions/index.js` (`notifyNewMessage`, `notifyFriendRequest`) | `app_notification_from_test.dart`, `notification_channels_match_test.dart`, `functions/notify.test.js` |
| Drafts kept on the phone | `ChatBarBloc` (`started`, saving after a pause), `ChatDraft`, `IDraftRepository`, `LocalChatStore`, `LocalVault` (encrypted, wiped on sign-out) | `chat_bar_draft_test.dart`, `local_chat_store_test.dart`, `message_composer_media_test.dart` |
| Loading skeleton | `messages_skeleton.dart`, `presentation/core/widgets/skeleton.dart` | `test/presentation/core/messages_skeleton_test.dart` |
| Key reset and unreadable-message notices | `chat_timeline.dart` | `chat_timeline_test.dart`, `chat_timeline_partial_history_test.dart` |
| Sending | `ChatBarBloc` (`sent`), `MessageOutbox`, `MessageRepository.addMessageToChatWithId` / `ChatRepository.create` (a message sent twice lands once) | `chat_bar_reply_test.dart`, `chat_creation_ids_test.dart`, `message_outbox_test.dart` |

The long-press menu on a message starts with the user's favourite reactions
and a button for any emoji, then has Reply, Edit (their own message, for 15
minutes), Copy text, Save photo (or Save all), Copy link and Delete for
everyone (their own message, after asking). A deleted message has no menu and
cannot be replied to. On a message not sent yet the menu has Try again now,
Copy text and Delete message.

## Friends and friend requests

- `domain/friend_requests/`, `application/friend_requests/` (actor bloc plus
  pending and received watchers), `application/chats/friends_watcher/`,
  `infrastructure/friend_requests/`, `presentation/home/friend_requests/`,
  `presentation/home/search/`.
- A request between two people has the same pair id in either direction.
  Status strings (`Pending`, `Accepted`) are literal and pinned by the rules and
  a test.

## Profile and appearance

- `application/user/` (`UserFormBloc`, `UserWatcherBloc`),
  `presentation/home/profile/`.
- Appearance (Device, Light, Dark) is `application/settings/appearance/`
  (`AppearanceBloc`, hydrated), with `presentation/home/profile/widgets/appearance_picker.dart`.
  "Device" follows the phone's setting, including a night schedule.

## Theme

- `presentation/core/theme/app_theme.dart` builds light and dark themes from
  one brand color.
- `app_colors.dart` holds the colors the Material scheme lacks: bubbles, links,
  highlight, skeleton.
- Buttons: `FilledButton` is the main action, `OutlinedButton` an alternative,
  `TextButton` a way around. Destructive actions use
  `AppTheme.destructiveButton`.
- Guarded by `test/architecture/presentation_styles_come_from_theme_test.dart`
  and `test/presentation/core/app_theme_test.dart` (contrast and text sizes).

## Push notifications

- **Client:** `domain/notifications/`,
  `infrastructure/notifications/firebase_push_token_registry.dart`. Tokens are
  stored at `users/{uid}/fcmTokens/{token}`.
- **Server:** `functions/index.js` (`notifyNewMessage`, a trigger on new
  messages) and `functions/notify.js` (pure helpers, tested with
  `node --test`).
- A notification says who wrote and never what: message text must not pass
  through FCM.
