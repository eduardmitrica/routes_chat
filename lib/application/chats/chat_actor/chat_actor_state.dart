part of 'chat_actor_bloc.dart';

sealed class ChatActorState extends Equatable {
  const ChatActorState();

  const factory ChatActorState.initial() = ChatActorInitial;
  const factory ChatActorState.actionInProgress() = ChatActorActionInProgress;
  const factory ChatActorState.creationFailure(ChatFailure noteFailure) =
      ChatActorCreationFailure;
  const factory ChatActorState.creationSuccess() = ChatActorCreationSuccess;

  @override
  List<Object?> get props => const [];
}

final class ChatActorInitial extends ChatActorState {
  const ChatActorInitial();
}

final class ChatActorActionInProgress extends ChatActorState {
  const ChatActorActionInProgress();
}

final class ChatActorCreationFailure extends ChatActorState {
  final ChatFailure noteFailure;
  const ChatActorCreationFailure(this.noteFailure);
  @override
  List<Object?> get props => [noteFailure];
}

final class ChatActorCreationSuccess extends ChatActorState {
  const ChatActorCreationSuccess();
}
