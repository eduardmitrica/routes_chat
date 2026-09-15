part of 'messages_watcher_bloc.dart';

sealed class MessagesWatcherEvent extends Equatable {
  const MessagesWatcherEvent();

  const factory MessagesWatcherEvent.watchStarted(UniqueId chatId) =
      MessagesWatchStarted;
  const factory MessagesWatcherEvent.latestReceived(
    Either<MessageFailure, MessagePage> failureOrPage,
  ) = MessagesLatestReceived;
  const factory MessagesWatcherEvent.olderRequested() = MessagesOlderRequested;
  const factory MessagesWatcherEvent.searchChanged(String query) =
      MessagesSearchChanged;
  const factory MessagesWatcherEvent.searchClosed() = MessagesSearchClosed;
  const factory MessagesWatcherEvent.messageRevealRequested(
    UniqueId messageId,
  ) = MessageRevealRequested;
  const factory MessagesWatcherEvent.reactionsReceived(
    Either<MessageFailure, KtList<MessageReaction>> failureOrReactions,
  ) = MessagesReactionsReceived;
  const factory MessagesWatcherEvent.messageChanged(Message message) =
      MessageChanged;
  const factory MessagesWatcherEvent.blocksChanged() = MessagesBlocksChanged;

  @override
  List<Object?> get props => const [];
}

/// Start showing [chatId]'s messages, newest page first.
final class MessagesWatchStarted extends MessagesWatcherEvent {
  final UniqueId chatId;
  const MessagesWatchStarted(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

/// The newest page changed, or could not be loaded.
final class MessagesLatestReceived extends MessagesWatcherEvent {
  final Either<MessageFailure, MessagePage> failureOrPage;
  const MessagesLatestReceived(this.failureOrPage);
  @override
  List<Object?> get props => [failureOrPage];
}

/// The user scrolled near the oldest message loaded.
final class MessagesOlderRequested extends MessagesWatcherEvent {
  const MessagesOlderRequested();
}

/// The user typed [query] in the chat's search.
final class MessagesSearchChanged extends MessagesWatcherEvent {
  final String query;
  const MessagesSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// The user left the search.
final class MessagesSearchClosed extends MessagesWatcherEvent {
  const MessagesSearchClosed();
}

/// The user wants to see [messageId], such as the message a reply quotes.
/// Older pages load until it is loaded.
final class MessageRevealRequested extends MessagesWatcherEvent {
  final UniqueId messageId;
  const MessageRevealRequested(this.messageId);
  @override
  List<Object?> get props => [messageId];
}

/// The reactions to the messages loaded changed, or could not be loaded.
final class MessagesReactionsReceived extends MessagesWatcherEvent {
  final Either<MessageFailure, KtList<MessageReaction>> failureOrReactions;
  const MessagesReactionsReceived(this.failureOrReactions);
  @override
  List<Object?> get props => [failureOrReactions];
}

/// The user edited or deleted [message]. It shows as it is now even when it
/// is on an older page, which does not update by itself.
final class MessageChanged extends MessagesWatcherEvent {
  final Message message;
  const MessageChanged(this.message);
  @override
  List<Object?> get props => [message];
}

/// The user blocked or unblocked someone.
final class MessagesBlocksChanged extends MessagesWatcherEvent {
  const MessagesBlocksChanged();
}
