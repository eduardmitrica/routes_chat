import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/chats/chat_requests.dart';
import '../../domain/core/value_objects.dart';
import '../../domain/shared/user/current_user_session_interface.dart';

/// The user's decisions about chats from people who are not their friends,
/// in `users/{uid}/chatRequests/{chatId}`, and whether such people may reach
/// them at all, in `users/{uid}/settings/messaging`.
///
/// Both are private to the user. The sender is never told what happened to
/// their message; the notification functions read the setting with the Admin
/// SDK, so a message that may not reach the user never rings.
class FirestoreChatRequestsRepository implements IChatRequestsRepository {
  static const messagingSettings = 'messaging';

  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;

  const FirestoreChatRequestsRepository(this._firestore, this._session);

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _requests(String uid) =>
      _user(uid).collection('chatRequests');

  DocumentReference<Map<String, dynamic>> _settings(String uid) =>
      _user(uid).collection('settings').doc(messagingSettings);

  @override
  Stream<ChatRequests> watch() {
    final uid = _session.current?.id;
    if (uid == null) return Stream.value(const ChatRequests());
    // Both together: a change to either decides where a chat belongs.
    return Rx.combineLatest2(
      _requests(uid).snapshots().takeUntil(_session.ended),
      _settings(uid).snapshots().takeUntil(_session.ended),
      (
        QuerySnapshot<Map<String, dynamic>> decisions,
        DocumentSnapshot<Map<String, dynamic>> settings,
      ) => ChatRequests(
        byChatId: {
          for (final document in decisions.docs)
            document.id: ?decisionFrom(document.data()),
        },
        allowFromAnyone: settings.data()?['allowFromAnyone'] as bool? ?? true,
      ),
    ).handleError((Object error) {
      debugPrint('Message requests not watched: ${error.runtimeType}');
    });
  }

  /// A stored decision, or null when it is not in the stored format. One made
  /// on this phone has no server time yet, and counts from now.
  @visibleForTesting
  static ChatRequestDecision? decisionFrom(Map<String, dynamic>? data) {
    final state = ChatRequestState.fromStored(data?['state']);
    if (state == null) return null;
    final at = data?['at'];
    return ChatRequestDecision(
      state,
      at is Timestamp ? at.toDate() : DateTime.now(),
    );
  }

  @override
  Future<void> accept(UniqueId chatId) =>
      _decide(chatId, ChatRequestState.accepted);

  @override
  Future<void> delete(UniqueId chatId) =>
      _decide(chatId, ChatRequestState.deleted);

  Future<void> _decide(UniqueId chatId, ChatRequestState state) async {
    final uid = _session.current?.id;
    if (uid == null) return;
    try {
      await _requests(uid).doc(chatId.getOrCrash()).set({
        'state': state.storedName,
        'at': FieldValue.serverTimestamp(),
      });
    } on Exception catch (exception) {
      debugPrint(
        'Message request not ${state.storedName}: '
        '${exception.runtimeType}',
      );
    }
  }

  @override
  Future<void> setAllowFromAnyone({required bool allow}) async {
    final uid = _session.current?.id;
    if (uid == null) return;
    try {
      await _settings(uid).set({'allowFromAnyone': allow});
    } on Exception catch (exception) {
      debugPrint('Messaging setting not saved: ${exception.runtimeType}');
    }
  }
}
