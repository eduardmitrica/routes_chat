part of 'pending_friend_requests_watcher_bloc.dart';

@freezed
class PendingFriendRequestsWatcherEvent
    with _$PendingFriendRequestsWatcherEvent {
  const factory PendingFriendRequestsWatcherEvent.watchAllStarted() =
      _WatchStarted;

  const factory PendingFriendRequestsWatcherEvent.friendRequestsReceived(
      Either<FriendRequestFailure, KtList<FriendRequest>>
          failureOrFriendRequests) = _FriendRequestsReceived;
}
