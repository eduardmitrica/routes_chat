part of 'chat_actor_bloc.dart';

@freezed
class ChatActorEvent with _$ChatActorEvent {
  const factory ChatActorEvent.created(KtList<UniqueId> otherThanCurrentParticipantIds, Message firstMessage) = _Created;
}
