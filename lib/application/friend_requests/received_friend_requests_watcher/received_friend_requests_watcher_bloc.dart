import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';

import '../../../domain/friend_requests/failures.dart';
import '../../../domain/friend_requests/friend_request.dart';
import '../../../domain/friend_requests/friend_requests_repository_interface.dart';
import '../../../domain/safety/blocks.dart';

part 'received_friend_requests_watcher_event.dart';

part 'received_friend_requests_watcher_state.dart';

class ReceivedFriendRequestsWatcherBloc
    extends
        Bloc<
          ReceivedFriendRequestsWatcherEvent,
          ReceivedFriendRequestsWatcherState
        > {
  final IFriendRequestsRepository _friendRequestRepository;

  /// Requests from someone the user blocked stay out of sight.
  final IBlockList? _blocks;
  StreamSubscription<Blocks>? _blocksSubscription;
  KtList<FriendRequest>? _received;

  StreamSubscription<Either<FriendRequestFailure, KtList<FriendRequest>>>?
  _receivedFriendRequestsSubscription;

  ReceivedFriendRequestsWatcherBloc(
    this._friendRequestRepository, {
    IBlockList? blocks,
  }) : _blocks = blocks,
       super(const ReceivedFriendRequestsWatcherState.initial()) {
    on<ReceivedFriendRequestsWatcherEvent>((event, emit) {
      switch (event) {
        case ReceivedFriendRequestsWatchAllStarted():
          emit(const ReceivedFriendRequestsWatcherState.loadInProgress());
          _blocksSubscription ??= _blocks?.blocksChanges.listen((_) {
            if (!isClosed) {
              add(const ReceivedFriendRequestsWatcherEvent.blocksChanged());
            }
          });
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
              (friendRequests) {
                _received = friendRequests;
                return ReceivedFriendRequestsWatcherState.loadSuccess(
                  _visible(friendRequests),
                );
              },
            ),
          );
        case ReceivedFriendRequestsBlocksChanged():
          final received = _received;
          if (received != null &&
              state is ReceivedFriendRequestsWatcherLoadSuccess) {
            emit(
              ReceivedFriendRequestsWatcherState.loadSuccess(
                _visible(received),
              ),
            );
          }
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

  /// [friendRequests] except those from someone the user blocked.
  KtList<FriendRequest> _visible(KtList<FriendRequest> friendRequests) {
    final blocks = _blocks?.blocks;
    if (blocks == null) return friendRequests;
    return friendRequests.filter(
      (friendRequest) => !blocks.isBlocked(friendRequest.senderId),
    );
  }

  @override
  Future<void> close() async {
    await _receivedFriendRequestsSubscription?.cancel();
    await _blocksSubscription?.cancel();
    return super.close();
  }
}
