part of 'users_watcher_bloc.dart';

@freezed
class UsersWatcherEvent with _$UsersWatcherEvent {
  const factory UsersWatcherEvent.watchStarted(KtList<UniqueId> ids) =
  _WatchStarted;

  const factory UsersWatcherEvent.friendRequestsReceived(
      Either<UserFailure, KtList<User>>
      failureOrFriendRequests) = _FriendRequestsReceived;
}
