import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';

import '../../domain/groups/group.dart';
import '../../domain/shared/user/current_user_session_interface.dart';
import '../core/firestore_helpers.dart';
import '../core/single_flight.dart';
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

/// The signed-in user's unlocked key pair, and the version of their keys.
final class UnlockedKeys {
  final SimpleKeyPair keyPair;
  final int keyVersion;

  const UnlockedKeys(this.keyPair, this.keyVersion);
}

/// Supplies the signed-in user's unlocked keys.
abstract interface class UnlockedKeysSource {
  /// Throws [EncryptionKeysLocked] if this device has not unlocked [userId]'s
  /// keys.
  Future<UnlockedKeys> unlockedKeys(String userId);

  /// Emits when this device unlocks or replaces keys, so that nothing opened
  /// with earlier keys is kept.
  Stream<void> get keysChanged;
}

/// A new generation of a chat's key: the key, and what is stored for it.
final class NewKeyGeneration {
  final int number;
  final SecretKeyData key;
  final KeyGeneration stored;

  const NewKeyGeneration(this.number, this.key, this.stored);
}

/// Creates and opens the keys of the signed-in user's chats. See docs/e2ee.md.
///
/// Opened keys are kept in memory for the session and forgotten when it ends
/// or the keys change, so a chat's key is opened once rather than for every
/// message.
class ChatKeyring {
  final FirebaseFirestore _firestore;
  final ChatCipher _cipher;
  final UnlockedKeysSource _keys;
  final ICurrentUserSession _session;

  final _chatKeys = <String, Future<SecretKey>>{};
  final _ownKeys = <String, Future<UnlockedKeys>>{};
  final _addingGenerations = <String, Future<void>>{};

  ChatKeyring(this._firestore, this._cipher, this._keys, this._session) {
    _session.ended.listen((_) => forget());
    _keys.keysChanged.listen((_) => forget());
  }

  /// Drops every opened key from memory.
  void forget() {
    _chatKeys.clear();
    _ownKeys.clear();
  }

  /// The first generation of the key of a new chat between [participantIds].
  ///
  /// Throws [ParticipantWithoutKeys] if one of them has no published public
  /// key.
  Future<NewKeyGeneration> firstGeneration(
    String chatId,
    List<String> participantIds,
  ) => _newGeneration(chatId, participantIds, 1);

  /// Keeps a generation this device just stored, so it is not opened again.
  void remember(String chatId, NewKeyGeneration generation) {
    final userId = _session.current?.id;
    if (userId != null) {
      _chatKeys[_entry(userId, chatId, generation.number)] = Future.value(
        generation.key,
      );
    }
  }

  /// The key of generation [number] of [chatId], opened from [generations].
  ///
  /// Throws [UnreadableCiphertext] if it does not open for the signed-in
  /// user's current keys.
  Future<SecretKey> chatKey(
    String chatId,
    int number,
    Map<int, KeyGeneration> generations,
  ) => _cached(
    chatId,
    number,
    (userId) => _open(userId, chatId, number, generations),
  );

  /// The key of generation [number] of the stored chat [chatId], reading the
  /// chat if this device has not opened that generation yet.
  Future<SecretKey> storedChatKey(String chatId, int number) =>
      _cached(chatId, number, (userId) async {
        final data = (await _chatDocument(chatId).get()).data();
        if (data == null) {
          throw const UnreadableCiphertext();
        }
        return _open(
          userId,
          chatId,
          number,
          KeyGeneration.mapFromJson(data['keyGenerations']),
        );
      });

  /// Whether the signed-in user's keys were reset since generation [current]
  /// of [generations] was made, so they cannot open it.
  Future<bool> needsNewGeneration(
    Map<int, KeyGeneration> generations,
    int current,
  ) async {
    final userId = _signedInUserId();
    final own = await _ownUnlockedKeys(userId);
    final sealed = generations[current]?.sealedKeys[userId];
    return (sealed?.recipientKeyVersion ?? 0) < own.keyVersion;
  }

  /// Adds the next generation of [chatId]'s key, sealed to both participants'
  /// current keys, if the signed-in user's keys were reset since the current
  /// one. Their chat partner then sees the reset.
  Future<void> addGenerationIfNeeded(String chatId) => singleFlight(
    _addingGenerations,
    chatId,
    () => _addGenerationIfNeeded(chatId),
  );

  Future<void> _addGenerationIfNeeded(String chatId) async {
    final chatRef = _chatDocument(chatId);
    // Retried when someone else adds a generation first.
    for (var attempt = 0; attempt < 3; attempt++) {
      final data = (await chatRef.get()).data();
      if (data == null) return;
      final current = data['currentKeyGeneration'] as int;
      final generations = KeyGeneration.mapFromJson(data['keyGenerations']);
      if (!await _needsNewGeneration(data, generations, current)) return;

      // Sealing reads the other participant's public key, so the generation
      // is made outside the transaction, which may run more than once.
      final next = await _newGeneration(chatId, _sealedTo(data), current + 1);
      final added = await _firestore.runTransaction((transaction) async {
        final fresh = (await transaction.get(chatRef)).data();
        if (fresh == null || fresh['currentKeyGeneration'] != current) {
          return false;
        }
        transaction.update(chatRef, {
          FieldPath(['keyGenerations', '${next.number}']): next.stored.toJson(),
          'currentKeyGeneration': next.number,
        });
        return true;
      });
      if (added) {
        remember(chatId, next);
        return;
      }
    }
  }

  /// Who a new generation of a stored conversation is sealed to: the two
  /// people of a one-to-one chat, or everyone in a group, invited included.
  static List<String> _sealedTo(Map<String, dynamic> data) =>
      data.containsKey('participantIds')
      ? (data['participantIds'] as List).cast<String>()
      : [
          ...(data['memberIds'] as List).cast<String>(),
          ...(data['invitedIds'] as List).cast<String>(),
        ];

  /// Whether the stored conversation [data] needs its next key generation:
  /// the user's keys were reset, or, in a group, the current key is sealed to
  /// other people than are in it. Only a member of a group makes one.
  Future<bool> _needsNewGeneration(
    Map<String, dynamic> data,
    Map<int, KeyGeneration> generations,
    int current,
  ) async {
    if (!data.containsKey('participantIds')) {
      final userId = _signedInUserId();
      if (!(data['memberIds'] as List).contains(userId)) return false;
      if (groupKeyOutOfDate(
        generations[current]?.sealedKeys.keys ?? const [],
        _sealedTo(data),
      )) {
        return true;
      }
    }
    return needsNewGeneration(generations, current);
  }

  /// Whether a group's stored [data] needs a new key generation that the
  /// signed-in user, a member, would make.
  Future<bool> groupNeedsNewGeneration(Map<String, dynamic> data) async {
    final generations = KeyGeneration.mapFromJson(data['keyGenerations']);
    return _needsNewGeneration(
      data,
      generations,
      data['currentKeyGeneration'] as int,
    );
  }

  /// Every generation of [groupId]'s key the signed-in user can open, sealed
  /// to [recipientId], for someone added with its history. Generations the
  /// user cannot open are left out: nobody shares what they cannot read.
  ///
  /// Throws [ParticipantWithoutKeys] if [recipientId] has no published key.
  Future<Map<String, Object>> historyFor(
    String groupId,
    String recipientId,
    Map<int, KeyGeneration> generations,
  ) async {
    final (publicKey, keyVersion) = await _publishedKeys(recipientId);
    final shared = <String, Object>{};
    for (final number in generations.keys) {
      final SecretKey key;
      try {
        key = await chatKey(groupId, number, generations);
      } on UnreadableCiphertext {
        continue;
      }
      shared['$number'] = (await _cipher.seal(
        key,
        recipientPublicKey: publicKey,
        recipientKeyVersion: keyVersion,
        chatId: groupId,
        keyGeneration: number,
        recipientId: recipientId,
      )).toJson();
    }
    return shared;
  }

  /// The generation number a group's copied history is encrypted under. Real
  /// generations start at 1, so a copy can never pass for a message.
  static const historyGeneration = 0;

  /// A new key for the history of [groupId] copied for [recipientId], and the
  /// key sealed to them as generation [historyGeneration].
  ///
  /// Throws [ParticipantWithoutKeys] if [recipientId] has no published key.
  Future<(SecretKey, Map<String, Object>)> newHistoryKey(
    String groupId,
    String recipientId,
  ) async {
    final (publicKey, keyVersion) = await _publishedKeys(recipientId);
    final key = _cipher.newChatKey();
    final sealed = await _cipher.seal(
      key,
      recipientPublicKey: publicKey,
      recipientKeyVersion: keyVersion,
      chatId: groupId,
      keyGeneration: historyGeneration,
      recipientId: recipientId,
    );
    return (key, sealed.toJson());
  }

  Future<NewKeyGeneration> _newGeneration(
    String chatId,
    List<String> participantIds,
    int number,
  ) async {
    final userId = _signedInUserId();
    if (!participantIds.contains(userId)) {
      throw ArgumentError.value(
        participantIds,
        'participantIds',
        'must include the signed-in user',
      );
    }
    final own = await _ownUnlockedKeys(userId);
    // The user's own copy is sealed to their unlocked key pair, not to the
    // public key read from Firestore, so it is certainly one they can open.
    final ownPublicKey = (await own.keyPair.extractPublicKey()).bytes;

    final key = _cipher.newChatKey();
    final sealed = <String, SealedChatKey>{};
    for (final participantId in participantIds) {
      final (publicKey, keyVersion) = participantId == userId
          ? (ownPublicKey, own.keyVersion)
          : await _publishedKeys(participantId);
      sealed[participantId] = await _cipher.seal(
        key,
        recipientPublicKey: publicKey,
        recipientKeyVersion: keyVersion,
        chatId: chatId,
        keyGeneration: number,
        recipientId: participantId,
      );
    }
    return NewKeyGeneration(
      number,
      key,
      KeyGeneration(createdBy: userId, sealedKeys: sealed),
    );
  }

  Future<SecretKey> _open(
    String userId,
    String chatId,
    int number,
    Map<int, KeyGeneration> generations,
  ) async {
    final sealed =
        generations[number]?.sealedKeys[userId] ??
        (isGroupIdString(chatId)
            ? await _sharedWith(userId, chatId, number)
            : null);
    final own = await _ownUnlockedKeys(userId);
    // A key sealed to keys the user has since reset cannot open.
    if (sealed == null || sealed.recipientKeyVersion != own.keyVersion) {
      throw const UnreadableCiphertext();
    }
    return _cipher.open(
      sealed,
      recipientKeyPair: own.keyPair,
      chatId: chatId,
      keyGeneration: number,
      recipientId: userId,
    );
  }

  Future<SecretKey> _cached(
    String chatId,
    int number,
    Future<SecretKey> Function(String userId) open,
  ) async {
    final userId = _signedInUserId();
    final entry = _entry(userId, chatId, number);
    return _chatKeys[entry] ??= _forgetUnlessUnreadable(
      _chatKeys,
      entry,
      open(userId),
    );
  }

  Future<UnlockedKeys> _ownUnlockedKeys(String userId) => _ownKeys[userId] ??=
      _forgetUnlessUnreadable(_ownKeys, userId, _keys.unlockedKeys(userId));

  /// [userId]'s published public key, and the version of their keys.
  Future<(List<int>, int)> _publishedKeys(String userId) async {
    final data = (await _firestore.publicKeyDocument(userId).get()).data();
    final published = data?['publicKey'];
    final bytes = published is String ? base64Decode(published) : null;
    if (bytes == null || bytes.length != 32) {
      throw ParticipantWithoutKeys(userId);
    }
    // Keys published before key resets existed carry no version: they are
    // the user's first.
    return (bytes, data?['keyVersion'] as int? ?? 1);
  }

  /// Generation [number] of [groupId]'s key as shared with [userId] when they
  /// were added with the group's history, if it was.
  Future<SealedChatKey?> _sharedWith(
    String userId,
    String groupId,
    int number,
  ) async {
    try {
      // The key of a copied history is kept with the copy's grant.
      if (number == historyGeneration) {
        final grant = (await _chatDocument(
          groupId,
        ).collection('history').doc(userId).get()).data();
        final sealed = grant?['key'];
        return sealed is Map ? SealedChatKey.fromJson(sealed) : null;
      }
      final data = (await _chatDocument(
        groupId,
      ).collection('sharedKeys').doc(userId).get()).data();
      final sealed = (data?['generations'] as Map?)?['$number'];
      return sealed is Map ? SealedChatKey.fromJson(sealed) : null;
    } on FirebaseException catch (error) {
      // Refused means nothing is shared with the user. Anything else, such as
      // being offline, may pass, so it is not remembered as unreadable.
      if (error.code == 'permission-denied') return null;
      rethrow;
    }
  }

  DocumentReference<Map<String, dynamic>> _chatDocument(String chatId) =>
      _firestore.conversationDocument(chatId);

  String _signedInUserId() =>
      _session.current?.id ?? (throw const EncryptionKeysLocked());

  static String _entry(String userId, String chatId, int number) =>
      '$userId/$chatId/$number';

  /// Returns [future], removing it from [cache] if it fails for a reason that
  /// may pass, such as the network. A key that cannot open stays remembered
  /// as such until the keys change, instead of being tried for every message.
  static Future<T> _forgetUnlessUnreadable<T>(
    Map<String, Future<T>> cache,
    String entry,
    Future<T> future,
  ) {
    future.then<void>(
      (_) {},
      onError: (Object error) {
        if (error is! UnreadableCiphertext && identical(cache[entry], future)) {
          cache.remove(entry);
        }
      },
    );
    return future;
  }
}
