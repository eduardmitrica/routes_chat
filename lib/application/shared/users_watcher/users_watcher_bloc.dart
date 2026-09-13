import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/shared/user/user_failure.dart';

import '../../../domain/shared/user/user.dart';
import '../../../domain/core/value_objects.dart';
import '../../../domain/shared/user/user_repository_interface.dart';

part 'users_watcher_event.dart';
part 'users_watcher_state.dart';

class UsersWatcherBloc extends Bloc<UsersWatcherEvent, UsersWatcherState> {
  final IUserRepository _userRepository;

  StreamSubscription<Either<UserFailure, KtList<User>>>?
  _receivedFriendRequestsSubscription;

  UsersWatcherBloc(this._userRepository)
    : super(const UsersWatcherState.initial()) {
    on<UsersWatcherEvent>((event, emit) {
      switch (event) {
        case UsersWatchStarted():
          emit(const UsersWatcherState.loadInProgress());
          _receivedFriendRequestsSubscription = _userRepository
              .watchUsersWithIds(event.ids)
              .listen(
                (failureOrFriendRequests) => add(
                  UsersWatcherEvent.friendRequestsReceived(
                    failureOrFriendRequests,
                  ),
                ),
              );
        case UsersFriendRequestsReceived():
          emit(
            event.failureOrFriendRequests.fold(
              (failure) => UsersWatcherState.loadFailure(failure),
              (friendRequests) => UsersWatcherState.loadSuccess(friendRequests),
            ),
          );
      }
    });
  }

  @override
  Future<void> close() async {
    await _receivedFriendRequestsSubscription?.cancel();
    return super.close();
  }
}
