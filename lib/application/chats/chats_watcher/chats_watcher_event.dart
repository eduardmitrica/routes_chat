part of 'chats_watcher_bloc.dart';

@freezed
class ChatsWatcherEvent with _$ChatsWatcherEvent {
  const factory ChatsWatcherEvent.watchAllStarted() =
  _WatchStarted;

  const factory ChatsWatcherEvent.chatsReceived(
      Either<ChatFailure, KtList<Chat>>
      failureOrFriendRequests) = _ChatsReceived;
}
