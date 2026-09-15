part of 'chats_watcher_bloc.dart';

sealed class ChatsWatcherState extends Equatable {
  const ChatsWatcherState();

  const factory ChatsWatcherState.initial() = ChatsWatcherInitial;
  const factory ChatsWatcherState.loadInProgress() = ChatsWatcherLoadInProgress;
  const factory ChatsWatcherState.loadSuccess(
    KtList<Chat> chats,
    KtList<UniqueId> friendsThatCurrentUserHasChatsTo, {
    Set<String> unreadChatIds,
  }) = ChatsWatcherLoadSuccess;
  const factory ChatsWatcherState.loadFailure(ChatFailure failure) =
      ChatsWatcherLoadFailure;

  @override
  List<Object?> get props => const [];
}

final class ChatsWatcherInitial extends ChatsWatcherState {
  const ChatsWatcherInitial();
}

final class ChatsWatcherLoadInProgress extends ChatsWatcherState {
  const ChatsWatcherLoadInProgress();
}

final class ChatsWatcherLoadSuccess extends ChatsWatcherState {
  final KtList<Chat> chats;
  final KtList<UniqueId> friendsThatCurrentUserHasChatsTo;

  /// The ids of the chats with messages the user has not read on this phone.
  final Set<String> unreadChatIds;

  const ChatsWatcherLoadSuccess(
    this.chats,
    this.friendsThatCurrentUserHasChatsTo, {
    this.unreadChatIds = const {},
  });
  @override
  List<Object?> get props => [
    chats,
    friendsThatCurrentUserHasChatsTo,
    unreadChatIds,
  ];
}

final class ChatsWatcherLoadFailure extends ChatsWatcherState {
  final ChatFailure failure;
  const ChatsWatcherLoadFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}
