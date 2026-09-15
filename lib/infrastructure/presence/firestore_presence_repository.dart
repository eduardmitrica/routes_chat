import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/core/value_objects.dart';
import '../../domain/presence/presence.dart';
import '../../domain/presence/presence_repository_interface.dart';
import '../../domain/shared/user/current_user_session_interface.dart';

/// Typing in `chats/{chatId}/typing/{uid}` and presence in `presence/{uid}`.
///
/// firestore.rules let a chat's participants see who types in it, and only
/// friends see each other's presence. Both documents hold a server time and
/// nothing else a client could use to say more than "now".
class FirestorePresenceRepository implements IPresenceRepository {
  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;

  const FirestorePresenceRepository(this._firestore, this._session);

  DocumentReference<Map<String, dynamic>> _typing(String chatId, String uid) =>
      _firestore.collection('chats').doc(chatId).collection('typing').doc(uid);

  DocumentReference<Map<String, dynamic>> _presence(String uid) =>
      _firestore.collection('presence').doc(uid);

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
}
