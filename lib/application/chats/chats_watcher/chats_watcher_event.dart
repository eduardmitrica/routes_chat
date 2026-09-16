part of 'chats_watcher_bloc.dart';

sealed class ChatsWatcherEvent extends Equatable {
  const ChatsWatcherEvent();

  const factory ChatsWatcherEvent.watchAllStarted() = ChatsWatchAllStarted;

  const factory ChatsWatcherEvent.chatsReceived(
    Either<ChatFailure, KtList<Chat>> failureOrFriendRequests,
  ) = ChatsReceived;

  const factory ChatsWatcherEvent.readsChanged(ChatReads reads) =
      ChatsReadsChanged;

  const factory ChatsWatcherEvent.blocksChanged() = ChatsBlocksChanged;

  const factory ChatsWatcherEvent.requestsChanged() = ChatsRequestsChanged;

  const factory ChatsWatcherEvent.friendsReceived(KtList<UniqueId> friendIds) =
      ChatsFriendsReceived;

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

/// The user blocked or unblocked someone.
final class ChatsBlocksChanged extends ChatsWatcherEvent {
  const ChatsBlocksChanged();
}

/// The user accepted or deleted a request, or changed who may reach them.
final class ChatsRequestsChanged extends ChatsWatcherEvent {
  const ChatsRequestsChanged();
}

/// Who the user is friends with, which decides whose messages are requests.
final class ChatsFriendsReceived extends ChatsWatcherEvent {
  final KtList<UniqueId> friendIds;
  const ChatsFriendsReceived(this.friendIds);
  @override
  List<Object?> get props => [friendIds];
}

final class ChatsReceived extends ChatsWatcherEvent {
  final Either<ChatFailure, KtList<Chat>> failureOrFriendRequests;
  const ChatsReceived(this.failureOrFriendRequests);
  @override
  List<Object?> get props => [failureOrFriendRequests];
}
