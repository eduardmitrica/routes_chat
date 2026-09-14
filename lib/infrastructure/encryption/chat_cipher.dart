import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

/// A chat's encryption failed. See the subclasses.
abstract base class ChatEncryptionException implements Exception {
  const ChatEncryptionException();
}

/// Ciphertext did not open: the wrong key, the wrong chat, message or
/// recipient, or altered data.
final class UnreadableCiphertext extends ChatEncryptionException {
  const UnreadableCiphertext();

  @override
  String toString() => 'UnreadableCiphertext';
}

/// A public key that is malformed or of low order. Sealing to it would give a
/// key anyone can compute.
final class InvalidPublicKey extends ChatEncryptionException {
  const InvalidPublicKey();

  @override
  String toString() => 'InvalidPublicKey';
}

/// A chat key sealed to one participant's X25519 public key, stored at
/// `chats/{chatId}.chatKeys.{uid}`.
@immutable
final class SealedChatKey {
  final Uint8List ephemeralPublicKey;
  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List mac;

  const SealedChatKey({
    required this.ephemeralPublicKey,
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  Map<String, String> toJson() => {
    'ephemeralPublicKey': base64Encode(ephemeralPublicKey),
    'nonce': base64Encode(nonce),
    'cipherText': base64Encode(cipherText),
    'mac': base64Encode(mac),
  };

  factory SealedChatKey.fromJson(Map<dynamic, dynamic> json) => SealedChatKey(
    ephemeralPublicKey: _decodeField(json, 'ephemeralPublicKey'),
    nonce: _decodeField(json, 'nonce'),
    cipherText: _decodeField(json, 'cipherText'),
    mac: _decodeField(json, 'mac'),
  );

  /// A chat's `chatKeys` field: each participant's id to their sealed key.
  static Map<String, SealedChatKey> mapFromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('The chat has no sealed keys');
    }
    return {
      for (final entry in json.entries)
        entry.key as String: SealedChatKey.fromJson(
          entry.value is Map
              ? entry.value as Map
              : throw FormatException('No sealed key for ${entry.key}'),
        ),
    };
  }

  static Map<String, Map<String, String>> mapToJson(
    Map<String, SealedChatKey> sealedKeys,
  ) => {
    for (final entry in sealedKeys.entries) entry.key: entry.value.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is SealedChatKey &&
      listEquals(other.ephemeralPublicKey, ephemeralPublicKey) &&
      listEquals(other.nonce, nonce) &&
      listEquals(other.cipherText, cipherText) &&
      listEquals(other.mac, mac);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(ephemeralPublicKey),
    Object.hashAll(nonce),
    Object.hashAll(cipherText),
    Object.hashAll(mac),
  );
}

/// Message text encrypted with a chat key, stored as a message's `content`.
@immutable
final class EncryptedContent {
  static const currentVersion = 1;

  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List mac;

  const EncryptedContent({
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  Map<String, Object> toJson() => {
    'v': currentVersion,
    'nonce': base64Encode(nonce),
    'cipherText': base64Encode(cipherText),
    'mac': base64Encode(mac),
  };

  factory EncryptedContent.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('The message content is not encrypted');
    }
    if (json['v'] != currentVersion) {
      throw FormatException('Unsupported content version: ${json['v']}');
    }
    return EncryptedContent(
      nonce: _decodeField(json, 'nonce'),
      cipherText: _decodeField(json, 'cipherText'),
      mac: _decodeField(json, 'mac'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EncryptedContent &&
      listEquals(other.nonce, nonce) &&
      listEquals(other.cipherText, cipherText) &&
      listEquals(other.mac, mac);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(nonce),
    Object.hashAll(cipherText),
    Object.hashAll(mac),
  );
}

Uint8List _decodeField(Map<dynamic, dynamic> json, String field) {
  final value = json[field];
  if (value is! String) {
    throw FormatException('Missing $field');
  }
  return base64Decode(value);
}

/// Seals chat keys to participants and encrypts message text. See
/// docs/e2ee.md.
///
/// This is pure cryptography: finding public keys and storing chats is the
/// caller's job. The format is also implemented outside the app, so any change
/// here is a new version, never an edit.
class ChatCipher {
  static const chatKeyLength = 32;

  /// Shown in place of a message that does not decrypt.
  static const unreadableMessageText = 'This message could not be decrypted.';

  static const _sealingKeyInfo = 'routes_chat/v1/chat-key/kek';
  static const _chatKeyPurpose = 'routes_chat/v1/chat-key';
  static const _messagePurpose = 'routes_chat/v1/message';

  // Built on use rather than once, so they always come from the current
  // Cryptography.instance. See UserKeyManager.
  AesGcm get _aead => AesGcm.with256bits();
  X25519 get _x25519 => X25519();
  Hkdf get _hkdf => Hkdf(hmac: Hmac.sha256(), outputLength: chatKeyLength);

  SecretKeyData newChatKey() => SecretKeyData.random(length: chatKeyLength);

  /// Seals [chatKey] so only the holder of [recipientPublicKey]'s private key
  /// can open it, and only for [chatId] and [recipientId].
  ///
  /// Throws [InvalidPublicKey] if [recipientPublicKey] is unusable.
  Future<SealedChatKey> seal(
    SecretKey chatKey, {
    required List<int> recipientPublicKey,
    required String chatId,
    required String recipientId,
  }) async {
    final ephemeral = await _x25519.newKeyPair();
    final ephemeralPublicKey = (await ephemeral.extractPublicKey()).bytes;
    final sealingKey = await _sealingKey(
      ownKeyPair: ephemeral,
      remotePublicKey: recipientPublicKey,
      ephemeralPublicKey: ephemeralPublicKey,
      recipientPublicKey: recipientPublicKey,
    );
    if (sealingKey == null) {
      throw const InvalidPublicKey();
    }
    final box = await _aead.encrypt(
      await chatKey.extractBytes(),
      secretKey: sealingKey,
      aad: _associatedData(_chatKeyPurpose, [chatId, recipientId]),
    );
    return SealedChatKey(
      ephemeralPublicKey: Uint8List.fromList(ephemeralPublicKey),
      nonce: Uint8List.fromList(box.nonce),
      cipherText: Uint8List.fromList(box.cipherText),
      mac: Uint8List.fromList(box.mac.bytes),
    );
  }

  /// Opens a chat key sealed to [recipientKeyPair].
  ///
  /// Throws [UnreadableCiphertext] if it was sealed to someone else, for
  /// another chat, or altered.
  Future<SecretKeyData> open(
    SealedChatKey sealed, {
    required SimpleKeyPair recipientKeyPair,
    required String chatId,
    required String recipientId,
  }) async {
    final recipientPublicKey =
        (await recipientKeyPair.extractPublicKey()).bytes;
    final sealingKey = await _sealingKey(
      ownKeyPair: recipientKeyPair,
      remotePublicKey: sealed.ephemeralPublicKey,
      ephemeralPublicKey: sealed.ephemeralPublicKey,
      recipientPublicKey: recipientPublicKey,
    );
    if (sealingKey == null) {
      throw const UnreadableCiphertext();
    }
    return SecretKeyData(
      await _decrypt(
        SecretBox(sealed.cipherText, nonce: sealed.nonce, mac: Mac(sealed.mac)),
        sealingKey,
        _associatedData(_chatKeyPurpose, [chatId, recipientId]),
      ),
    );
  }

  Future<EncryptedContent> encrypt(
    String text, {
    required SecretKey chatKey,
    required String chatId,
    required String messageId,
    required String senderId,
  }) async {
    final box = await _aead.encrypt(
      utf8.encode(text),
      secretKey: chatKey,
      aad: _associatedData(_messagePurpose, [chatId, messageId, senderId]),
    );
    return EncryptedContent(
      nonce: Uint8List.fromList(box.nonce),
      cipherText: Uint8List.fromList(box.cipherText),
      mac: Uint8List.fromList(box.mac.bytes),
    );
  }

  /// The text of [content].
  ///
  /// Throws [UnreadableCiphertext] if [chatKey] is wrong, or [content] belongs
  /// to another chat, message or sender, or was altered.
  Future<String> decrypt(
    EncryptedContent content, {
    required SecretKey chatKey,
    required String chatId,
    required String messageId,
    required String senderId,
  }) async {
    final bytes = await _decrypt(
      SecretBox(
        content.cipherText,
        nonce: content.nonce,
        mac: Mac(content.mac),
      ),
      chatKey,
      _associatedData(_messagePurpose, [chatId, messageId, senderId]),
    );
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw const UnreadableCiphertext();
    }
  }

  /// The key a chat key is sealed under: HKDF over the X25519 shared secret,
  /// bound to both public keys. Null if the shared secret is all zeros, which
  /// a low-order public key produces.
  Future<SecretKey?> _sealingKey({
    required SimpleKeyPair ownKeyPair,
    required List<int> remotePublicKey,
    required List<int> ephemeralPublicKey,
    required List<int> recipientPublicKey,
  }) async {
    if (remotePublicKey.length != 32) {
      return null;
    }
    final sharedSecret = await (await _x25519.sharedSecretKey(
      keyPair: ownKeyPair,
      remotePublicKey: SimplePublicKey(
        remotePublicKey,
        type: KeyPairType.x25519,
      ),
    )).extractBytes();
    if (sharedSecret.every((byte) => byte == 0)) {
      return null;
    }
    return _hkdf.deriveKey(
      secretKey: SecretKeyData(sharedSecret),
      // RFC 5869's default salt, spelled out: Android's native HMAC rejects
      // the empty key an omitted salt would give.
      nonce: _hkdfDefaultSalt,
      info: [
        ...utf8.encode(_sealingKeyInfo),
        ...ephemeralPublicKey,
        ...recipientPublicKey,
      ],
    );
  }

  static final _hkdfDefaultSalt = List<int>.filled(32, 0, growable: false);

  Future<List<int>> _decrypt(
    SecretBox box,
    SecretKey key,
    List<int> associatedData,
  ) async {
    try {
      return await _aead.decrypt(box, secretKey: key, aad: associatedData);
    } on SecretBoxAuthenticationError {
      throw const UnreadableCiphertext();
    }
  }

  /// [purpose] followed by [fields], each prefixed with its length in bytes
  /// (32-bit big-endian), so two different lists of fields never encode the
  /// same.
  static Uint8List _associatedData(String purpose, List<String> fields) {
    final builder = BytesBuilder(copy: false);
    for (final part in [purpose, ...fields]) {
      final bytes = utf8.encode(part);
      builder
        ..add((ByteData(4)..setUint32(0, bytes.length)).buffer.asUint8List())
        ..add(bytes);
    }
    return builder.takeBytes();
  }
}
