part of 'messages_watcher_bloc.dart';

sealed class MessagesWatcherEvent extends Equatable {
  const MessagesWatcherEvent();

  const factory MessagesWatcherEvent.watchAllStartedForChatWithId(
    UniqueId chatId,
  ) = MessagesWatchAllStartedForChatWithId;

  const factory MessagesWatcherEvent.messagesReceived(
    Either<MessageFailure, KtList<Message>> failureOrMessages,
  ) = MessagesReceived;

  @override
  List<Object?> get props => const [];
}

final class MessagesWatchAllStartedForChatWithId extends MessagesWatcherEvent {
  final UniqueId chatId;
  const MessagesWatchAllStartedForChatWithId(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

final class MessagesReceived extends MessagesWatcherEvent {
  final Either<MessageFailure, KtList<Message>> failureOrMessages;
  const MessagesReceived(this.failureOrMessages);
  @override
  List<Object?> get props => [failureOrMessages];
}
