part of 'pending_friend_requests_watcher_bloc.dart';

sealed class PendingFriendRequestsWatcherState extends Equatable {
  const PendingFriendRequestsWatcherState();

  const factory PendingFriendRequestsWatcherState.initial() =
      PendingFriendRequestsWatcherInitial;
  const factory PendingFriendRequestsWatcherState.loadInProgress() =
      PendingFriendRequestsWatcherLoadInProgress;
  const factory PendingFriendRequestsWatcherState.loadSuccess(
    KtList<FriendRequest> friendRequests,
  ) = PendingFriendRequestsWatcherLoadSuccess;
  const factory PendingFriendRequestsWatcherState.loadFailure(
    FriendRequestFailure failure,
  ) = PendingFriendRequestsWatcherLoadFailure;

  @override
  List<Object?> get props => const [];
}

final class PendingFriendRequestsWatcherInitial
    extends PendingFriendRequestsWatcherState {
  const PendingFriendRequestsWatcherInitial();
}

final class PendingFriendRequestsWatcherLoadInProgress
    extends PendingFriendRequestsWatcherState {
  const PendingFriendRequestsWatcherLoadInProgress();
}

final class PendingFriendRequestsWatcherLoadSuccess
    extends PendingFriendRequestsWatcherState {
  final KtList<FriendRequest> friendRequests;
  const PendingFriendRequestsWatcherLoadSuccess(this.friendRequests);
  @override
  List<Object?> get props => [friendRequests];
}

final class PendingFriendRequestsWatcherLoadFailure
    extends PendingFriendRequestsWatcherState {
  final FriendRequestFailure failure;
  const PendingFriendRequestsWatcherLoadFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}
