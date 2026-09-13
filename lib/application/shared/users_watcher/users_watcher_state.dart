part of 'users_watcher_bloc.dart';

sealed class UsersWatcherState extends Equatable {
  const UsersWatcherState();

  const factory UsersWatcherState.initial() = UsersWatcherInitial;
  const factory UsersWatcherState.loadInProgress() = UsersWatcherLoadInProgress;
  const factory UsersWatcherState.loadSuccess(KtList<User> users) =
      UsersWatcherLoadSuccess;
  const factory UsersWatcherState.loadFailure(UserFailure failure) =
      UsersWatcherLoadFailure;

  @override
  List<Object?> get props => const [];
}

final class UsersWatcherInitial extends UsersWatcherState {
  const UsersWatcherInitial();
}

final class UsersWatcherLoadInProgress extends UsersWatcherState {
  const UsersWatcherLoadInProgress();
}

final class UsersWatcherLoadSuccess extends UsersWatcherState {
  final KtList<User> users;
  const UsersWatcherLoadSuccess(this.users);
  @override
  List<Object?> get props => [users];
}

final class UsersWatcherLoadFailure extends UsersWatcherState {
  final UserFailure failure;
  const UsersWatcherLoadFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}
