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
  Future<Either<GroupFailure, UniqueId>> create(
    List<UniqueId> invitees, {
    String name = '',
  });

  /// The user joins [groupId], which they were invited to.
  Future<Either<GroupFailure, Unit>> accept(UniqueId groupId);

  /// The user turns down [groupId]. Nobody is told.
  Future<Either<GroupFailure, Unit>> decline(UniqueId groupId);

  /// Invites [people] to [groupId], who can read its past as [history] says.
  /// Everyone's key is replaced before the next message, so they read what
  /// comes next.
  ///
  /// Fails with [GroupTooBig] beyond [Group.maxMembers], and with
  /// [GroupMemberWithoutKeys] if someone has not set up encryption.
  Future<Either<GroupFailure, Unit>> addPeople(
    UniqueId groupId,
    List<UniqueId> people, {
    required HistoryShare history,
  });

  /// An admin takes [userId] out of [groupId], joined or invited. They read
  /// nothing sent after.
  Future<Either<GroupFailure, Unit>> remove(UniqueId groupId, UniqueId userId);

  /// The user leaves [groupId]. When they were its only admin, whoever has
  /// been a member longest becomes one; when they were its last member, the
  /// group is gone.
  Future<Either<GroupFailure, Unit>> leave(UniqueId groupId);

  /// An admin makes [userId] an admin of [groupId], or stops them being one.
  Future<Either<GroupFailure, Unit>> setAdmin(
    UniqueId groupId,
    UniqueId userId, {
    required bool admin,
  });

  /// A member changes [groupId]'s name to [name], and its photo to the
  /// image at [photoPath], made small; [removePhoto] takes the photo away.
  /// Without either, the photo stays as it is.
  Future<Either<GroupFailure, Unit>> setProfile(
    UniqueId groupId, {
    required String name,
    String? photoPath,
    bool removePhoto = false,
  });

  /// An admin decides whether only admins may add people to [groupId].
  Future<Either<GroupFailure, Unit>> setOnlyAdminsAdd(
    UniqueId groupId, {
    required bool onlyAdmins,
  });
}
