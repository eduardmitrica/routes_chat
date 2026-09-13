import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:routes_chat/domain/shared/user/user_failure.dart';

import '../../../domain/shared/user/user.dart';
import '../../../domain/shared/user/user_repository_interface.dart';

part 'user_watcher_event.dart';

part 'user_watcher_state.dart';

class UserWatcherBloc extends Bloc<UserWatcherEvent, UserWatcherState> {
  final IUserRepository _userRepository;

  StreamSubscription<Either<UserFailure, User>>? _userSubscription;

  UserWatcherBloc(this._userRepository)
    : super(const UserWatcherState.initial()) {
    on<UserWatcherEvent>((event, emit) {
      switch (event) {
        case UserWatchStarted():
          emit(const UserWatcherState.loadInProgress());
          _userSubscription = _userRepository.watch().listen(
            (failureOrUser) =>
                add(UserWatcherEvent.userReceived(failureOrUser)),
          );
        case UserReceived():
          emit(
            event.failureOrUser.fold(
              (failure) => UserWatcherState.loadFailure(failure),
              (user) => UserWatcherState.loadSuccess(user),
            ),
          );
      }
    });
  }

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    return super.close();
  }
}
