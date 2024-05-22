part of 'messages_watcher_bloc.dart';

@freezed
class MessagesWatcherState with _$MessagesWatcherState {
  const factory MessagesWatcherState.initial() = _Initial;

  const factory MessagesWatcherState.loadInProgress() =
  _LoadInProgress;

  const factory MessagesWatcherState.loadSuccess(
      KtList<Message> messages) = _LoadSuccess;

  const factory MessagesWatcherState.loadFailure(
      MessageFailure failure) = _LoadFailure;
}
