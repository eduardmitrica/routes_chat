import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/domain/core/composite_id.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/failures.dart';
import 'package:routes_chat/domain/friend_requests/value_objects.dart';
import '../../../domain/friend_requests/friend_request.dart';
import '../../../domain/friend_requests/friend_requests_repository_interface.dart';
import '../../../domain/shared/user/user_repository_interface.dart';
import '../../../domain/shared/user/value_objects.dart';

part 'friend_request_actor_event.dart';

part 'friend_request_actor_state.dart';

class FriendRequestActorBloc
    extends Bloc<FriendRequestActorEvent, FriendRequestActorState> {
  final IFriendRequestsRepository _friendRequestRepository;
  final IUserRepository _userRepository;
  final ICurrentUserSession _session;

  FriendRequestActorBloc(
    this._friendRequestRepository,
    this._userRepository,
    this._session,
  ) : super(const FriendRequestActorState.initial()) {
    on<FriendRequestActorEvent>((event, emit) async {
      switch (event) {
        case FriendRequestActorUsernameChanged():
          emit(const FriendRequestActorState.initial());
        case FriendRequestActorSent():
          {
            emit(const FriendRequestActorState.actionInProgress());
            final username = Username(event.usernameInput);
            if (username.isValid()) {
              final currentUserDetails = _session.current;
              final sendingUserUsername = currentUserDetails?.username ?? '';
              final sendingUserId = currentUserDetails?.id ?? '';

              if (sendingUserUsername != username.getOrCrash()) {
                final receivingUser = await _userRepository.findUserByUsername(
                  username,
                );

                await receivingUser.fold(
                  (failure) {
                    emit(const FriendRequestActorState.sendingFailure());
                  },
                  (receivingUser) async {
                    final senderId = UniqueId.fromUniqueString(sendingUserId);
                    final friendRequest = FriendRequest(
                      // One document per pair of users, whichever of them
                      // sends first; see compositeId.
                      id: compositeId([senderId, receivingUser.id]),
                      senderId: senderId,
                      receiverId: receivingUser.id,
                      status: Status(Pending()),
                    );

                    final searchResult = await _friendRequestRepository
                        .findBySenderAndReceiverIds(
                          friendRequest.senderId,
                          friendRequest.receiverId,
                        );
                    await searchResult.fold(
                      (failure) async {
                        if (failure case NotFound()) {
                          final reverseSearchResult =
                              await _friendRequestRepository
                                  .findBySenderAndReceiverIds(
                                    friendRequest.receiverId,
                                    friendRequest.senderId,
                                  );
                          await reverseSearchResult.fold(
                            (failure) async {
                              if (failure case NotFound()) {
                                final possibleFailure =
                                    await _friendRequestRepository.create(
                                      friendRequest,
                                    );
                                possibleFailure.fold(
                                  (failure) => emit(
                                    const FriendRequestActorState.sendingFailure(),
                                  ),
                                  (_) => emit(
                                    const FriendRequestActorState.sendingSuccess(),
                                  ),
                                );
                              } else {
                                emit(
                                  const FriendRequestActorState.sendingFailure(),
                                );
                              }
                            },
                            (friendRequest) {
                              emit(
                                const FriendRequestActorState.friendRequestAlreadySentFromReceiver(),
                              );
                            },
                          );
                        } else {
                          emit(const FriendRequestActorState.sendingFailure());
                        }
                      },
                      (friendRequest) {
                        final status = friendRequest.status.getOrCrash();
                        if (status case Pending()) {
                          emit(
                            const FriendRequestActorState.requestAlreadySent(),
                          );
                        } else {
                          emit(const FriendRequestActorState.alreadyFriends());
                        }
                      },
                    );
                  },
                );
              } else {
                emit(const FriendRequestActorState.alreadyFriends());
              }
            } else {
              emit(const FriendRequestActorState.sendingFailure());
            }
          }
        case FriendRequestActorAccepted():
          {
            emit(const FriendRequestActorState.actionInProgress());
            final operationResult = await _friendRequestRepository.update(
              event.friendRequest.copyWith(status: Status(Accepted())),
            );

            emit(
              operationResult.fold(
                (failure) => const FriendRequestActorState.acceptingFailure(),
                (_) => const FriendRequestActorState.sendingSuccess(),
              ),
            );
          }
        case FriendRequestActorDeclined():
          {
            emit(const FriendRequestActorState.actionInProgress());
            final operationResult = await _friendRequestRepository.delete(
              event.friendRequest,
            );

            emit(
              operationResult.fold(
                (failure) => const FriendRequestActorState.decliningFailure(),
                (_) => const FriendRequestActorState.decliningSuccess(),
              ),
            );
          }
        case FriendRequestActorRolledBackChanges():
          emit(const FriendRequestActorState.resetToInitial());
      }
    });
  }
}
