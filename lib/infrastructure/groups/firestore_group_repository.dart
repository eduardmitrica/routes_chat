import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart' show SecretKey;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:kt_dart/collection.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/chats/messages/message.dart';
import '../../domain/chats/messages/message_changes.dart';
import '../../domain/chats/messages/value_objects.dart';
import '../../domain/core/value_objects.dart';
import '../../domain/groups/group.dart';
import '../../domain/groups/group_event.dart';
import '../../domain/groups/group_failure.dart';
import '../../domain/groups/group_profile.dart';
import '../../domain/groups/group_repository_interface.dart';
import '../../domain/shared/user/current_user_session_interface.dart';
import '../chats/chat_data_transfer_object.dart';
import '../chats/messages/message_payloads.dart';
import '../encryption/chat_cipher.dart';
import '../encryption/chat_keyring.dart';
import '../chats/messages/image_tools.dart';
import 'group_history_copies.dart';

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
    'onlyAdminsAdd',
    'profile',
    'keyGenerations',
    'currentKeyGeneration',
    'lastMessage',
    'createdAt',
  };

  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;
  final ChatKeyring _keyring;
  final ChatCipher _cipher;
  final ImageTools _images;

  /// A group's history copied for the user, for a last message they cannot
  /// open.
  late final _copies = GroupHistoryCopies(
    _firestore,
    _session,
    _keyring,
    _cipher,
  );

  FirestoreGroupRepository(
    this._firestore,
    this._session,
    this._keyring,
    this._cipher,
    this._images,
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
      final createdAt = data['createdAt'];
      final last = data['lastMessage'];

      if (joined && await _keyring.groupNeedsNewGeneration(data)) {
        // Someone joined or left, or the user reset their keys: a new
        // generation sealed to everyone in the group now is added. Not
        // awaited; the list does not wait.
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

      final profile = await _profileFrom(
        document.reference,
        data,
        generations,
        joined,
      );
      return Group(
        id: UniqueId.fromUniqueString(document.id),
        profile: profile,
        memberIds: _ids(data['memberIds']),
        invitedIds: _ids(data['invitedIds']),
        invitedBy: (data['invitedBy'] as Map).cast<String, String>(),
        adminIds: _ids(data['adminIds']),
        onlyAdminsAdd: data['onlyAdminsAdd'] as bool? ?? false,
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

  /// The group's name and photo, when this phone can open them. Invited
  /// people hold the key too, so an invitation shows the name.
  ///
  /// A member who can open them under an earlier generation than the current
  /// one encrypts them again under it, so someone who joined since, who holds
  /// only the newer keys, sees them too.
  Future<GroupProfile?> _profileFrom(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
    Map<int, KeyGeneration> generations,
    bool joined,
  ) async {
    final stored = data['profile'];
    if (stored == null) return null;
    try {
      final content = EncryptedContent.fromJson(stored);
      final profile = await _cipher.decryptGroupProfile(
        content,
        groupKey: await _keyring.chatKey(
          ref.id,
          content.keyGeneration,
          generations,
        ),
        groupId: ref.id,
      );
      final current = data['currentKeyGeneration'] as int;
      if (joined && content.keyGeneration < current) {
        unawaited(
          _writeProfile(ref, profile, current, generations).catchError(
            (Object error) => debugPrint(
              'Group profile not moved to the current key: '
              '${error.runtimeType}',
            ),
          ),
        );
      }
      return profile;
    } on Exception catch (exception) {
      if (exception is UnreadableCiphertext || exception is FormatException) {
        return null;
      }
      rethrow;
    }
  }

  /// [profile] encrypted under generation [generation], as stored.
  Future<Map<String, Object>> _encryptedProfile(
    String groupId,
    GroupProfile profile,
    int generation,
    Map<int, KeyGeneration> generations,
  ) async => (await _cipher.encryptGroupProfile(
    profile,
    groupKey: await _keyring.chatKey(groupId, generation, generations),
    groupId: groupId,
    keyGeneration: generation,
  )).toJson();

  Future<void> _writeProfile(
    DocumentReference<Map<String, dynamic>> ref,
    GroupProfile profile,
    int generation,
    Map<int, KeyGeneration> generations,
  ) async => ref.update({
    'profile': await _encryptedProfile(
      ref.id,
      profile,
      generation,
      generations,
    ),
  });

  /// Adds to [batch] the event of [type], caused by [byId], in the messages of
  /// [ref]. It is written with the change it describes, which the rules check
  /// it against.
  static void _event(
    WriteBatch batch,
    DocumentReference<Map<String, dynamic>> ref,
    String byId,
    GroupEventType type, {
    String? subjectId,
    bool? on,
  }) => batch.set(ref.collection('messages').doc(UniqueId().getOrCrash()), {
    'kind': 'event',
    'type': type.stored,
    'senderId': byId,
    'subjectId': ?subjectId,
    'on': ?on,
    'serverTimeStamp': FieldValue.serverTimestamp(),
  });

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
        final copied = await _copies.payloadOf(
          groupId,
          stored.id!,
          stored.senderId,
        );
        text = copied?.summary ?? ChatCipher.unreadableMessageText;
        readable = copied != null;
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
  Future<Either<GroupFailure, UniqueId>> create(
    List<UniqueId> invitees, {
    String name = '',
  }) async {
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
      _keyring.remember(groupId, firstGeneration);
      final ref = _groups.doc(groupId);
      final profileName = groupNameOf(name) ?? '';
      final batch = _firestore.batch()
        ..set(ref, {
          'memberIds': [userId],
          'invitedIds': invited.toList(),
          'invitedBy': {for (final id in invited) id: userId},
          'adminIds': [userId],
          'keyGenerations': const KeyGenerationsConverter().toJson({
            firstGeneration.number: firstGeneration.stored,
          }),
          'currentKeyGeneration': firstGeneration.number,
          if (profileName.isNotEmpty)
            'profile': (await _cipher.encryptGroupProfile(
              GroupProfile(name: profileName),
              groupKey: firstGeneration.key,
              groupId: groupId,
              keyGeneration: firstGeneration.number,
            )).toJson(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      _event(batch, ref, userId, GroupEventType.created);
      await batch.commit();
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
      final ref = _groups.doc(groupId.getOrCrash());
      final batch = _firestore.batch()
        ..update(ref, <Object, Object?>{
          if (join) 'memberIds': FieldValue.arrayUnion([userId]),
          'invitedIds': FieldValue.arrayRemove([userId]),
          FieldPath(['invitedBy', userId]): FieldValue.delete(),
        });
      // Turning a group down tells nobody, so only joining is an event.
      if (join) _event(batch, ref, userId, GroupEventType.joined);
      await batch.commit();
      return right(unit);
    } on Exception catch (exception) {
      return left(_failureFor(exception));
    }
  }

  @override
  Future<Either<GroupFailure, Unit>> addPeople(
    UniqueId groupId,
    List<UniqueId> people, {
    required HistoryShare history,
  }) => _forMember(groupId, (userId, ref, data) async {
    final everyone = {..._ids(data['memberIds']), ..._ids(data['invitedIds'])};
    final added = {
      for (final person in people) person.getOrCrash(),
    }.difference(everyone);
    if (added.isEmpty) return right(unit);
    if (everyone.length + added.length > Group.maxMembers) {
      return left(const GroupTooBig());
    }
    final generations = KeyGeneration.mapFromJson(data['keyGenerations']);
    final window = history.window;
    final since = window == null ? null : DateTime.now().subtract(window);
    // One person a write, as the rules require, each with their history in
    // the same write: once invited, a friend's phone joins at once, and
    // should find it there.
    for (final person in added) {
      // Also fails for someone without keys, who cannot be added: the next
      // key could not be sealed to them.
      final shared = await _keyring.historyFor(
        groupId.getOrCrash(),
        person,
        history == HistoryShare.all ? generations : const {},
      );
      final historyKey = since == null
          ? null
          : await _keyring.newHistoryKey(groupId.getOrCrash(), person);
      final batch = _firestore.batch();
      if (shared.isNotEmpty) {
        batch.set(ref.collection('sharedKeys').doc(person), {
          'sharedBy': userId,
          'generations': shared,
        });
      }
      if (historyKey != null && since != null) {
        batch.set(ref.collection('history').doc(person), {
          'sharedBy': userId,
          'since': Timestamp.fromDate(since),
          'key': historyKey.$2,
        });
      }
      batch.update(ref, {
        'invitedIds': FieldValue.arrayUnion([person]),
        FieldPath(['invitedBy', person]): userId,
      });
      _event(batch, ref, userId, GroupEventType.added, subjectId: person);
      await batch.commit();
      if (historyKey != null && since != null) {
        await _copyHistory(ref, person, historyKey.$1, since, generations);
      }
    }
    return right(unit);
  });

  /// How many copies go in one batch; Firestore takes at most 500 writes.
  static const _copiesPerBatch = 400;

  /// Copies every message of the group sent since [since] that the user can
  /// read, encrypted again under [key] for [person] alone, into
  /// `history/{person}/messages`. A message the user cannot read, or one
  /// that was deleted, is not copied. Each copy keeps its message's id,
  /// sender and time, which the rules check against the message.
  ///
  /// A copy that fails is left out: the person added reads that message as
  /// unreadable, and nobody else is affected.
  Future<void> _copyHistory(
    DocumentReference<Map<String, dynamic>> ref,
    String person,
    SecretKey key,
    DateTime since,
    Map<int, KeyGeneration> generations,
  ) async {
    final groupId = ref.id;
    try {
      final originals = await ref
          .collection('messages')
          .where(
            'serverTimeStamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(since),
          )
          .orderBy('serverTimeStamp')
          .get();
      var batch = _firestore.batch();
      var inBatch = 0;
      for (final original in originals.docs) {
        final data = original.data();
        final content = data['content'];
        final sentAt = data['serverTimeStamp'];
        final senderId = data['senderId'];
        if (content == null || sentAt is! Timestamp || senderId is! String) {
          continue;
        }
        final MessagePayload payload;
        try {
          final encrypted = EncryptedContent.fromJson(content);
          payload = await _cipher.decrypt(
            encrypted,
            chatKey: await _keyring.chatKey(
              groupId,
              encrypted.keyGeneration,
              generations,
            ),
            chatId: groupId,
            messageId: original.id,
            senderId: senderId,
          );
        } on Exception catch (exception) {
          if (exception is UnreadableCiphertext ||
              exception is FormatException) {
            continue;
          }
          rethrow;
        }
        batch.set(
          ref
              .collection('history')
              .doc(person)
              .collection('messages')
              .doc(original.id),
          {
            'senderId': senderId,
            'imageUrls': const <String>[],
            'reactions': const <String>[],
            'isEdited': data['isEdited'] ?? false,
            'serverTimeStamp': sentAt,
            'content': (await _cipher.encrypt(
              payload,
              chatKey: key,
              chatId: groupId,
              keyGeneration: ChatKeyring.historyGeneration,
              messageId: original.id,
              senderId: senderId,
            )).toJson(),
          },
        );
        if (++inBatch == _copiesPerBatch) {
          await batch.commit();
          batch = _firestore.batch();
          inBatch = 0;
        }
      }
      if (inBatch > 0) await batch.commit();
    } on Exception catch (exception) {
      // The invitation stands; only the copied history is incomplete.
      debugPrint('Group history not copied: ${exception.runtimeType}');
    }
  }

  @override
  Future<Either<GroupFailure, Unit>> remove(
    UniqueId groupId,
    UniqueId userId,
  ) => _forMember(groupId, (me, ref, data) async {
    final id = userId.getOrCrash();
    final batch = _firestore.batch()
      ..update(ref, {
        'memberIds': FieldValue.arrayRemove([id]),
        'invitedIds': FieldValue.arrayRemove([id]),
        'adminIds': FieldValue.arrayRemove([id]),
        FieldPath(['invitedBy', id]): FieldValue.delete(),
      });
    _event(batch, ref, me, GroupEventType.removed, subjectId: id);
    await batch.commit();
    return right(unit);
  });

  @override
  Future<Either<GroupFailure, Unit>> leave(UniqueId groupId) =>
      _forMember(groupId, (me, ref, data) async {
        final members = _ids(data['memberIds']);
        if (members.length == 1) {
          // The last member: the group goes with them, and the function
          // cleanUpDeletedGroup deletes everything it kept.
          await ref.delete();
          return right(unit);
        }
        final group = Group(
          id: groupId,
          memberIds: members,
          invitedIds: _ids(data['invitedIds']),
          invitedBy: const {},
          adminIds: _ids(data['adminIds']),
        );
        final batch = _firestore.batch()
          ..update(ref, {
            'memberIds': FieldValue.arrayRemove([me]),
            'adminIds': group.adminsAfterLeaving(me),
          });
        _event(batch, ref, me, GroupEventType.left);
        await batch.commit();
        return right(unit);
      });

  @override
  Future<Either<GroupFailure, Unit>> setAdmin(
    UniqueId groupId,
    UniqueId userId, {
    required bool admin,
  }) => _forMember(groupId, (me, ref, data) async {
    final id = userId.getOrCrash();
    final batch = _firestore.batch()
      ..update(ref, {
        'adminIds': admin
            ? FieldValue.arrayUnion([id])
            : FieldValue.arrayRemove([id]),
      });
    _event(
      batch,
      ref,
      me,
      admin ? GroupEventType.adminAdded : GroupEventType.adminRemoved,
      subjectId: id,
    );
    await batch.commit();
    return right(unit);
  });

  @override
  Future<Either<GroupFailure, Unit>> setOnlyAdminsAdd(
    UniqueId groupId, {
    required bool onlyAdmins,
  }) => _forMember(groupId, (me, ref, data) async {
    final batch = _firestore.batch()
      ..update(ref, {'onlyAdminsAdd': onlyAdmins});
    _event(batch, ref, me, GroupEventType.onlyAdminsAdd, on: onlyAdmins);
    await batch.commit();
    return right(unit);
  });

  /// The most a group photo may take, after making it small.
  static const maxPhotoBytes = 45000;

  @override
  Future<Either<GroupFailure, Unit>> setProfile(
    UniqueId groupId, {
    required String name,
    String? photoPath,
    bool removePhoto = false,
  }) => _forMember(groupId, (me, ref, data) async {
    final newName = groupNameOf(name);
    if (newName == null) return left(const GroupUnexpected());
    final generations = KeyGeneration.mapFromJson(data['keyGenerations']);
    final current = data['currentKeyGeneration'] as int;
    final before =
        await _profileFrom(ref, data, generations, false) ??
        const GroupProfile();
    final photo = removePhoto
        ? null
        : photoPath != null
        ? await _smallPhoto(photoPath)
        : before.photo;
    final after = GroupProfile(name: newName, photo: photo);
    final renamed = after.name != before.name;
    final photoChanged = removePhoto ? before.photo != null : photoPath != null;
    if (!renamed && !photoChanged) return right(unit);
    final batch = _firestore.batch()
      ..update(ref, {
        'profile': await _encryptedProfile(ref.id, after, current, generations),
      });
    if (renamed) _event(batch, ref, me, GroupEventType.renamed);
    if (photoChanged) _event(batch, ref, me, GroupEventType.photoChanged);
    await batch.commit();
    return right(unit);
  });

  /// The image at [path] as a small JPEG for a group photo.
  Future<List<int>> _smallPhoto(String path) async {
    final original = await File(path).readAsBytes();
    for (final quality in [80, 65, 50]) {
      final small = await _images.toJpeg(
        original,
        side: GroupProfile.photoSide,
        quality: quality,
      );
      if (small.length <= maxPhotoBytes) return small;
    }
    throw const FormatException('The photo is too large even when small');
  }

  /// Runs [change] on [groupId] as it is now, for the signed-in user. What
  /// they may change is the rules' to decide; a refusal is
  /// [GroupInsufficientPermissions].
  Future<Either<GroupFailure, Unit>> _forMember(
    UniqueId groupId,
    Future<Either<GroupFailure, Unit>> Function(
      String userId,
      DocumentReference<Map<String, dynamic>> ref,
      Map<String, dynamic> data,
    )
    change,
  ) async {
    final userId = _session.current?.id;
    if (userId == null) return left(const GroupInsufficientPermissions());
    try {
      final ref = _groups.doc(groupId.getOrCrash());
      final data = (await ref.get()).data();
      if (data == null) return left(const GroupInsufficientPermissions());
      return await change(userId, ref, data);
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
