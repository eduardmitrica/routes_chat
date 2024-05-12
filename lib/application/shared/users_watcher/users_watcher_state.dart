part of 'users_watcher_bloc.dart';

@freezed
class UsersWatcherState with _$UsersWatcherState {
  const factory UsersWatcherState.initial() = _Initial;

  const factory UsersWatcherState.loadInProgress() = _LoadInProgress;

  const factory UsersWatcherState.loadSuccess(
      KtList<User> friendRequests) = _LoadSuccess;

  const factory UsersWatcherState.loadFailure(
      UserFailure failure) = _LoadFailure;
}
