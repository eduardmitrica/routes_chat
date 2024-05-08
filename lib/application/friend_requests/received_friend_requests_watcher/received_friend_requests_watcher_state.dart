part of 'received_friend_requests_watcher_bloc.dart';

@freezed
class ReceivedFriendRequestsWatcherState with _$ReceivedFriendRequestsWatcherState {
  const factory ReceivedFriendRequestsWatcherState.initial() = _Initial;

  const factory ReceivedFriendRequestsWatcherState.loadInProgress() = _LoadInProgress;

  const factory ReceivedFriendRequestsWatcherState.loadSuccess(
      KtList<FriendRequest> friendRequests) = _LoadSuccess;

  const factory ReceivedFriendRequestsWatcherState.loadFailure(
      FriendRequestFailure failure) = _LoadFailure;
}
