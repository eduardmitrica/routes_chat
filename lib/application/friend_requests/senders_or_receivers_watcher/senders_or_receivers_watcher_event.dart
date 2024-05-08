part of 'senders_or_receivers_watcher_bloc.dart';

@freezed
class SendersOrReceiversWatcherEvent with _$SendersOrReceiversWatcherEvent {
  const factory SendersOrReceiversWatcherEvent.watchStarted(KtList<UniqueId> ids) =
  _WatchStarted;

  const factory SendersOrReceiversWatcherEvent.friendRequestsReceived(
      Either<UserFailure, KtList<User>>
      failureOrFriendRequests) = _FriendRequestsReceived;
}
