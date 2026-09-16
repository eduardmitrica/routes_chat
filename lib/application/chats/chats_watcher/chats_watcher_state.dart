part of 'chats_watcher_bloc.dart';

sealed class ChatsWatcherState extends Equatable {
  const ChatsWatcherState();

  const factory ChatsWatcherState.initial() = ChatsWatcherInitial;
  const factory ChatsWatcherState.loadInProgress() = ChatsWatcherLoadInProgress;
  const factory ChatsWatcherState.loadSuccess(
    KtList<Chat> chats,
    KtList<UniqueId> friendsThatCurrentUserHasChatsTo, {
    Set<String> unreadChatIds,
    Set<String> blockedChatIds,
    Set<String> hiddenPreviewChatIds,
    Set<String> requestChatIds,
    Set<String> hiddenChatIds,
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

  /// The ids of the chats with someone the user blocked.
  final Set<String> blockedChatIds;

  /// The ids of the chats whose last message stays out of sight, sent by
  /// someone while the user had them blocked.
  final Set<String> hiddenPreviewChatIds;

  /// The ids of the chats waiting to be accepted or deleted: from someone
  /// who is not a friend, whom the user has not written to.
  final Set<String> requestChatIds;

  /// The ids of the chats that show nowhere: a request the user deleted with
  /// nothing new since, or one from someone who is not a friend while the
  /// user takes no such messages.
  final Set<String> hiddenChatIds;

  const ChatsWatcherLoadSuccess(
    this.chats,
    this.friendsThatCurrentUserHasChatsTo, {
    this.unreadChatIds = const {},
    this.blockedChatIds = const {},
    this.hiddenPreviewChatIds = const {},
    this.requestChatIds = const {},
    this.hiddenChatIds = const {},
  });

  /// The chats to show in the list: not requests, and not hidden.
  KtList<Chat> get chatsInList => chats.filter(
    (chat) =>
        !requestChatIds.contains(chat.id.getOrCrash()) &&
        !hiddenChatIds.contains(chat.id.getOrCrash()),
  );

  /// The chats waiting to be accepted or deleted.
  KtList<Chat> get requests =>
      chats.filter((chat) => requestChatIds.contains(chat.id.getOrCrash()));

  @override
  List<Object?> get props => [
    chats,
    friendsThatCurrentUserHasChatsTo,
    unreadChatIds,
    blockedChatIds,
    hiddenPreviewChatIds,
    requestChatIds,
    hiddenChatIds,
  ];
}

final class ChatsWatcherLoadFailure extends ChatsWatcherState {
  final ChatFailure failure;
  const ChatsWatcherLoadFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}
