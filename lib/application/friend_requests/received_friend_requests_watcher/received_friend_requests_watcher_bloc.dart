import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';

import '../../../domain/friend_requests/failures.dart';
import '../../../domain/friend_requests/friend_request.dart';
import '../../../domain/friend_requests/friend_requests_repository_interface.dart';

part 'received_friend_requests_watcher_event.dart';

part 'received_friend_requests_watcher_state.dart';

class ReceivedFriendRequestsWatcherBloc
    extends
        Bloc<
          ReceivedFriendRequestsWatcherEvent,
          ReceivedFriendRequestsWatcherState
        > {
  final IFriendRequestsRepository _friendRequestRepository;

  StreamSubscription<Either<FriendRequestFailure, KtList<FriendRequest>>>?
  _receivedFriendRequestsSubscription;

  ReceivedFriendRequestsWatcherBloc(this._friendRequestRepository)
    : super(const ReceivedFriendRequestsWatcherState.initial()) {
    on<ReceivedFriendRequestsWatcherEvent>((event, emit) {
      switch (event) {
        case ReceivedFriendRequestsWatchAllStarted():
          emit(const ReceivedFriendRequestsWatcherState.loadInProgress());
          _receivedFriendRequestsSubscription = _friendRequestRepository
              .watchReceivedForCurrentUser()
              .listen(
                (failureOrFriendRequests) => add(
                  ReceivedFriendRequestsWatcherEvent.friendRequestsReceived(
                    failureOrFriendRequests,
                  ),
                ),
              );
        case ReceivedFriendRequestsReceived():
          emit(
            event.failureOrFriendRequests.fold(
              (failure) =>
                  ReceivedFriendRequestsWatcherState.loadFailure(failure),
              (friendRequests) =>
                  ReceivedFriendRequestsWatcherState.loadSuccess(
                    friendRequests,
                  ),
            ),
          );
      }
    });
  }

  Future<void> refreshSubscription() async {
    await _receivedFriendRequestsSubscription?.cancel();
    Future loadSuccessOrFailureState = stream
        .where(
          (state) =>
              state is ReceivedFriendRequestsWatcherLoadSuccess ||
              state is ReceivedFriendRequestsWatcherLoadFailure,
        )
        .first;
    add(const ReceivedFriendRequestsWatcherEvent.watchAllStarted());
    await loadSuccessOrFailureState;
  }

  @override
  Future<void> close() async {
    await _receivedFriendRequestsSubscription?.cancel();
    return super.close();
  }
}
