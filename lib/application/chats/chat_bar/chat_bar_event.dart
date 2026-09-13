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
