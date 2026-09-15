part of 'chats_watcher_bloc.dart';

sealed class ChatsWatcherEvent extends Equatable {
  const ChatsWatcherEvent();

  const factory ChatsWatcherEvent.watchAllStarted() = ChatsWatchAllStarted;

  const factory ChatsWatcherEvent.chatsReceived(
    Either<ChatFailure, KtList<Chat>> failureOrFriendRequests,
  ) = ChatsReceived;

  const factory ChatsWatcherEvent.readsChanged(ChatReads reads) =
      ChatsReadsChanged;

  @override
  List<Object?> get props => const [];
}

final class ChatsWatchAllStarted extends ChatsWatcherEvent {
  const ChatsWatchAllStarted();
}

/// How far the user has read changed.
final class ChatsReadsChanged extends ChatsWatcherEvent {
  final ChatReads reads;
  const ChatsReadsChanged(this.reads);
  @override
  List<Object?> get props => [reads];
}

final class ChatsReceived extends ChatsWatcherEvent {
  final Either<ChatFailure, KtList<Chat>> failureOrFriendRequests;
  const ChatsReceived(this.failureOrFriendRequests);
  @override
  List<Object?> get props => [failureOrFriendRequests];
}
