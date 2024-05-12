import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/collection.dart';

import 'package:routes_chat/domain/shared/user/user_failure.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import 'package:routes_chat/infrastructure/core/firestore_helpers.dart';
import 'package:routes_chat/infrastructure/shared/user/user_data_transfer_object.dart';
import 'package:rxdart/rxdart.dart';

import '../../../domain/shared/user/user.dart';
import '../../../domain/shared/user/user_repository_interface.dart';
import '../../../domain/shared/user/value_objects.dart';



@LazySingleton(as: IUserRepository)
class UserFacade implements IUserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;

  const UserFacade(this._firestore, this._firebaseStorage);

  @override
  Stream<Either<UserFailure, User>> watch() async* {
    final userDocument = await _firestore.userDocument;
    yield* userDocument
        .snapshots()
        .map((snapshot) => right<UserFailure, User>(
            UserDataTransferObject.fromFirestore(
                    snapshot as DocumentSnapshot<Map<String, dynamic>>)
                .toDomain()))
        .onErrorReturnWith((exception, stackTrace) {
      if (exception is PlatformException &&
          exception.message!.contains('PERMISSION_DENIED')) {
        return left(InsufficientPermission());
      } else {
        return left(Unexpected());
      }
    });
  }

  @override
  Future<Either<UserFailure, Unit>> update(User user) async {
    try {
      final userDocument = await _firestore.userDocument;

      await user.imageUrl.value.fold((failure) async {
        final storageRef = _firebaseStorage
            .ref()
            .child('user_images')
            .child('${userDocument.id}.jpg');
        await storageRef
            .putFile(File(failure.failedValue))
            .whenComplete(() async {
          final imageUrl = await storageRef.getDownloadURL();
          final userDto = UserDataTransferObject.fromDomain(
            user.copyWith(
              imageUrl: ImageUrl(imageUrl),
            ),
          );
          await userDocument.update(userDto.toJson());
        });
      }, (_) async {
        final userDto = UserDataTransferObject.fromDomain(user);
        await userDocument.update(userDto.toJson());
      });
      return const Right(unit);
    } on PlatformException catch (exception) {
      if (exception.message!.contains('PERMISSION_DENIED')) {
        return Left(InsufficientPermission());
      } else if (exception.message!.contains('NOT_FOUND')) {
        return Left(UnableToUpdate());
      } else {
        return Left(Unexpected());
      }
    }
  }

  @override
  Future<Either<UserFailure, User>> findUserByUsername(
      Username username) async {
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
      KtList<UniqueId> ids) async* {
    final idsValues = ids.map((id) => id.getOrCrash());
    yield* _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapShot) => snapShot.docs.map(
            (document) =>
                UserDataTransferObject.fromFirestore(document).toDomain(),
          ),
        )
        .map(
          (users) => right<UserFailure, KtList<User>>(
            users
                .where((user) => idsValues.contains(user.id.getOrCrash()))
                .toImmutableList(),
          ),
        )
        .onErrorReturnWith((exception, stackTrace) {
      if (exception is PlatformException &&
          exception.message!.contains('PERMISSION_DENIED')) {
        return left(InsufficientPermission());
      } else {
        return left(Unexpected());
      }
    });
  }
}
