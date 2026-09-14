part of 'chat_bar_bloc.dart';

sealed class ChatBarEvent extends Equatable {
  const ChatBarEvent();

  const factory ChatBarEvent.messageContentChanged(String contentString) =
      MessageContentChanged;
  const factory ChatBarEvent.newChatCreated(
    KtList<UniqueId> otherThanCurrentParticipantIds,
  ) = NewChatCreated;
  const factory ChatBarEvent.newMessageAddedToChatWithId(
    String content,
    UniqueId chatId,
  ) = NewMessageAddedToChatWithId;
  const factory ChatBarEvent.replyStarted(Message message) = ReplyStarted;
  const factory ChatBarEvent.replyCancelled() = ReplyCancelled;
  const factory ChatBarEvent.mediaPicked(List<String> paths) = MediaPicked;
  const factory ChatBarEvent.mediaRemoved(UniqueId id) = MediaRemoved;

  @override
  List<Object?> get props => const [];
}

final class MessageContentChanged extends ChatBarEvent {
  final String contentString;
  const MessageContentChanged(this.contentString);
  @override
  List<Object?> get props => [contentString];
}

final class NewChatCreated extends ChatBarEvent {
  final KtList<UniqueId> otherThanCurrentParticipantIds;
  const NewChatCreated(this.otherThanCurrentParticipantIds);
  @override
  List<Object?> get props => [otherThanCurrentParticipantIds];
}

final class NewMessageAddedToChatWithId extends ChatBarEvent {
  final String content;
  final UniqueId chatId;
  const NewMessageAddedToChatWithId(this.content, this.chatId);
  @override
  List<Object?> get props => [content, chatId];
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
