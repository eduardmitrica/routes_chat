part of 'pending_friend_requests_watcher_bloc.dart';

@freezed
class PendingFriendRequestsWatcherState
    with _$PendingFriendRequestsWatcherState {
  const factory PendingFriendRequestsWatcherState.initial() = _Initial;

  const factory PendingFriendRequestsWatcherState.loadInProgress() =
      _LoadInProgress;

  const factory PendingFriendRequestsWatcherState.loadSuccess(
      KtList<FriendRequest> friendRequests) = _LoadSuccess;

  const factory PendingFriendRequestsWatcherState.loadFailure(
      FriendRequestFailure failure) = _LoadFailure;
}
