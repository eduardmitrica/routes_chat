part of 'pending_friend_requests_watcher_bloc.dart';

sealed class PendingFriendRequestsWatcherEvent extends Equatable {
  const PendingFriendRequestsWatcherEvent();

  const factory PendingFriendRequestsWatcherEvent.watchAllStarted() =
      PendingFriendRequestsWatchAllStarted;

  const factory PendingFriendRequestsWatcherEvent.friendRequestsReceived(
    Either<FriendRequestFailure, KtList<FriendRequest>> failureOrFriendRequests,
  ) = PendingFriendRequestsReceived;

  @override
  List<Object?> get props => const [];
}

final class PendingFriendRequestsWatchAllStarted
    extends PendingFriendRequestsWatcherEvent {
  const PendingFriendRequestsWatchAllStarted();
}

final class PendingFriendRequestsReceived
    extends PendingFriendRequestsWatcherEvent {
  final Either<FriendRequestFailure, KtList<FriendRequest>>
  failureOrFriendRequests;
  const PendingFriendRequestsReceived(this.failureOrFriendRequests);
  @override
  List<Object?> get props => [failureOrFriendRequests];
}
