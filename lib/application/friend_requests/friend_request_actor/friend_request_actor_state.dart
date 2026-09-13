part of 'friend_request_actor_bloc.dart';

sealed class FriendRequestActorState extends Equatable {
  const FriendRequestActorState();

  const factory FriendRequestActorState.initial() = FriendRequestActorInitial;
  const factory FriendRequestActorState.actionInProgress() =
      FriendRequestActorActionInProgress;
  const factory FriendRequestActorState.sendingFailure() =
      FriendRequestActorSendingFailure;
  const factory FriendRequestActorState.sendingSuccess() =
      FriendRequestActorSendingSuccess;
  const factory FriendRequestActorState.acceptingSuccess() =
      FriendRequestActorAcceptingSuccess;
  const factory FriendRequestActorState.acceptingFailure() =
      FriendRequestActorAcceptingFailure;
  const factory FriendRequestActorState.decliningSuccess() =
      FriendRequestActorDecliningSuccess;
  const factory FriendRequestActorState.decliningFailure() =
      FriendRequestActorDecliningFailure;
  const factory FriendRequestActorState.requestAlreadySent() =
      FriendRequestActorRequestAlreadySent;
  const factory FriendRequestActorState.alreadyFriends() =
      FriendRequestActorAlreadyFriends;
  const factory FriendRequestActorState.friendRequestAlreadySentFromReceiver() =
      FriendRequestActorFriendRequestAlreadySentFromReceiver;
  const factory FriendRequestActorState.resetToInitial() =
      FriendRequestActorResetToInitial;

  @override
  List<Object?> get props => const [];
}

final class FriendRequestActorInitial extends FriendRequestActorState {
  const FriendRequestActorInitial();
}

final class FriendRequestActorActionInProgress extends FriendRequestActorState {
  const FriendRequestActorActionInProgress();
}

final class FriendRequestActorSendingFailure extends FriendRequestActorState {
  const FriendRequestActorSendingFailure();
}

final class FriendRequestActorSendingSuccess extends FriendRequestActorState {
  const FriendRequestActorSendingSuccess();
}

final class FriendRequestActorAcceptingSuccess extends FriendRequestActorState {
  const FriendRequestActorAcceptingSuccess();
}

final class FriendRequestActorAcceptingFailure extends FriendRequestActorState {
  const FriendRequestActorAcceptingFailure();
}

final class FriendRequestActorDecliningSuccess extends FriendRequestActorState {
  const FriendRequestActorDecliningSuccess();
}

final class FriendRequestActorDecliningFailure extends FriendRequestActorState {
  const FriendRequestActorDecliningFailure();
}

final class FriendRequestActorRequestAlreadySent
    extends FriendRequestActorState {
  const FriendRequestActorRequestAlreadySent();
}

final class FriendRequestActorAlreadyFriends extends FriendRequestActorState {
  const FriendRequestActorAlreadyFriends();
}

final class FriendRequestActorFriendRequestAlreadySentFromReceiver
    extends FriendRequestActorState {
  const FriendRequestActorFriendRequestAlreadySentFromReceiver();
}

final class FriendRequestActorResetToInitial extends FriendRequestActorState {
  const FriendRequestActorResetToInitial();
}
