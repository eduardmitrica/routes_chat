import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/core/composite_id.dart';
import '../../domain/core/value_objects.dart';
import '../../domain/safety/blocks.dart';
import '../../domain/safety/safety_repository_interface.dart';
import '../../domain/shared/user/current_user_session_interface.dart';

/// Blocks in `users/{uid}/blocks/{blockedUid}`, private to the user, and
/// reports in `reports`, which no app can read back.
class FirestoreSafetyRepository implements ISafetyRepository {
  /// The most earlier blocks kept per person. firestore.rules check it.
  static const maxEarlierBlocks = 100;

  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;

  const FirestoreSafetyRepository(this._firestore, this._session);

  CollectionReference<Map<String, dynamic>> _blocks(String uid) =>
      _firestore.collection('users').doc(uid).collection('blocks');

  @override
  Stream<Blocks> watchBlocks() {
    if (_session.current == null) return Stream.value(const Blocks());
    return _blocks(_session.current!.id)
        .snapshots()
        .takeUntil(_session.ended)
        .map(
          (snapshot) => Blocks({
            for (final document in snapshot.docs)
              document.id: recordFrom(document.id, document.data()),
          }),
        )
        .handleError((Object error) {
          debugPrint('Blocks not watched: ${error.runtimeType}');
        });
  }

  /// A stored block as a record. A block just made on this phone has no
  /// server time yet, and counts from now.
  @visibleForTesting
  static BlockRecord recordFrom(String userId, Map<String, dynamic> data) {
    final since = data['blockedSince'];
    return BlockRecord(
      userId: UniqueId.fromUniqueString(userId),
      blockedSince: since is Timestamp
          ? since.toDate()
          : data.containsKey('blockedSince')
          ? DateTime.now()
          : null,
      earlier: [
        for (final block in (data['earlier'] as List?) ?? const [])
          if (block case {'from': Timestamp from, 'to': Timestamp to})
            (from: from.toDate(), to: to.toDate()),
      ],
    );
  }

  @override
  Future<Either<SafetyFailure, Unit>> block(UniqueId userId) =>
      _guard('Blocking', (uid) async {
        final other = userId.getOrCrash();
        final blockRef = _blocks(uid).doc(other);
        final pair = compositeId([
          UniqueId.fromUniqueString(uid),
          userId,
        ]).getOrCrash();
        final friendRequestRef = _firestore
            .collection('friendRequests')
            .doc(pair);
        final (existingBlock, friendRequest) = await (
          blockRef.get(),
          friendRequestRef.get(),
        ).wait;
        final chat = _firestore.collection('chats').doc(pair);
        final batch = _firestore.batch()
          ..delete(chat.collection('reads').doc(uid))
          ..delete(chat.collection('typing').doc(uid));
        // Blocking someone blocked already would move the start of the block
        // later, and show what they sent in between.
        if (existingBlock.data()?['blockedSince'] == null) {
          batch.set(blockRef, {
            'blockedSince': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        // The rules let only the two people delete a request that exists.
        if (friendRequest.exists) batch.delete(friendRequestRef);
        await batch.commit();
      });

  @override
  Future<Either<SafetyFailure, Unit>> unblock(UniqueId userId) =>
      _guard('Unblocking', (uid) async {
        final blockRef = _blocks(uid).doc(userId.getOrCrash());
        await _firestore.runTransaction((transaction) async {
          final data = (await transaction.get(blockRef)).data();
          final since = data?['blockedSince'];
          if (data == null || since is! Timestamp) return;
          final earlier = [
            ...((data['earlier'] as List?) ?? const []),
            {'from': since, 'to': Timestamp.now()},
          ];
          transaction.update(blockRef, {
            'blockedSince': FieldValue.delete(),
            // The oldest go first; what was sent then may show again.
            'earlier': earlier.length > maxEarlierBlocks
                ? earlier.sublist(earlier.length - maxEarlierBlocks)
                : earlier,
          });
        });
      });

  @override
  Future<Either<SafetyFailure, Unit>> report({
    required UniqueId reportedId,
    UniqueId? chatId,
    required ReportReason reason,
    List<ReportedMessage> messages = const [],
  }) => _guard('Reporting', (uid) async {
    await _firestore.collection('reports').add({
      'reporterId': uid,
      'reportedId': reportedId.getOrCrash(),
      'chatId': chatId?.getOrCrash(),
      'reason': reason.storedName,
      'messages': [
        for (final message in messages.take(ReportedMessage.maxPerReport))
          {
            'messageId': message.messageId.getOrCrash(),
            'senderId': message.senderId.getOrCrash(),
            'text': message.text,
            'sentAt': Timestamp.fromDate(message.sentAt),
          },
      ],
      'createdAt': FieldValue.serverTimestamp(),
    });
  });

  Future<Either<SafetyFailure, Unit>> _guard(
    String what,
    Future<void> Function(String uid) action,
  ) async {
    final uid = _session.current?.id;
    if (uid == null) return left(SafetyInsufficientPermissions());
    try {
      await action(uid);
      return right(unit);
    } on FirebaseException catch (exception) {
      debugPrint('$what failed: ${exception.code}');
      return left(
        exception.code.contains('permission-denied')
            ? SafetyInsufficientPermissions()
            : SafetyUnexpected(),
      );
    } on Exception catch (exception) {
      debugPrint('$what failed: ${exception.runtimeType}');
      return left(SafetyUnexpected());
    }
  }
}
