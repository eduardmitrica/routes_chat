import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:routes_chat/domain/authentication/user_failure.dart';

import '../../../domain/authentication/user.dart';
import '../../../domain/authentication/user_facade_interface.dart';

part 'user_watcher_event.dart';

part 'user_watcher_state.dart';

part 'user_watcher_bloc.freezed.dart';

@injectable
class UserWatcherBloc extends Bloc<UserWatcherEvent, UserWatcherState> {
  final IUserFacade _userFacade;

  StreamSubscription<Either<UserFailure, User>>? _userSubscription;

  UserWatcherBloc(this._userFacade) : super(const UserWatcherState.initial()) {
    on<UserWatcherEvent>((event, emit) {
      event.map(watchStarted: (event) {
        emit(const UserWatcherState.loadInProgress());
        _userSubscription = _userFacade.watch().listen(
              (failureOrUser) => add(
                UserWatcherEvent.userReceived(failureOrUser),
              ),
            );
      }, userReceived: (event) {
        emit(
          event.failureOrUser.fold(
            (failure) => UserWatcherState.loadFailure(failure),
            (user) => UserWatcherState.loadSuccess(user),
          ),
        );
      });
    });
  }

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    return super.close();
  }
}
