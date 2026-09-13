part of 'chat_actor_bloc.dart';

sealed class ChatActorEvent extends Equatable {
  const ChatActorEvent();

  const factory ChatActorEvent.created(
    KtList<UniqueId> otherThanCurrentParticipantIds,
    Message firstMessage,
  ) = ChatActorCreated;

  @override
  List<Object?> get props => const [];
}

final class ChatActorCreated extends ChatActorEvent {
  final KtList<UniqueId> otherThanCurrentParticipantIds;
  final Message firstMessage;
  const ChatActorCreated(
    this.otherThanCurrentParticipantIds,
    this.firstMessage,
  );
  @override
  List<Object?> get props => [otherThanCurrentParticipantIds, firstMessage];
}
