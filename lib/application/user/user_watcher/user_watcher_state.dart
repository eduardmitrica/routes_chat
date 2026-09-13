part of 'user_watcher_bloc.dart';

sealed class UserWatcherState extends Equatable {
  const UserWatcherState();

  const factory UserWatcherState.initial() = UserWatcherInitial;
  const factory UserWatcherState.loadInProgress() = UserWatcherLoadInProgress;
  const factory UserWatcherState.loadSuccess(User user) =
      UserWatcherLoadSuccess;
  const factory UserWatcherState.loadFailure(UserFailure failure) =
      UserWatcherLoadFailure;

  @override
  List<Object?> get props => const [];
}

final class UserWatcherInitial extends UserWatcherState {
  const UserWatcherInitial();
}

final class UserWatcherLoadInProgress extends UserWatcherState {
  const UserWatcherLoadInProgress();
}

final class UserWatcherLoadSuccess extends UserWatcherState {
  final User user;
  const UserWatcherLoadSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

final class UserWatcherLoadFailure extends UserWatcherState {
  final UserFailure failure;
  const UserWatcherLoadFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}
