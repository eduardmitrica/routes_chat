part of 'friends_watcher_bloc.dart';

sealed class FriendsWatcherEvent extends Equatable {
  const FriendsWatcherEvent();

  const factory FriendsWatcherEvent.watchAllStarted() = FriendsWatchAllStarted;

  const factory FriendsWatcherEvent.friendRequestsReceived(
    Either<FriendRequestFailure, KtList<FriendRequest>> failureOrFriendRequests,
  ) = FriendsFriendRequestsReceived;

  @override
  List<Object?> get props => const [];
}

final class FriendsWatchAllStarted extends FriendsWatcherEvent {
  const FriendsWatchAllStarted();
}

final class FriendsFriendRequestsReceived extends FriendsWatcherEvent {
  final Either<FriendRequestFailure, KtList<FriendRequest>>
  failureOrFriendRequests;
  const FriendsFriendRequestsReceived(this.failureOrFriendRequests);
  @override
  List<Object?> get props => [failureOrFriendRequests];
}
