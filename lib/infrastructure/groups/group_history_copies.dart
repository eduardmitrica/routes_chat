import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/shared/user/current_user_session_interface.dart';
import '../core/firestore_helpers.dart';
import '../encryption/chat_cipher.dart';
import '../encryption/chat_keyring.dart';

/// Messages of a group copied for the signed-in user when whoever added them
/// shared the last day or week. See docs/e2ee.md.
///
/// The user holds no key for the originals, so wherever one does not open,
/// in the chat or in the list's preview, its copy is tried.
class GroupHistoryCopies {
  final FirebaseFirestore _firestore;
  final ICurrentUserSession _session;
  final ChatKeyring _keyring;
  final ChatCipher _cipher;

  /// Whether some history was copied for a user in a group, by user and
  /// group, so a group with none is asked once.
  final _grants = <String, Future<bool>>{};

  GroupHistoryCopies(
    this._firestore,
    this._session,
    this._keyring,
    this._cipher,
  );

  /// [messageId] of [groupId], sent by [senderId], as copied for the user;
  /// null when it was not copied for them or the copy does not open.
  Future<MessagePayload?> payloadOf(
    String groupId,
    String messageId,
    String senderId,
  ) async {
    final userId = _session.current?.id;
    if (userId == null) return null;
    final entry = '$userId/$groupId';
    final history = _firestore
        .conversationDocument(groupId)
        .collection('history')
        .doc(userId);
    try {
      final granted = await (_grants[entry] ??= history.get().then(
        (grant) => grant.exists,
      ));
      if (!granted) return null;
      final copy = (await history.collection('messages').doc(messageId).get())
          .data();
      if (copy == null) return null;
      final content = EncryptedContent.fromJson(copy['content']);
      return await _cipher.decrypt(
        content,
        chatKey: await _keyring.storedChatKey(groupId, content.keyGeneration),
        chatId: groupId,
        messageId: messageId,
        senderId: senderId,
      );
    } on Exception catch (exception) {
      if (exception is FirebaseException ||
          exception is FormatException ||
          exception is UnreadableCiphertext) {
        // Asked again next time: the copy may land a moment after the user
        // joined.
        _grants.remove(entry);
        return null;
      }
      rethrow;
    }
  }
}
