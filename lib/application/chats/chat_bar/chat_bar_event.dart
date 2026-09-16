part of 'chat_bar_bloc.dart';

sealed class ChatBarEvent extends Equatable {
  const ChatBarEvent();

  const factory ChatBarEvent.started(UniqueId otherUserId) = ChatBarStarted;

  /// Writing in the group [groupId]: no typing is shared and nothing is
  /// accepted or created, since the group exists already.
  const factory ChatBarEvent.startedInGroup(UniqueId groupId) =
      ChatBarStartedInGroup;
  const factory ChatBarEvent.messageContentChanged(String contentString) =
      MessageContentChanged;
  const factory ChatBarEvent.replyStarted(Message message) = ReplyStarted;
  const factory ChatBarEvent.replyCancelled() = ReplyCancelled;
  const factory ChatBarEvent.editStarted(Message message) = EditStarted;
  const factory ChatBarEvent.editCancelled() = EditCancelled;
  const factory ChatBarEvent.mediaPicked(List<String> paths) = MediaPicked;
  const factory ChatBarEvent.mediaRemoved(UniqueId id) = MediaRemoved;
  const factory ChatBarEvent.sent(String text, {required bool chatExists}) =
      MessageSent;
  const factory ChatBarEvent.outgoingChanged(KtList<OutgoingMessage> messages) =
      OutgoingChanged;
  const factory ChatBarEvent.retryRequested(UniqueId messageId) =
      OutgoingRetryRequested;
  const factory ChatBarEvent.discardRequested(UniqueId messageId) =
      OutgoingDiscardRequested;

  @override
  List<Object?> get props => const [];
}

/// The user opened the chat with [otherUserId]: its draft comes back.
final class ChatBarStartedInGroup extends ChatBarEvent {
  final UniqueId groupId;
  const ChatBarStartedInGroup(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

final class ChatBarStarted extends ChatBarEvent {
  final UniqueId otherUserId;
  const ChatBarStarted(this.otherUserId);
  @override
  List<Object?> get props => [otherUserId];
}

final class MessageContentChanged extends ChatBarEvent {
  final String contentString;
  const MessageContentChanged(this.contentString);
  @override
  List<Object?> get props => [contentString];
}

/// The user chose to reply to [message]: the next message sent answers it.
final class ReplyStarted extends ChatBarEvent {
  final Message message;
  const ReplyStarted(this.message);
  @override
  List<Object?> get props => [message];
}

/// The user no longer replies: the next message sent stands on its own.
final class ReplyCancelled extends ChatBarEvent {
  const ReplyCancelled();
}

/// The user chose to edit [message], which they sent: its text is theirs to
/// change, and sending saves it.
final class EditStarted extends ChatBarEvent {
  final Message message;
  const EditStarted(this.message);
  @override
  List<Object?> get props => [message];
}

/// The user stopped editing without saving: what they were writing before
/// comes back.
final class EditCancelled extends ChatBarEvent {
  const EditCancelled();
}

/// The user chose photos or GIFs at [paths] for the next message.
final class MediaPicked extends ChatBarEvent {
  final List<String> paths;
  const MediaPicked(this.paths);
  @override
  List<Object?> get props => [paths];
}

/// The user took the chosen photo or GIF [id] out of the next message.
final class MediaRemoved extends ChatBarEvent {
  final UniqueId id;
  const MediaRemoved(this.id);
  @override
  List<Object?> get props => [id];
}

/// The user sent [text], with the reply and photos chosen, to a chat that
/// exists already or that this message starts. While editing, [text] is the
/// edited message's new text.
final class MessageSent extends ChatBarEvent {
  final String text;
  final bool chatExists;
  const MessageSent(this.text, {required this.chatExists});
  @override
  List<Object?> get props => [text, chatExists];
}

/// The messages of the chat on their way changed.
final class OutgoingChanged extends ChatBarEvent {
  final KtList<OutgoingMessage> messages;
  const OutgoingChanged(this.messages);
  @override
  List<Object?> get props => [messages];
}

/// The user asked to try sending [messageId] again now.
final class OutgoingRetryRequested extends ChatBarEvent {
  final UniqueId messageId;
  const OutgoingRetryRequested(this.messageId);
  @override
  List<Object?> get props => [messageId];
}

/// The user gave up sending [messageId].
final class OutgoingDiscardRequested extends ChatBarEvent {
  final UniqueId messageId;
  const OutgoingDiscardRequested(this.messageId);
  @override
  List<Object?> get props => [messageId];
}
