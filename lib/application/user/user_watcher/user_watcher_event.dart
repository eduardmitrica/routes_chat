part of 'user_watcher_bloc.dart';

@freezed
class UserWatcherEvent with _$UserWatcherEvent {
  const factory UserWatcherEvent.watchStarted() = _WatchStarted;
  const factory UserWatcherEvent.userReceived(Either<UserFailure, User> failureOrUser) = _UserReceived;
}
