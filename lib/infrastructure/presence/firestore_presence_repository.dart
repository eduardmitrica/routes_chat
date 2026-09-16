import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/core/value_objects.dart';
import '../../domain/presence/presence.dart';
import '../../domain/presence/presence_repository_interface.dart';
import '../../domain/shared/user/current_user_session_interface.dart';
import '../core/firestore_helpers.dart';

/// Typing in `chats/{chatId}/typing/{uid}`, how far each person has read in
/// `chats/{chatId}/reads/{uid}`, and presence in `presence/{uid}`. A group
/// keeps its typing and reads the same way under `groups/{groupId}`.
///
/// firestore.rules let a chat's participants and a group's members see who
/// types and reads in it, and only friends see each other's presence. Typing
/// and presence hold a
/// server time and nothing else a client could use to say more than "now". A
/// read marker also names the message read, with its send time, never what
/// it says.
class FirestorePresenceRepository implements IPresenceRepository {
  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;

  const FirestorePresenceRepository(this._firestore, this._session);

  DocumentReference<Map<String, dynamic>> _typing(String chatId, String uid) =>
      _firestore.conversationDocument(chatId).collection('typing').doc(uid);

  DocumentReference<Map<String, dynamic>> _presence(String uid) =>
      _firestore.collection('presence').doc(uid);

  DocumentReference<Map<String, dynamic>> _readMarker(
    String chatId,
    String uid,
  ) => _firestore.conversationDocument(chatId).collection('reads').doc(uid);

  /// Runs [write] for the signed-in user, logging only the kind of failure.
  Future<void> _bestEffort(
    String what,
    Future<void> Function(String uid) write,
  ) async {
    final uid = _session.current?.id;
    if (uid == null) return;
    try {
      await write(uid);
    } on Exception catch (exception) {
      debugPrint('$what failed: ${exception.runtimeType}');
    }
  }

  @override
  Future<void> startTyping(UniqueId chatId) => _bestEffort(
    'Typing',
    (uid) => _typing(
      chatId.getOrCrash(),
      uid,
    ).set({'typingAt': FieldValue.serverTimestamp()}),
  );

  @override
  Future<void> stopTyping(UniqueId chatId) => _bestEffort(
    'Stopping typing',
    (uid) => _typing(chatId.getOrCrash(), uid).delete(),
  );

  @override
  Stream<DateTime?> watchTyping(UniqueId chatId, UniqueId userId) {
    if (_session.current == null) return const Stream.empty();
    return _typing(chatId.getOrCrash(), userId.getOrCrash())
        .snapshots()
        .takeUntil(_session.ended)
        // Our own pending write has no server time yet.
        .where((snapshot) => !snapshot.metadata.hasPendingWrites)
        .map(
          (snapshot) => (snapshot.data()?['typingAt'] as Timestamp?)?.toDate(),
        )
        .handleError((Object error) {
          debugPrint('Typing not watched: ${error.runtimeType}');
        });
  }

  @override
  Future<void> reportOnline() => _bestEffort(
    'Reporting online',
    (uid) => _presence(
      uid,
    ).set({'state': 'online', 'lastSeenAt': FieldValue.serverTimestamp()}),
  );

  @override
  Future<void> reportOffline() => _bestEffort(
    'Reporting offline',
    (uid) => _presence(
      uid,
    ).set({'state': 'offline', 'lastSeenAt': FieldValue.serverTimestamp()}),
  );

  @override
  Future<void> clearPresence(String userId) async {
    try {
      await _presence(userId).delete();
    } on Exception catch (exception) {
      debugPrint('Clearing presence failed: ${exception.runtimeType}');
    }
  }

  @override
  Stream<Presence?> watchPresence(UniqueId userId) {
    if (_session.current == null) return const Stream.empty();
    return _presence(userId.getOrCrash())
        .snapshots()
        .takeUntil(_session.ended)
        .where((snapshot) => !snapshot.metadata.hasPendingWrites)
        .map((snapshot) {
          final data = snapshot.data();
          final lastSeenAt = data?['lastSeenAt'];
          if (data == null || lastSeenAt is! Timestamp) return null;
          return Presence(
            online: data['state'] == 'online',
            lastSeenAt: lastSeenAt.toDate(),
          );
        })
        // Not friends, or signed out: show nothing rather than fail.
        .handleError((Object error) {
          debugPrint('Presence not watched: ${error.runtimeType}');
        });
  }

  @override
  Future<void> markRead(UniqueId chatId, UniqueId messageId) =>
      _bestEffort('Marking read', (uid) async {
        final chat = chatId.getOrCrash();
        final id = messageId.getOrCrash();
        // The rules require the message's own send time, to the microsecond.
        final message = await _firestore
            .conversationDocument(chat)
            .collection('messages')
            .doc(id)
            .get();
        final sentAt = message.data()?['serverTimeStamp'];
        if (sentAt is! Timestamp) return;
        await _readMarker(chat, uid).set({
          'messageId': id,
          'messageSentAt': sentAt,
          'readAt': FieldValue.serverTimestamp(),
        });
      });

  @override
  Stream<DateTime?> watchReadUpTo(UniqueId chatId, UniqueId userId) {
    if (_session.current == null) return const Stream.empty();
    return _readMarker(chatId.getOrCrash(), userId.getOrCrash())
        .snapshots()
        .takeUntil(_session.ended)
        .map(
          (snapshot) =>
              (snapshot.data()?['messageSentAt'] as Timestamp?)?.toDate(),
        )
        .handleError((Object error) {
          debugPrint('Read receipts not watched: ${error.runtimeType}');
        });
  }

  @override
  Future<void> clearReads() =>
      _bestEffort('Clearing read receipts', (uid) async {
        final chats = await _firestore
            .collection('chats')
            .where('participantIds', arrayContains: uid)
            .get();
        final groups = await _firestore
            .collection('groups')
            .where('memberIds', arrayContains: uid)
            .get();
        final ids = [
          for (final chat in chats.docs) chat.id,
          for (final group in groups.docs) group.id,
        ];
        // A batch holds at most 500 writes.
        for (var start = 0; start < ids.length; start += 400) {
          final batch = _firestore.batch();
          for (final id in ids.skip(start).take(400)) {
            batch.delete(_readMarker(id, uid));
          }
          await batch.commit();
        }
      });

  /// The [field] timestamp of each document in the group's [collection], by
  /// user id, leaving out the signed-in user's own.
  Stream<Map<String, DateTime>> _perPerson(
    UniqueId groupId,
    String collection,
    String field,
  ) {
    final uid = _session.current?.id;
    if (uid == null) return const Stream.empty();
    return _firestore
        .conversationDocument(groupId.getOrCrash())
        .collection(collection)
        .snapshots()
        .takeUntil(_session.ended)
        .map(
          (snapshot) => {
            for (final document in snapshot.docs)
              if (document.data()[field] case final Timestamp time
                  when document.id != uid)
                document.id: time.toDate(),
          },
        )
        // Taken out of the group, or signed out: show nothing rather than
        // fail.
        .handleError((Object error) {
          debugPrint('Group $collection not watched: ${error.runtimeType}');
        });
  }

  @override
  Stream<Map<String, DateTime>> watchTypingInGroup(UniqueId groupId) =>
      _perPerson(groupId, 'typing', 'typingAt');

  @override
  Stream<Map<String, DateTime>> watchReadsInGroup(UniqueId groupId) =>
      _perPerson(groupId, 'reads', 'messageSentAt');
}
