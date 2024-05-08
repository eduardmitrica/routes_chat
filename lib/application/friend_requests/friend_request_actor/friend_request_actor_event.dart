part of 'friend_request_actor_bloc.dart';

@freezed
class FriendRequestActorEvent with _$FriendRequestActorEvent {
  const factory FriendRequestActorEvent.usernameChanged() = _UsernameChanged;
  const factory FriendRequestActorEvent.sent(String usernameInput) = _Sent;
  const factory FriendRequestActorEvent.accepted(FriendRequest friendRequest) = _Accepted;
  const factory FriendRequestActorEvent.declined(FriendRequest friendRequest) = _Declined;
  const factory FriendRequestActorEvent.rolledBackChanges() = _RolledBackChanges;
}
