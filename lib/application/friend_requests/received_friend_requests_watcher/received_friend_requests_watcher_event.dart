part of 'received_friend_requests_watcher_bloc.dart';

@freezed
class ReceivedFriendRequestsWatcherEvent
    with _$ReceivedFriendRequestsWatcherEvent {
  const factory ReceivedFriendRequestsWatcherEvent.watchAllStarted() =
      _WatchStarted;

  const factory ReceivedFriendRequestsWatcherEvent.friendRequestsReceived(
      Either<FriendRequestFailure, KtList<FriendRequest>>
          failureOrFriendRequests) = _FriendRequestsReceived;
}
