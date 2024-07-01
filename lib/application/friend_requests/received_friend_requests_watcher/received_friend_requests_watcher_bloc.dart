import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';

import '../../../domain/friend_requests/failures.dart';
import '../../../domain/friend_requests/friend_request.dart';
import '../../../domain/friend_requests/friend_requests_repository_interface.dart';

part 'received_friend_requests_watcher_event.dart';

part 'received_friend_requests_watcher_state.dart';

part 'received_friend_requests_watcher_bloc.freezed.dart';

@injectable
class ReceivedFriendRequestsWatcherBloc extends Bloc<
    ReceivedFriendRequestsWatcherEvent, ReceivedFriendRequestsWatcherState> {
  final IFriendRequestsRepository _friendRequestRepository;

  StreamSubscription<Either<FriendRequestFailure, KtList<FriendRequest>>>?
      _receivedFriendRequestsSubscription;

  ReceivedFriendRequestsWatcherBloc(this._friendRequestRepository)
      : super(const ReceivedFriendRequestsWatcherState.initial()) {
    on<ReceivedFriendRequestsWatcherEvent>(
      (event, emit) {
        event.map(
          watchAllStarted: (event) {
            emit(const ReceivedFriendRequestsWatcherState.loadInProgress());
            _receivedFriendRequestsSubscription = _friendRequestRepository
                .watchReceivedForCurrentUser()
                .listen(
                  (failureOrFriendRequests) => add(
                    ReceivedFriendRequestsWatcherEvent.friendRequestsReceived(
                        failureOrFriendRequests),
                  ),
                );
          },
          friendRequestsReceived: (event) {
            emit(
              event.failureOrFriendRequests.fold(
                (failure) =>
                    ReceivedFriendRequestsWatcherState.loadFailure(failure),
                (friendRequests) =>
                    ReceivedFriendRequestsWatcherState.loadSuccess(
                        friendRequests),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> refreshSubscription() async {
    await _receivedFriendRequestsSubscription?.cancel();
    Future loadSuccessOrFailureState = stream
        .where((state) => state.maybeMap(
            loadSuccess: (_) => true,
            loadFailure: (_) => true,
            orElse: () => false))
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
