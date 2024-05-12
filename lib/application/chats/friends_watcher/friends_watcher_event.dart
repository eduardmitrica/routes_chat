part of 'friends_watcher_bloc.dart';

@freezed
class FriendsWatcherEvent with _$FriendsWatcherEvent {
  const factory FriendsWatcherEvent.watchAllStarted() =
  _WatchStarted;

  const factory FriendsWatcherEvent.friendRequestsReceived(
      Either<FriendRequestFailure, KtList<FriendRequest>>
      failureOrFriendRequests) = _FriendRequestsReceived;
}
