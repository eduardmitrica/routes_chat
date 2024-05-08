import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';

import '../../../domain/friend_requests/failures.dart';
import '../../../domain/friend_requests/friend_request.dart';
import '../../../domain/friend_requests/friend_requests_repository_interface.dart';

part 'pending_friend_requests_watcher_event.dart';
part 'pending_friend_requests_watcher_state.dart';
part 'pending_friend_requests_watcher_bloc.freezed.dart';

@injectable
class PendingFriendRequestsWatcherBloc extends Bloc<PendingFriendRequestsWatcherEvent, PendingFriendRequestsWatcherState> {
  final IFriendRequestsRepository _friendRequestRepository;

  StreamSubscription<Either<FriendRequestFailure, KtList<FriendRequest>>>?
  _pendingFriendRequestsSubscription;

  PendingFriendRequestsWatcherBloc(this._friendRequestRepository)
      : super(const PendingFriendRequestsWatcherState.initial()) {
    on<PendingFriendRequestsWatcherEvent>(
          (event, emit) {
        event.map(
          watchAllStarted: (event) {
            emit(const PendingFriendRequestsWatcherState.loadInProgress());
            _pendingFriendRequestsSubscription =
                _friendRequestRepository.watchPendingFromCurrentUser().listen(
                      (failureOrFriendRequests) => add(
                        PendingFriendRequestsWatcherEvent.friendRequestsReceived(
                        failureOrFriendRequests),
                  ),
                );
          },
          friendRequestsReceived: (event) {
            emit(
              event.failureOrFriendRequests.fold(
                    (failure) => PendingFriendRequestsWatcherState.loadFailure(failure),
                    (friendRequests) =>
                        PendingFriendRequestsWatcherState.loadSuccess(friendRequests),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> refreshSubscription() async{
    _pendingFriendRequestsSubscription?.cancel();
    add(const PendingFriendRequestsWatcherEvent.watchAllStarted());
  }

  @override
  Future<void> close() async {
    await _pendingFriendRequestsSubscription?.cancel();
    return super.close();
  }
}
