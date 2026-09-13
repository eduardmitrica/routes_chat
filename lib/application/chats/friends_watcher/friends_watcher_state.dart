part of 'friends_watcher_bloc.dart';

sealed class FriendsWatcherState extends Equatable {
  const FriendsWatcherState();

  const factory FriendsWatcherState.initial() = FriendsWatcherInitial;
  const factory FriendsWatcherState.loadInProgress() =
      FriendsWatcherLoadInProgress;
  const factory FriendsWatcherState.loadSuccess(
    KtList<FriendRequest> friendRequests,
    KtList<UniqueId> friendsIds,
  ) = FriendsWatcherLoadSuccess;
  const factory FriendsWatcherState.loadFailure(FriendRequestFailure failure) =
      FriendsWatcherLoadFailure;

  @override
  List<Object?> get props => const [];
}

final class FriendsWatcherInitial extends FriendsWatcherState {
  const FriendsWatcherInitial();
}

final class FriendsWatcherLoadInProgress extends FriendsWatcherState {
  const FriendsWatcherLoadInProgress();
}

final class FriendsWatcherLoadSuccess extends FriendsWatcherState {
  final KtList<FriendRequest> friendRequests;
  final KtList<UniqueId> friendsIds;
  const FriendsWatcherLoadSuccess(this.friendRequests, this.friendsIds);
  @override
  List<Object?> get props => [friendRequests, friendsIds];
}

final class FriendsWatcherLoadFailure extends FriendsWatcherState {
  final FriendRequestFailure failure;
  const FriendsWatcherLoadFailure(this.failure);
  @override
  List<Object?> get props => [failure];
}
