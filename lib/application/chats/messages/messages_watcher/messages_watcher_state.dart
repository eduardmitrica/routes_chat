part of 'messages_watcher_bloc.dart';

sealed class MessagesWatcherState extends Equatable {
  const MessagesWatcherState();

  const factory MessagesWatcherState.initial() = MessagesWatcherInitial;
  const factory MessagesWatcherState.loadInProgress() =
      MessagesWatcherLoadInProgress;
  const factory MessagesWatcherState.loadSuccess(KtList<Message> messages) =
      MessagesWatcherLoadSuccess;
  const factory MessagesWatcherState.loadFailure(MessageFailure failure) =
      MessagesWatcherLoadFailure;

  @override
  List<Object?> get props => const [];
}

final class MessagesWatcherInitial extends MessagesWatcherState {
  const MessagesWatcherInitial();
}

final class MessagesWatcherLoadInProgress extends MessagesWatcherState {
  const MessagesWatcherLoadInProgress();
}

final class MessagesWatcherLoadSuccess extends MessagesWatcherState {
  final KtList<Message> messages;
  const MessagesWatcherLoadSuccess(this.messages);
  @override
  List<Object?> get props => [messages];
}

final class MessagesWatcherLoadFailure extends MessagesWatcherState {
  final MessageFailure failure;
  const MessagesWatcherLoadFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}
