import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/authentication/user_facade_interface.dart';
import 'package:routes_chat/domain/authentication/user_failure.dart';

import '../../../domain/authentication/user.dart';
import '../../../domain/core/value_objects.dart';

part 'senders_or_receivers_watcher_event.dart';
part 'senders_or_receivers_watcher_state.dart';
part 'senders_or_receivers_watcher_bloc.freezed.dart';

@injectable
class SendersOrReceiversWatcherBloc extends Bloc<SendersOrReceiversWatcherEvent, SendersOrReceiversWatcherState> {
  final IUserFacade _userRepository;

  StreamSubscription<Either<UserFailure, KtList<User>>>?
  _receivedFriendRequestsSubscription;

  SendersOrReceiversWatcherBloc(this._userRepository)
      : super(const SendersOrReceiversWatcherState.initial()) {
    on<SendersOrReceiversWatcherEvent>(
          (event, emit) {
        event.map(
          watchStarted: (event) {
            emit(const SendersOrReceiversWatcherState.loadInProgress());
            _receivedFriendRequestsSubscription = _userRepository
                .watchUsersWithIds(event.ids)
                .listen(
                  (failureOrFriendRequests) => add(
                    SendersOrReceiversWatcherEvent.friendRequestsReceived(
                    failureOrFriendRequests),
              ),
            );
          },
          friendRequestsReceived: (event) {
            emit(
              event.failureOrFriendRequests.fold(
                    (failure) =>
                        SendersOrReceiversWatcherState.loadFailure(failure),
                    (friendRequests) =>
                        SendersOrReceiversWatcherState.loadSuccess(
                        friendRequests),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _receivedFriendRequestsSubscription?.cancel();
    return super.close();
  }
}
