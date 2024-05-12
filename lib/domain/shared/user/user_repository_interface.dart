import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/domain/shared/user/user_failure.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';

import '../../core/value_objects.dart';

abstract interface class IUserRepository {
  Stream<Either<UserFailure, User>> watch();
  Stream<Either<UserFailure, KtList<User>>> watchUsersWithIds(KtList<UniqueId> ids);
  Future<Either<UserFailure, Unit>> update(User user);
  Future<Either<UserFailure, User>> findUserByUsername(Username username);
}