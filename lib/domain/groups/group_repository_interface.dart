import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';

import '../core/value_objects.dart';
import 'group.dart';
import 'group_failure.dart';

/// Groups the signed-in user belongs to or is invited to.
abstract interface class IGroupRepository {
  /// The groups the user has joined, their newest messages decrypted, as they
  /// change.
  Stream<Either<GroupFailure, KtList<Group>>> watchJoined();

  /// The groups the user was added to and has not accepted yet, as they
  /// change. Their messages stay unread until the user joins.
  Stream<Either<GroupFailure, KtList<Group>>> watchInvitations();

  /// Starts a group with the user as its only member and admin, and
  /// [invitees] invited. Returns its id.
  ///
  /// Fails with [GroupTooBig] beyond [Group.maxMembers], and with
  /// [GroupMemberWithoutKeys] if someone has not set up encryption.
  Future<Either<GroupFailure, UniqueId>> create(List<UniqueId> invitees);

  /// The user joins [groupId], which they were invited to.
  Future<Either<GroupFailure, Unit>> accept(UniqueId groupId);

  /// The user turns down [groupId]. Nobody is told.
  Future<Either<GroupFailure, Unit>> decline(UniqueId groupId);
}
