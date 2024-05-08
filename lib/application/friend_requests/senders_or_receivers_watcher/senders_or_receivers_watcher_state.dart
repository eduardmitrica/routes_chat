part of 'senders_or_receivers_watcher_bloc.dart';

@freezed
class SendersOrReceiversWatcherState with _$SendersOrReceiversWatcherState {
  const factory SendersOrReceiversWatcherState.initial() = _Initial;

  const factory SendersOrReceiversWatcherState.loadInProgress() = _LoadInProgress;

  const factory SendersOrReceiversWatcherState.loadSuccess(
      KtList<User> friendRequests) = _LoadSuccess;

  const factory SendersOrReceiversWatcherState.loadFailure(
      UserFailure failure) = _LoadFailure;
}
