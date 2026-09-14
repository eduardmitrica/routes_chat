import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/core/composite_id.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/failures.dart';
import 'package:routes_chat/domain/friend_requests/friend_request.dart';
import 'package:routes_chat/domain/friend_requests/friend_requests_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/infrastructure/friend_requests/friend_request_data_transfer_object.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/friend_requests/value_objects.dart';
import '../../domain/friend_requests/value_validators.dart';

class FriendRequestRepository implements IFriendRequestsRepository {
  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;

  const FriendRequestRepository(this._firestore, this._session);

  @override
  Future<Either<FriendRequestFailure, Unit>> create(
    FriendRequest friendRequest,
  ) async {
    final friendRequestDto = FriendRequestDataTransferObject.fromDomain(
      friendRequest,
    );
    // The id is the pair of users (compositeId), so a request in either
    // direction is this same document. Reading it with transaction.get lets
    // Firestore retry when another create commits first. The previous check,
    // a query run inside the transaction, was invisible to it, so two
    // simultaneous requests could both be written.
    final friendRequestRef = _firestore
        .collection('friendRequests')
        .doc(friendRequest.id.getOrCrash());
    try {
      await _firestore.runTransaction((transaction) async {
        final existingRequest = await transaction.get(friendRequestRef);
        if (!existingRequest.exists) {
          transaction.set(friendRequestRef, friendRequestDto.toJson());
        }
      });
      return const Right(unit);
    } on FirebaseException catch (exception) {
      if (exception.code.contains('permission-denied')) {
        return Left(InsufficientPermissions());
      } else {
        return Left(Unexpected());
      }
    }
  }

  @override
  Future<Either<FriendRequestFailure, Unit>> delete(
    FriendRequest friendRequest,
  ) async {
    try {
      await _firestore
          .collection('friendRequests')
          .doc(friendRequest.id.getOrCrash())
          .delete();
      return const Right(unit);
    } on FirebaseException catch (exception) {
      if (exception.code.contains('permission-denied')) {
        return Left(InsufficientPermissions());
      } else {
        return Left(Unexpected());
      }
    }
  }

  @override
  Future<Either<FriendRequestFailure, Unit>> update(
    FriendRequest friendRequest,
  ) async {
    try {
      await _firestore
          .collection('friendRequests')
          .doc(friendRequest.id.getOrCrash())
          .update(
            FriendRequestDataTransferObject.fromDomain(friendRequest).toJson(),
          );
      return const Right(unit);
    } on FirebaseException catch (exception) {
      if (exception.code.contains('permission-denied')) {
        return Left(InsufficientPermissions());
      } else {
        return Left(Unexpected());
      }
    }
  }

  @override
  Future<Either<FriendRequestFailure, FriendRequest>>
  findBySenderAndReceiverIds(UniqueId senderId, UniqueId receiverId) async {
    try {
      final snapshot = await _firestore
          .collection('friendRequests')
          .doc(compositeId([senderId, receiverId]).getOrCrash())
          .get();
      // Both directions share the pair document; only report it when it was
      // sent in the direction asked about.
      if (snapshot.exists &&
          snapshot.data()?['senderId'] == senderId.getOrCrash()) {
        return Right(
          FriendRequestDataTransferObject.fromFirestore(snapshot).toDomain(),
        );
      }
      return Left(NotFound());
    } on FirebaseException catch (exception) {
      if (exception.code.contains('permission-denied')) {
        return Left(InsufficientPermissions());
      } else {
        return Left(Unexpected());
      }
    }
  }

  @override
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
  watchPendingFromCurrentUser() => _watchCurrentUsersRequests(
    status: Pending(),
    keep: (friendRequest, uid) => friendRequest.senderId.getOrCrash() == uid,
  );

  @override
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
  watchReceivedForCurrentUser() => _watchCurrentUsersRequests(
    status: Pending(),
    keep: (friendRequest, uid) => friendRequest.receiverId.getOrCrash() == uid,
  );

  @override
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
  watchFriendsForCurrentUser() =>
      _watchCurrentUsersRequests(status: Accepted(), keep: (_, _) => true);

  /// The signed-in user's own requests with [status], newest first, narrowed
  /// by [keep] to the direction a caller wants.
  ///
  /// Scoped on the server with `participantIds arrayContains <uid>`. The rules
  /// let only the two parties read a request, and Firestore checks a list
  /// query against everything it could return, so the previous listen on the
  /// whole collection, filtered here in Dart, would now be denied, and it
  /// used to download every user's requests.
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
  _watchCurrentUsersRequests({
    required FriendRequestStatus status,
    required bool Function(FriendRequest friendRequest, String uid) keep,
  }) async* {
    final currentUser = _session.current;
    if (currentUser == null) {
      yield left(InsufficientPermissions());
      return;
    }
    yield* _firestore
        .collection('friendRequests')
        .where('participantIds', arrayContains: currentUser.id)
        .where('status', isEqualTo: statusName(status))
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .takeUntil(_session.ended)
        .map(
          (snapShot) => right<FriendRequestFailure, KtList<FriendRequest>>(
            snapShot.docs
                .map(
                  (document) => FriendRequestDataTransferObject.fromFirestore(
                    document,
                  ).toDomain(),
                )
                .where((friendRequest) => keep(friendRequest, currentUser.id))
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith((exception, stackTrace) {
          if (exception is FirebaseException &&
              exception.code.contains('permission-denied')) {
            return left(InsufficientPermissions());
          } else {
            return left(Unexpected());
          }
        });
  }
}
