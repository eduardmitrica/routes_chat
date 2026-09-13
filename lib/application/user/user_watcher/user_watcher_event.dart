part of 'user_watcher_bloc.dart';

sealed class UserWatcherEvent extends Equatable {
  const UserWatcherEvent();

  const factory UserWatcherEvent.watchStarted() = UserWatchStarted;
  const factory UserWatcherEvent.userReceived(
    Either<UserFailure, User> failureOrUser,
  ) = UserReceived;

  @override
  List<Object?> get props => const [];
}

final class UserWatchStarted extends UserWatcherEvent {
  const UserWatchStarted();
}

final class UserReceived extends UserWatcherEvent {
  final Either<UserFailure, User> failureOrUser;
  const UserReceived(this.failureOrUser);
  @override
  List<Object?> get props => [failureOrUser];
}
