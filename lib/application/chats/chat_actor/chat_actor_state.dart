part of 'chat_actor_bloc.dart';

@freezed
class ChatActorState with _$ChatActorState {
  const factory ChatActorState.initial() = _Initial;
  const factory ChatActorState.actionInProgress() = _ActionInProgress;
  const factory ChatActorState.creationFailure(ChatFailure noteFailure) = _CreationFailure;
  const factory ChatActorState.creationSuccess() = _CreationSuccess;
}
