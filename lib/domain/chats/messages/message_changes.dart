import 'message.dart';

/// How long after sending a message its sender can still edit it.
///
/// firestore.rules accept an edit for a few minutes longer, so one started
/// just before the end, or on a phone whose clock runs a little behind, is
/// still saved.
const messageEditWindow = Duration(minutes: 15);

/// How long after sending a message firestore.rules still accept an edit of
/// it; a test checks they agree.
const messageEditSaveWindow = Duration(minutes: 20);

/// What shows in place of a deleted message, in the chat and the chat list.
const deletedMessageText = 'This message was deleted';

/// What the user with id [userId] can do with a message that arrived.
extension MessageChanges on Message {
  bool isFrom(String userId) => senderId.getOrCrash() == userId;

  /// Whether it arrived and can be read, so there is something to change.
  bool get _arrived => lastUpdatedAt != null && isReadable && !isDeleted;

  /// Their own message, within [messageEditWindow] of sending it. A voice
  /// message is sent as it was recorded.
  bool canBeEditedBy(String userId, DateTime now) =>
      isFrom(userId) &&
      _arrived &&
      !attachments.iter.any((attachment) => attachment.isVoice) &&
      now.difference(lastUpdatedAt!) < messageEditWindow;

  /// Their own message, for everyone in the chat, however old it is.
  bool canBeDeletedBy(String userId) => isFrom(userId) && _arrived;

  bool get canBeReactedTo => _arrived;
}
