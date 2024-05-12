part of 'friends_watcher_bloc.dart';

@freezed
class FriendsWatcherState with _$FriendsWatcherState {
  const factory FriendsWatcherState.initial() = _Initial;

  const factory FriendsWatcherState.loadInProgress() =
  _LoadInProgress;

  const factory FriendsWatcherState.loadSuccess(
      KtList<FriendRequest> friendRequests, KtList<UniqueId> friendsIds) = _LoadSuccess;

  const factory FriendsWatcherState.loadFailure(
      FriendRequestFailure failure) = _LoadFailure;
}
