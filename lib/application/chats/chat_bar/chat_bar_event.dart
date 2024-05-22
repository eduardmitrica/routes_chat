part of 'chat_bar_bloc.dart';

@freezed
class ChatBarEvent with _$ChatBarEvent {
  const factory ChatBarEvent.messageContentChanged(String contentString) = _MessageContentChanged;
  const factory ChatBarEvent.newChatCreated(KtList<UniqueId> otherThanCurrentParticipantIds) = _NewChatCreated;
  const factory ChatBarEvent.newMessageAddedToChatWithId(String content, UniqueId chatId) = _NewMessageAddedToChatWithId;
}
