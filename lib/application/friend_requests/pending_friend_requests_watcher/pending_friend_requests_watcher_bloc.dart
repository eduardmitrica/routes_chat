import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';

import '../../../domain/friend_requests/failures.dart';
import '../../../domain/friend_requests/friend_request.dart';
import '../../../domain/friend_requests/friend_requests_repository_interface.dart';

part 'pending_friend_requests_watcher_event.dart';

part 'pending_friend_requests_watcher_state.dart';

class PendingFriendRequestsWatcherBloc
    extends
        Bloc<
          PendingFriendRequestsWatcherEvent,
          PendingFriendRequestsWatcherState
        > {
  final IFriendRequestsRepository _friendRequestRepository;

  StreamSubscription<Either<FriendRequestFailure, KtList<FriendRequest>>>?
  _pendingFriendRequestsSubscription;

  PendingFriendRequestsWatcherBloc(this._friendRequestRepository)
    : super(const PendingFriendRequestsWatcherState.initial()) {
    on<PendingFriendRequestsWatcherEvent>((event, emit) {
      switch (event) {
        case PendingFriendRequestsWatchAllStarted():
          emit(const PendingFriendRequestsWatcherState.loadInProgress());
          _pendingFriendRequestsSubscription = _friendRequestRepository
              .watchPendingFromCurrentUser()
              .listen(
                (failureOrFriendRequests) => add(
                  PendingFriendRequestsWatcherEvent.friendRequestsReceived(
                    failureOrFriendRequests,
                  ),
                ),
              );
        case PendingFriendRequestsReceived():
          emit(
            event.failureOrFriendRequests.fold(
              (failure) =>
                  PendingFriendRequestsWatcherState.loadFailure(failure),
              (friendRequests) =>
                  PendingFriendRequestsWatcherState.loadSuccess(friendRequests),
            ),
          );
      }
    });
  }

  Future<void> refreshSubscription() async {
    await _pendingFriendRequestsSubscription?.cancel();
    Future loadSuccessOrFailureState = stream
        .where(
          (state) =>
              state is PendingFriendRequestsWatcherLoadSuccess ||
              state is PendingFriendRequestsWatcherLoadFailure,
        )
        .first;
    add(const PendingFriendRequestsWatcherEvent.watchAllStarted());
    await loadSuccessOrFailureState;
  }

  @override
  Future<void> close() async {
    await _pendingFriendRequestsSubscription?.cancel();
    return super.close();
  }
}
