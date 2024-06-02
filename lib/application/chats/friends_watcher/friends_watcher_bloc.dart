import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/injection.dart';

import '../../../domain/core/value_objects.dart';
import '../../../domain/friend_requests/failures.dart';
import '../../../domain/friend_requests/friend_request.dart';
import '../../../domain/friend_requests/friend_requests_repository_interface.dart';

part 'friends_watcher_event.dart';

part 'friends_watcher_state.dart';

part 'friends_watcher_bloc.freezed.dart';

@injectable
class FriendsWatcherBloc
    extends Bloc<FriendsWatcherEvent, FriendsWatcherState> {
  final IFriendRequestsRepository _friendRequestRepository;
  var userId = '';

  StreamSubscription<Either<FriendRequestFailure, KtList<FriendRequest>>>?
      _acceptedFriendRequestsSubscription;

  FriendsWatcherBloc(this._friendRequestRepository)
      : super(const FriendsWatcherState.initial()) {
    on<FriendsWatcherEvent>(
      (event, emit) {
        event.map(
          watchAllStarted: (event) {
            emit(const FriendsWatcherState.loadInProgress());
            _acceptedFriendRequestsSubscription =
                _friendRequestRepository.watchFriendsForCurrentUser().listen(
                      (failureOrFriendRequests) => add(
                        FriendsWatcherEvent.friendRequestsReceived(
                            failureOrFriendRequests),
                      ),
                    );
          },
          friendRequestsReceived: (event) {
            if (userId.isEmpty) {
              final fetchedUserId = getIt<CurrentUseInformationPersistent>().id;
              userId = fetchedUserId;
            }
            emit(
              event.failureOrFriendRequests
                  .fold((failure) => FriendsWatcherState.loadFailure(failure),
                      (friendRequests) {
                final friendRequestsWhereCurrentUserIsNotSender =
                    friendRequests.filter((friendRequest) =>
                        friendRequest.senderId.getOrCrash() != userId);
                final receivingUsersIds =
                    friendRequestsWhereCurrentUserIsNotSender
                        .map((friendRequest) => friendRequest.senderId);
                final friendRequestsWhereCurrentUserIsNotReceiver =
                    friendRequests.filter((friendRequest) =>
                        friendRequest.receiverId.getOrCrash() != userId);
                final sendingUsersIds =
                    friendRequestsWhereCurrentUserIsNotReceiver
                        .map((friendRequest) => friendRequest.receiverId);
                final friendsIds = receivingUsersIds + sendingUsersIds;

                return FriendsWatcherState.loadSuccess(
                    friendRequests, friendsIds);
              }),
            );
          },
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _acceptedFriendRequestsSubscription?.cancel();
    return super.close();
  }
}
