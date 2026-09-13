part of 'users_watcher_bloc.dart';

sealed class UsersWatcherEvent extends Equatable {
  const UsersWatcherEvent();

  const factory UsersWatcherEvent.watchStarted(KtList<UniqueId> ids) =
      UsersWatchStarted;

  const factory UsersWatcherEvent.friendRequestsReceived(
    Either<UserFailure, KtList<User>> failureOrFriendRequests,
  ) = UsersFriendRequestsReceived;

  @override
  List<Object?> get props => const [];
}

final class UsersWatchStarted extends UsersWatcherEvent {
  final KtList<UniqueId> ids;
  const UsersWatchStarted(this.ids);
  @override
  List<Object?> get props => [ids];
}

final class UsersFriendRequestsReceived extends UsersWatcherEvent {
  final Either<UserFailure, KtList<User>> failureOrFriendRequests;
  const UsersFriendRequestsReceived(this.failureOrFriendRequests);
  @override
  List<Object?> get props => [failureOrFriendRequests];
}
