part of 'chats_watcher_bloc.dart';

sealed class ChatsWatcherEvent extends Equatable {
  const ChatsWatcherEvent();

  const factory ChatsWatcherEvent.watchAllStarted() = ChatsWatchAllStarted;

  const factory ChatsWatcherEvent.chatsReceived(
    Either<ChatFailure, KtList<Chat>> failureOrFriendRequests,
  ) = ChatsReceived;

  @override
  List<Object?> get props => const [];
}

final class ChatsWatchAllStarted extends ChatsWatcherEvent {
  const ChatsWatchAllStarted();
}

final class ChatsReceived extends ChatsWatcherEvent {
  final Either<ChatFailure, KtList<Chat>> failureOrFriendRequests;
  const ChatsReceived(this.failureOrFriendRequests);
  @override
  List<Object?> get props => [failureOrFriendRequests];
}
