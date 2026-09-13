part of 'received_friend_requests_watcher_bloc.dart';

sealed class ReceivedFriendRequestsWatcherState extends Equatable {
  const ReceivedFriendRequestsWatcherState();

  const factory ReceivedFriendRequestsWatcherState.initial() =
      ReceivedFriendRequestsWatcherInitial;
  const factory ReceivedFriendRequestsWatcherState.loadInProgress() =
      ReceivedFriendRequestsWatcherLoadInProgress;
  const factory ReceivedFriendRequestsWatcherState.loadSuccess(
    KtList<FriendRequest> friendRequests,
  ) = ReceivedFriendRequestsWatcherLoadSuccess;
  const factory ReceivedFriendRequestsWatcherState.loadFailure(
    FriendRequestFailure failure,
  ) = ReceivedFriendRequestsWatcherLoadFailure;

  @override
  List<Object?> get props => const [];
}

final class ReceivedFriendRequestsWatcherInitial
    extends ReceivedFriendRequestsWatcherState {
  const ReceivedFriendRequestsWatcherInitial();
}

final class ReceivedFriendRequestsWatcherLoadInProgress
    extends ReceivedFriendRequestsWatcherState {
  const ReceivedFriendRequestsWatcherLoadInProgress();
}

final class ReceivedFriendRequestsWatcherLoadSuccess
    extends ReceivedFriendRequestsWatcherState {
  final KtList<FriendRequest> friendRequests;
  const ReceivedFriendRequestsWatcherLoadSuccess(this.friendRequests);
  @override
  List<Object?> get props => [friendRequests];
}

final class ReceivedFriendRequestsWatcherLoadFailure
    extends ReceivedFriendRequestsWatcherState {
  final FriendRequestFailure failure;
  const ReceivedFriendRequestsWatcherLoadFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}
