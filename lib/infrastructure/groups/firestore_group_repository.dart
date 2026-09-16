import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:kt_dart/collection.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/chats/messages/message.dart';
import '../../domain/chats/messages/message_changes.dart';
import '../../domain/chats/messages/value_objects.dart';
import '../../domain/core/value_objects.dart';
import '../../domain/groups/group.dart';
import '../../domain/groups/group_failure.dart';
import '../../domain/groups/group_repository_interface.dart';
import '../../domain/shared/user/current_user_session_interface.dart';
import '../chats/chat_data_transfer_object.dart';
import '../chats/messages/message_payloads.dart';
import '../encryption/chat_cipher.dart';
import '../encryption/chat_keyring.dart';

/// Groups in `groups/{groupId}`. See docs/e2ee.md and firestore.rules.
///
/// A group document holds who has joined (`memberIds`), who is invited
/// (`invitedIds`, and `invitedBy` for who added each), the admins, every
/// generation of the group's key sealed to everyone in it, and the encrypted
/// last message. Its messages live under it as a one-to-one chat's do, so
/// sending and reading them is the same code.
class FirestoreGroupRepository implements IGroupRepository {
  static const collection = 'groups';

  /// The fields a group document holds; firestore.rules lists the same, and a
  /// test keeps the two equal.
  static const fields = {
    'memberIds',
    'invitedIds',
    'invitedBy',
    'adminIds',
    'keyGenerations',
    'currentKeyGeneration',
    'lastMessage',
    'createdAt',
  };

  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;
  final ChatKeyring _keyring;
  final ChatCipher _cipher;

  const FirestoreGroupRepository(
    this._firestore,
    this._session,
    this._keyring,
    this._cipher,
  );

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection(collection);

  @override
  Stream<Either<GroupFailure, KtList<Group>>> watchJoined() =>
      _watch('memberIds', joined: true);

  @override
  Stream<Either<GroupFailure, KtList<Group>>> watchInvitations() =>
      _watch('invitedIds', joined: false);

  /// The groups whose [field] holds the user. The rules only allow a query
  /// scoped this way.
  Stream<Either<GroupFailure, KtList<Group>>> _watch(
    String field, {
    required bool joined,
  }) async* {
    final userId = _session.current?.id;
    if (userId == null) {
      yield left(const GroupInsufficientPermissions());
      return;
    }
    yield* _groups
        .where(field, arrayContains: userId)
        .snapshots()
        .takeUntil(_session.ended)
        .asyncMap(
          (snapshot) async => (await Future.wait(
            snapshot.docs.map((document) => _groupFrom(document, joined)),
          )).nonNulls,
        )
        .map(
          (groups) =>
              right<GroupFailure, KtList<Group>>(groups.toImmutableList()),
        )
        .onErrorReturnWith((error, _) => left(_failureFor(error)));
  }

  /// [document] as a group. Its last message is decrypted only for a group
  /// the user has joined: an invitation shows no messages.
  ///
  /// Null for a document not in the stored format, which is left out rather
  /// than hiding every group.
  Future<Group?> _groupFrom(
    DocumentSnapshot<Map<String, dynamic>> document,
    bool joined,
  ) async {
    final data = document.data();
    if (data == null) return null;
    try {
      final generations = KeyGeneration.mapFromJson(data['keyGenerations']);
      final current = data['currentKeyGeneration'] as int;
      final createdAt = data['createdAt'];
      final last = data['lastMessage'];

      if (joined && await _keyring.needsNewGeneration(generations, current)) {
        // The user reset their keys: a generation they can open is added,
        // as for a one-to-one chat. Not awaited; the list does not wait.
        unawaited(
          _keyring
              .addGenerationIfNeeded(document.id)
              .catchError(
                (Object error) => debugPrint(
                  'Group key generation not added: ${error.runtimeType}',
                ),
              ),
        );
      }

      return Group(
        id: UniqueId.fromUniqueString(document.id),
        memberIds: _ids(data['memberIds']),
        invitedIds: _ids(data['invitedIds']),
        invitedBy: (data['invitedBy'] as Map).cast<String, String>(),
        adminIds: _ids(data['adminIds']),
        createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
        lastMessage: joined && last is Map
            ? await _lastMessage(
                document.id,
                last.cast<String, dynamic>(),
                generations,
              )
            : null,
      );
    } on Object catch (error) {
      if (error is! TypeError && error is! FormatException) rethrow;
      debugPrint('Group left out, not in the stored format');
      return null;
    }
  }

  static List<String> _ids(Object? json) => (json as List).cast<String>();

  /// The stored last message, decrypted for the preview. One that does not
  /// decrypt reads [ChatCipher.unreadableMessageText].
  Future<Message> _lastMessage(
    String groupId,
    Map<String, dynamic> json,
    Map<int, KeyGeneration> generations,
  ) async {
    final stored = const MessageDataTransferObjectConverter().fromJson(json);
    var text = deletedMessageText;
    var readable = true;
    if (!stored.isDeleted) {
      try {
        final content = stored.encryptedContent;
        text = (await _cipher.decrypt(
          content,
          chatKey: await _keyring.chatKey(
            groupId,
            content.keyGeneration,
            generations,
          ),
          chatId: groupId,
          messageId: stored.id!,
          senderId: stored.senderId,
        )).summary;
      } on Exception catch (exception) {
        if (exception is! UnreadableCiphertext &&
            exception is! FormatException) {
          rethrow;
        }
        text = ChatCipher.unreadableMessageText;
        readable = false;
      }
    }
    return Message(
      id: UniqueId.fromUniqueString(stored.id!),
      senderId: UniqueId.fromUniqueString(stored.senderId),
      content: Content(text),
      imageUrls: const KtList.empty(),
      isEdited: stored.isEdited,
      lastUpdatedAt: stored.timeStamp,
      isReadable: readable,
      isDeleted: stored.isDeleted,
      keyGeneration: stored.content?.keyGeneration ?? 1,
    );
  }

  @override
  Future<Either<GroupFailure, UniqueId>> create(List<UniqueId> invitees) async {
    final userId = _session.current?.id;
    if (userId == null) return left(const GroupInsufficientPermissions());
    final invited = {for (final invitee in invitees) invitee.getOrCrash()}
      ..remove(userId);
    if (invited.isEmpty) return left(const GroupUnexpected());
    if (invited.length + 1 > Group.maxMembers) {
      return left(const GroupTooBig());
    }
    try {
      final groupId = newGroupId().getOrCrash();
      final firstGeneration = await _keyring.firstGeneration(groupId, [
        userId,
        ...invited,
      ]);
      await _groups.doc(groupId).set({
        'memberIds': [userId],
        'invitedIds': invited.toList(),
        'invitedBy': {for (final id in invited) id: userId},
        'adminIds': [userId],
        'keyGenerations': const KeyGenerationsConverter().toJson({
          firstGeneration.number: firstGeneration.stored,
        }),
        'currentKeyGeneration': firstGeneration.number,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _keyring.remember(groupId, firstGeneration);
      return right(UniqueId.fromUniqueString(groupId));
    } on Exception catch (exception) {
      return left(_failureFor(exception));
    }
  }

  @override
  Future<Either<GroupFailure, Unit>> accept(UniqueId groupId) =>
      _answer(groupId, join: true);

  @override
  Future<Either<GroupFailure, Unit>> decline(UniqueId groupId) =>
      _answer(groupId, join: false);

  /// Leaves the invited and, when [join], joins the members. The rules allow
  /// only this change, and only to the invited person themselves.
  Future<Either<GroupFailure, Unit>> _answer(
    UniqueId groupId, {
    required bool join,
  }) async {
    final userId = _session.current?.id;
    if (userId == null) return left(const GroupInsufficientPermissions());
    try {
      await _groups.doc(groupId.getOrCrash()).update(<Object, Object?>{
        if (join) 'memberIds': FieldValue.arrayUnion([userId]),
        'invitedIds': FieldValue.arrayRemove([userId]),
        FieldPath(['invitedBy', userId]): FieldValue.delete(),
      });
      return right(unit);
    } on Exception catch (exception) {
      return left(_failureFor(exception));
    }
  }

  static GroupFailure _failureFor(Object error) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return const GroupInsufficientPermissions();
    }
    if (error is ParticipantWithoutKeys) {
      return GroupMemberWithoutKeys(error.userId);
    }
    // The type only: nothing about who is in a group belongs in the log.
    debugPrint('Groups failed: ${error.runtimeType}');
    return const GroupUnexpected();
  }
}
