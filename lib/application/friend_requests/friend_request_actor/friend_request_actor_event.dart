part of 'friend_request_actor_bloc.dart';

sealed class FriendRequestActorEvent extends Equatable {
  const FriendRequestActorEvent();

  const factory FriendRequestActorEvent.usernameChanged() =
      FriendRequestActorUsernameChanged;
  const factory FriendRequestActorEvent.sent(String usernameInput) =
      FriendRequestActorSent;
  const factory FriendRequestActorEvent.accepted(FriendRequest friendRequest) =
      FriendRequestActorAccepted;
  const factory FriendRequestActorEvent.declined(FriendRequest friendRequest) =
      FriendRequestActorDeclined;
  const factory FriendRequestActorEvent.rolledBackChanges() =
      FriendRequestActorRolledBackChanges;

  @override
  List<Object?> get props => const [];
}

final class FriendRequestActorUsernameChanged extends FriendRequestActorEvent {
  const FriendRequestActorUsernameChanged();
}

final class FriendRequestActorSent extends FriendRequestActorEvent {
  final String usernameInput;
  const FriendRequestActorSent(this.usernameInput);
  @override
  List<Object?> get props => [usernameInput];
}

final class FriendRequestActorAccepted extends FriendRequestActorEvent {
  final FriendRequest friendRequest;
  const FriendRequestActorAccepted(this.friendRequest);
  @override
  List<Object?> get props => [friendRequest];
}

final class FriendRequestActorDeclined extends FriendRequestActorEvent {
  final FriendRequest friendRequest;
  const FriendRequestActorDeclined(this.friendRequest);
  @override
  List<Object?> get props => [friendRequest];
}

final class FriendRequestActorRolledBackChanges
    extends FriendRequestActorEvent {
  const FriendRequestActorRolledBackChanges();
}
