part of 'messages_watcher_bloc.dart';

@freezed
class MessagesWatcherEvent with _$MessagesWatcherEvent {
  const factory MessagesWatcherEvent.watchAllStartedForChatWithId(UniqueId chatId) =
  _WatchStarted;

  const factory MessagesWatcherEvent.messagesReceived(
      Either<MessageFailure, KtList<Message>>
      failureOrMessages) = _MessagesReceived;
}
