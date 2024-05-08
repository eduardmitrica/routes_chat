part of 'friend_request_actor_bloc.dart';

@freezed
class FriendRequestActorState with _$FriendRequestActorState {
  const factory FriendRequestActorState.initial() = _Initial;
  const factory FriendRequestActorState.actionInProgress() = _ActionInProgress;
  const factory FriendRequestActorState.sendingFailure() = _SendingFailure;
  const factory FriendRequestActorState.sendingSuccess() = _SendingSuccess;
  const factory FriendRequestActorState.acceptingSuccess() = _AcceptingSuccess;
  const factory FriendRequestActorState.acceptingFailure() = _AcceptingFailure;
  const factory FriendRequestActorState.decliningSuccess() = _DecliningSuccess;
  const factory FriendRequestActorState.decliningFailure() = _DecliningFailure;
  const factory FriendRequestActorState.requestAlreadySent() = _RequestAlreadySent;
  const factory FriendRequestActorState.alreadyFriends() = _AlreadyFriends;
  const factory FriendRequestActorState.friendRequestAlreadySentFromReceiver() = _FriendRequestAlreadySentFromReceiver;
  const factory FriendRequestActorState.resetToInitial() = _ResetToInitial;
}
