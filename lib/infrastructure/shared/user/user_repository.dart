import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kt_dart/collection.dart';

import 'package:routes_chat/domain/shared/user/user_failure.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import 'package:routes_chat/infrastructure/core/chunked.dart';
import 'package:routes_chat/infrastructure/core/firestore_helpers.dart';
import 'package:routes_chat/infrastructure/shared/user/user_data_transfer_object.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/shared/user/current_user_session_interface.dart';
import '../../../domain/shared/user/user.dart';
import '../../../domain/shared/user/user_repository_interface.dart';
import '../../../domain/shared/user/value_objects.dart';

class UserFacade implements IUserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;
  final ICurrentUserSession _session;

  const UserFacade(this._firestore, this._firebaseStorage, this._session);

  @override
  Stream<Either<UserFailure, User>> watch() async* {
    final currentUser = _session.current;
    if (currentUser == null) {
      yield left(InsufficientPermission());
      return;
    }
    yield* _firestore
        .userDocument(currentUser.id)
        .snapshots()
        .takeUntil(_session.ended)
        .map(
          (snapshot) => right<UserFailure, User>(
            UserDataTransferObject.fromFirestore(
              snapshot as DocumentSnapshot<Map<String, dynamic>>,
            ).toDomain(),
          ),
        )
        .onErrorReturnWith((exception, stackTrace) {
          if (exception is FirebaseException &&
              exception.code.contains('permission-denied')) {
            return left(InsufficientPermission());
          } else {
            return left(Unexpected());
          }
        });
  }

  @override
  Future<Either<UserFailure, Unit>> update(User user) async {
    final currentUser = _session.current;
    if (currentUser == null) {
      return Left(InsufficientPermission());
    }
    try {
      final userDocument = _firestore.userDocument(currentUser.id);

      await user.imageUrl.value.fold(
        (failure) async {
          final storageRef = _firebaseStorage
              .ref()
              .child('user_images')
              .child('${userDocument.id}.jpg');
          await storageRef.putFile(File(failure.failedValue)).whenComplete(
            () async {
              final imageUrl = await storageRef.getDownloadURL();
              final userDto = UserDataTransferObject.fromDomain(
                user.copyWith(imageUrl: ImageUrl(imageUrl)),
              );
              await _writeProfile(userDocument, userDto);
            },
          );
        },
        (_) async {
          final userDto = UserDataTransferObject.fromDomain(user);
          await _writeProfile(userDocument, userDto);
        },
      );
      return const Right(unit);
    } on FirebaseException catch (exception) {
      if (exception.code.contains('permission-denied')) {
        return Left(InsufficientPermission());
      } else if (exception.code.contains('not-found')) {
        return Left(UnableToUpdate());
      } else {
        return Left(Unexpected());
      }
    }
  }

  /// Updates the profile and, if its username changed, moves that username's
  /// entry in the `usernames` index in the same transaction: claim the new
  /// name, release the old one. Security rules reject a profile whose username
  /// is not claimed by the same uid, so these writes cannot be separated.
  Future<void> _writeProfile(
    DocumentReference userDocument,
    UserDataTransferObject userDto,
  ) {
    final profile = userDto.toJson();
    final newUsername = profile['username'] as String;

    return _firestore.runTransaction((transaction) async {
      final storedProfile = await transaction.get(userDocument);
      final previousUsername =
          (storedProfile.data() as Map<String, dynamic>?)?['username']
              as String?;
      final isRename = previousUsername != newUsername;

      // Transactions need every read before the first write.
      DocumentSnapshot? previousClaim;
      if (isRename && previousUsername != null) {
        previousClaim = await transaction.get(
          _firestore.usernameDocument(previousUsername),
        );
      }

      transaction.update(userDocument, profile);
      if (isRename) {
        transaction.set(_firestore.usernameDocument(newUsername), {
          'uid': userDocument.id,
        });
        if (previousClaim?.exists ?? false) {
          transaction.delete(previousClaim!.reference);
        }
      }
    });
  }

  @override
  Future<Either<UserFailure, User>> findUserByUsername(
    Username username,
  ) async {
    final userDocsWithGivenEmailAddress = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.getOrCrash())
        .get();

    final queryResult = userDocsWithGivenEmailAddress.docs;
    if (queryResult.isNotEmpty) {
      final firstResult = queryResult.first;
      final user = UserDataTransferObject.fromFirestore(firstResult).toDomain();
      return Right(user);
    } else {
      return Left(UserNotFound());
    }
  }

  @override
  Stream<Either<UserFailure, KtList<User>>> watchUsersWithIds(
    KtList<UniqueId> ids,
  ) async* {
    final uniqueIds = ids.map((id) => id.getOrCrash()).asList().toSet().toList();
    if (uniqueIds.isEmpty) {
      yield right<UserFailure, KtList<User>>(const KtList<User>.empty());
      return;
    }

    // Listen to exactly these profiles rather than the whole collection,
    // which downloaded every user's profile to every signed-in user. Firestore
    // accepts at most 30 values per `in` filter, hence the groups.
    final groups = chunked(uniqueIds, _maximumInFilterValues).map(
      (group) => _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: group)
          .snapshots()
          .takeUntil(_session.ended)
          .map(
            (snapShot) => snapShot.docs
                .map(
                  (document) =>
                      UserDataTransferObject.fromFirestore(document).toDomain(),
                )
                .toList(),
          ),
    );

    yield* CombineLatestStream.list<List<User>>(groups)
        .map((groupsOfUsers) {
          // Ordered by document id, as the whole-collection listen returned.
          final users = groupsOfUsers.expand((group) => group).toList()
            ..sort(
              (first, second) =>
                  first.id.getOrCrash().compareTo(second.id.getOrCrash()),
            );
          return right<UserFailure, KtList<User>>(users.toImmutableList());
        })
        .onErrorReturnWith((exception, stackTrace) {
          if (exception is FirebaseException &&
              exception.code.contains('permission-denied')) {
            return left(InsufficientPermission());
          } else {
            return left(Unexpected());
          }
        });
  }

  /// Firestore's limit on values in a single `in` filter.
  static const _maximumInFilterValues = 30;
}
