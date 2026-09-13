part of 'received_friend_requests_watcher_bloc.dart';

sealed class ReceivedFriendRequestsWatcherEvent extends Equatable {
  const ReceivedFriendRequestsWatcherEvent();

  const factory ReceivedFriendRequestsWatcherEvent.watchAllStarted() =
      ReceivedFriendRequestsWatchAllStarted;

  const factory ReceivedFriendRequestsWatcherEvent.friendRequestsReceived(
    Either<FriendRequestFailure, KtList<FriendRequest>> failureOrFriendRequests,
  ) = ReceivedFriendRequestsReceived;

  @override
  List<Object?> get props => const [];
}

final class ReceivedFriendRequestsWatchAllStarted
    extends ReceivedFriendRequestsWatcherEvent {
  const ReceivedFriendRequestsWatchAllStarted();
}

final class ReceivedFriendRequestsReceived
    extends ReceivedFriendRequestsWatcherEvent {
  final Either<FriendRequestFailure, KtList<FriendRequest>>
  failureOrFriendRequests;
  const ReceivedFriendRequestsReceived(this.failureOrFriendRequests);
  @override
  List<Object?> get props => [failureOrFriendRequests];
}
