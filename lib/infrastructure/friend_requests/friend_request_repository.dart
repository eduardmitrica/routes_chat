import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/failures.dart';
import 'package:routes_chat/domain/friend_requests/friend_request.dart';
import 'package:routes_chat/domain/friend_requests/friend_requests_repository_interface.dart';
import 'package:routes_chat/infrastructure/core/firestore_helpers.dart';
import 'package:routes_chat/infrastructure/friend_requests/friend_request_data_transfer_object.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/friend_requests/value_objects.dart';

@LazySingleton(as: IFriendRequestsRepository)
class FriendRequestRepository implements IFriendRequestsRepository {
  final FirebaseFirestore _firestore;

  const FriendRequestRepository(this._firestore);

  @override
  Future<Either<FriendRequestFailure, Unit>> create(
      FriendRequest friendRequest) async {
    final friendRequestDto =
        FriendRequestDataTransferObject.fromDomain(friendRequest);

    final friendRequestRef = _firestore
        .collection('friendRequests')
        .doc(friendRequest.id.getOrCrash());

    final matchingPendingFriendRequestRef = _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: friendRequestDto.senderId)
        .where('receiverId', isEqualTo: friendRequestDto.receiverId);
    final matchingReceivingFriendRequestRef = _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: friendRequestDto.receiverId)
        .where('receiverId', isEqualTo: friendRequestDto.senderId);
    try {
      await _firestore.runTransaction((transaction) async {
        final pendingFriendsRequestsMatchResult =
            await matchingPendingFriendRequestRef.get();
        final receivingFriendsRequestsMatchResult =
            await matchingReceivingFriendRequestRef.get();

        DocumentReference? foundFriendRequestRef;
        if (pendingFriendsRequestsMatchResult.docs.isNotEmpty) {
          foundFriendRequestRef =
              pendingFriendsRequestsMatchResult.docs.first.reference;
        }
        if (receivingFriendsRequestsMatchResult.docs.isNotEmpty) {
          foundFriendRequestRef =
              receivingFriendsRequestsMatchResult.docs.first.reference;
        }

        if (foundFriendRequestRef == null) {
          transaction.set(friendRequestRef, friendRequestDto.toJson());
        }
      });
      return const Right(unit);
    } on PlatformException catch (exception) {
      if (exception.message!.contains('PERMISSION_DENIED')) {
        return Left(InsufficientPermissions());
      } else {
        return Left(Unexpected());
      }
    }
  }

  @override
  Future<Either<FriendRequestFailure, Unit>> delete(
      FriendRequest friendRequest) async {
    try {
      await _firestore
          .collection('friendRequests')
          .doc(friendRequest.id.getOrCrash())
          .delete();
      return const Right(unit);
    } on PlatformException catch (exception) {
      if (exception.message!.contains('PERMISSION_DENIED')) {
        return Left(InsufficientPermissions());
      } else {
        return Left(Unexpected());
      }
    }
  }

  @override
  Future<Either<FriendRequestFailure, Unit>> update(
      FriendRequest friendRequest) async {
    try {
      await _firestore
          .collection('friendRequests')
          .doc(friendRequest.id.getOrCrash())
          .update(FriendRequestDataTransferObject.fromDomain(friendRequest)
              .toJson());
      return const Right(unit);
    } on PlatformException catch (exception) {
      if (exception.message!.contains('PERMISSION_DENIED')) {
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
      final friendRequestQueryResult = await _firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: senderId.getOrCrash())
          .where('receiverId', isEqualTo: receiverId.getOrCrash())
          .get();

      final docs = friendRequestQueryResult.docs;
      if (docs.isNotEmpty) {
        return Right(FriendRequestDataTransferObject.fromFirestore(docs.first)
            .toDomain());
      } else {
        return Left(NotFound());
      }
    } on PlatformException catch (exception) {
      if (exception.message!.contains('PERMISSION_DENIED')) {
        return Left(InsufficientPermissions());
      } else {
        return Left(Unexpected());
      }
    }
  }

  @override
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
      watchPendingFromCurrentUser() async* {
    final userDocument = await _firestore.userDocument;
    yield* _firestore
        .collection('friendRequests')
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (snapShot) => snapShot.docs.map(
            (document) =>
                FriendRequestDataTransferObject.fromFirestore(document)
                    .toDomain(),
          ),
        )
        .map(
          (friendRequests) =>
              right<FriendRequestFailure, KtList<FriendRequest>>(
            friendRequests
                .where((friendRequest) =>
                    friendRequest.senderId.getOrCrash() == userDocument.id &&
                    friendRequest.status.getOrCrash().runtimeType ==
                        Pending().runtimeType)
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith((exception, stackTrace) {
      if (exception is PlatformException &&
          exception.message!.contains('PERMISSION_DENIED')) {
        return left(InsufficientPermissions());
      } else {
        return left(Unexpected());
      }
    });
  }

  @override
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
      watchReceivedForCurrentUser() async* {
    final userDocument = await _firestore.userDocument;
    yield* _firestore
        .collection('friendRequests')
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (snapShot) => snapShot.docs.map(
            (document) =>
                FriendRequestDataTransferObject.fromFirestore(document)
                    .toDomain(),
          ),
        )
        .map(
          (friendRequests) =>
              right<FriendRequestFailure, KtList<FriendRequest>>(
            friendRequests
                .where((friendRequest) =>
                    friendRequest.receiverId.getOrCrash() == userDocument.id &&
                    friendRequest.status.getOrCrash().runtimeType ==
                        Pending().runtimeType)
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith((exception, stackTrace) {
      if (exception is PlatformException &&
          exception.message!.contains('PERMISSION_DENIED')) {
        return left(InsufficientPermissions());
      } else {
        return left(Unexpected());
      }
    });
  }

  @override
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
      watchFriendsForCurrentUser() async* {
    final userDocument = await _firestore.userDocument;
    yield* _firestore
        .collection('friendRequests')
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (snapShot) => snapShot.docs.map(
            (document) =>
                FriendRequestDataTransferObject.fromFirestore(document)
                    .toDomain(),
          ),
        )
        .map(
          (friendRequests) =>
              right<FriendRequestFailure, KtList<FriendRequest>>(
            friendRequests
                .where((friendRequest) =>
                    (friendRequest.senderId.getOrCrash() == userDocument.id ||
                        friendRequest.receiverId.getOrCrash() ==
                            userDocument.id) &&
                    friendRequest.status.getOrCrash().runtimeType ==
                        Accepted().runtimeType)
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith((exception, stackTrace) {
      if (exception is PlatformException &&
          exception.message!.contains('PERMISSION_DENIED')) {
        return left(InsufficientPermissions());
      } else {
        return left(Unexpected());
      }
    });
  }
}
