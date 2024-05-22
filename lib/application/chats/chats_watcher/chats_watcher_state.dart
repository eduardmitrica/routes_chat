part of 'chats_watcher_bloc.dart';

@freezed
class ChatsWatcherState with _$ChatsWatcherState {
  const factory ChatsWatcherState.initial() = _Initial;

  const factory ChatsWatcherState.loadInProgress() =
  _LoadInProgress;

  const factory ChatsWatcherState.loadSuccess(
      KtList<Chat> chats, KtList<UniqueId> friendsThatCurrentUserHasChatsTo) = _LoadSuccess;

  const factory ChatsWatcherState.loadFailure(
      ChatFailure failure) = _LoadFailure;
}
