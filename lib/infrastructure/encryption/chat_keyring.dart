import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';

import '../../domain/shared/user/current_user_session_interface.dart';
import '../core/firestore_helpers.dart';
import 'chat_cipher.dart';

/// This device has not unlocked the signed-in user's encryption keys, or
/// nobody is signed in.
final class EncryptionKeysLocked extends ChatEncryptionException {
  const EncryptionKeysLocked();

  @override
  String toString() => 'EncryptionKeysLocked';
}

/// [userId] has not set up encryption, so no chat key can be sealed to them.
final class ParticipantWithoutKeys extends ChatEncryptionException {
  final String userId;

  const ParticipantWithoutKeys(this.userId);

  @override
  String toString() => 'ParticipantWithoutKeys($userId)';
}

/// Supplies the signed-in user's unlocked X25519 key pair.
abstract interface class UnlockedKeyPairSource {
  /// Throws [EncryptionKeysLocked] if this device has not unlocked [userId]'s
  /// keys.
  Future<SimpleKeyPair> unlockedKeyPair(String userId);
}

/// A new chat's key, and that key sealed to each participant.
final class NewChatKey {
  final SecretKeyData key;
  final Map<String, SealedChatKey> sealed;

  const NewChatKey(this.key, this.sealed);
}

/// Creates and opens the keys of the signed-in user's chats. See docs/e2ee.md.
///
/// Opened keys are kept in memory for the session and forgotten when it ends,
/// so a chat's key is opened once rather than for every message.
class ChatKeyring {
  final FirebaseFirestore _firestore;
  final ChatCipher _cipher;
  final UnlockedKeyPairSource _keyPairs;
  final ICurrentUserSession _session;

  final _chatKeys = <String, Future<SecretKey>>{};
  final _ownKeyPairs = <String, Future<SimpleKeyPair>>{};

  ChatKeyring(this._firestore, this._cipher, this._keyPairs, this._session) {
    _session.ended.listen((_) => forget());
  }

  /// Drops every opened key from memory.
  void forget() {
    _chatKeys.clear();
    _ownKeyPairs.clear();
  }

  /// A key for a new chat between [participantIds], sealed to each of them.
  ///
  /// Throws [ParticipantWithoutKeys] if one of them has no published public
  /// key.
  Future<NewChatKey> newChatKey(
    String chatId,
    List<String> participantIds,
  ) async {
    final userId = _signedInUserId();
    if (!participantIds.contains(userId)) {
      throw ArgumentError.value(
        participantIds,
        'participantIds',
        'must include the signed-in user',
      );
    }
    // The user's own public key comes from their unlocked key pair, not from
    // Firestore, so it is certainly the one they can open.
    final ownPublicKey = (await (await _ownKeyPair(
      userId,
    )).extractPublicKey()).bytes;

    final chatKey = _cipher.newChatKey();
    final sealed = <String, SealedChatKey>{};
    for (final participantId in participantIds) {
      sealed[participantId] = await _cipher.seal(
        chatKey,
        recipientPublicKey: participantId == userId
            ? ownPublicKey
            : await _publishedPublicKey(participantId),
        chatId: chatId,
        recipientId: participantId,
      );
    }
    return NewChatKey(chatKey, sealed);
  }

  /// Keeps the key of a chat this device just created, so it is not opened
  /// again.
  void remember(String chatId, SecretKey chatKey) {
    final userId = _session.current?.id;
    if (userId != null) {
      _chatKeys[_entry(userId, chatId)] = Future.value(chatKey);
    }
  }

  /// The key of [chatId], opened from the chat's [sealedKeys].
  ///
  /// Throws [UnreadableCiphertext] if none of them opens for the signed-in
  /// user.
  Future<SecretKey> chatKey(
    String chatId,
    Map<String, SealedChatKey> sealedKeys,
  ) => _cached(chatId, (userId) => _open(userId, chatId, sealedKeys));

  /// The key of the stored chat [chatId], reading its sealed keys if this
  /// device has not opened it yet.
  Future<SecretKey> storedChatKey(String chatId) => _cached(chatId, (
    userId,
  ) async {
    final chat = await _firestore.collection('chats').doc(chatId).get();
    final data = chat.data();
    if (data == null) {
      throw const UnreadableCiphertext();
    }
    return _open(userId, chatId, SealedChatKey.mapFromJson(data['chatKeys']));
  });

  Future<SecretKey> _open(
    String userId,
    String chatId,
    Map<String, SealedChatKey> sealedKeys,
  ) async {
    final sealed = sealedKeys[userId];
    if (sealed == null) {
      throw const UnreadableCiphertext();
    }
    return _cipher.open(
      sealed,
      recipientKeyPair: await _ownKeyPair(userId),
      chatId: chatId,
      recipientId: userId,
    );
  }

  Future<SecretKey> _cached(
    String chatId,
    Future<SecretKey> Function(String userId) open,
  ) async {
    final userId = _signedInUserId();
    final entry = _entry(userId, chatId);
    return _chatKeys[entry] ??= _forgetOnError(_chatKeys, entry, open(userId));
  }

  Future<SimpleKeyPair> _ownKeyPair(String userId) => _ownKeyPairs[userId] ??=
      _forgetOnError(_ownKeyPairs, userId, _keyPairs.unlockedKeyPair(userId));

  Future<List<int>> _publishedPublicKey(String userId) async {
    final published = (await _firestore.publicKeyDocument(userId).get())
        .data()?['publicKey'];
    final bytes = published is String ? base64Decode(published) : null;
    if (bytes == null || bytes.length != 32) {
      throw ParticipantWithoutKeys(userId);
    }
    return bytes;
  }

  String _signedInUserId() =>
      _session.current?.id ?? (throw const EncryptionKeysLocked());

  static String _entry(String userId, String chatId) => '$userId/$chatId';

  /// Returns [future], removing it from [cache] if it fails, so a failure is
  /// retried next time instead of being remembered.
  static Future<T> _forgetOnError<T>(
    Map<String, Future<T>> cache,
    String entry,
    Future<T> future,
  ) {
    future.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(cache[entry], future)) {
          cache.remove(entry);
        }
      },
    );
    return future;
  }
}
