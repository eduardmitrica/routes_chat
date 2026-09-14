import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

/// A chat's encryption failed. See the subclasses.
abstract base class ChatEncryptionException implements Exception {
  const ChatEncryptionException();
}

/// Ciphertext did not open: the wrong key, the wrong chat, generation, message
/// or recipient, or altered data.
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

/// A chat key sealed to one participant's X25519 public key.
@immutable
final class SealedChatKey {
  final Uint8List ephemeralPublicKey;
  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List mac;

  /// The version of the recipient's keys it was sealed to. When the recipient
  /// resets their keys, a higher version tells their app to start a new key
  /// generation for the chat.
  final int recipientKeyVersion;

  const SealedChatKey({
    required this.ephemeralPublicKey,
    required this.nonce,
    required this.cipherText,
    required this.mac,
    required this.recipientKeyVersion,
  });

  Map<String, Object> toJson() => {
    'ephemeralPublicKey': base64Encode(ephemeralPublicKey),
    'nonce': base64Encode(nonce),
    'cipherText': base64Encode(cipherText),
    'mac': base64Encode(mac),
    'keyVersion': recipientKeyVersion,
  };

  factory SealedChatKey.fromJson(Map<dynamic, dynamic> json) => SealedChatKey(
    ephemeralPublicKey: _decodeField(json, 'ephemeralPublicKey'),
    nonce: _decodeField(json, 'nonce'),
    cipherText: _decodeField(json, 'cipherText'),
    mac: _decodeField(json, 'mac'),
    recipientKeyVersion: _intField(json, 'keyVersion'),
  );

  @override
  bool operator ==(Object other) =>
      other is SealedChatKey &&
      listEquals(other.ephemeralPublicKey, ephemeralPublicKey) &&
      listEquals(other.nonce, nonce) &&
      listEquals(other.cipherText, cipherText) &&
      listEquals(other.mac, mac) &&
      other.recipientKeyVersion == recipientKeyVersion;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(ephemeralPublicKey),
    Object.hashAll(nonce),
    Object.hashAll(cipherText),
    Object.hashAll(mac),
    recipientKeyVersion,
  );
}

/// One generation of a chat's key: the key sealed to each participant, and
/// the participant who made it.
///
/// A chat starts at generation 1. A participant who resets their keys can no
/// longer open it, so their app adds the next generation, sealed to both
/// participants' current keys. Earlier messages stay under earlier
/// generations.
@immutable
final class KeyGeneration {
  final String createdBy;
  final Map<String, SealedChatKey> sealedKeys;

  const KeyGeneration({required this.createdBy, required this.sealedKeys});

  Map<String, Object> toJson() => {
    'createdBy': createdBy,
    'sealedKeys': {
      for (final entry in sealedKeys.entries) entry.key: entry.value.toJson(),
    },
  };

  factory KeyGeneration.fromJson(Map<dynamic, dynamic> json) {
    final createdBy = json['createdBy'];
    final sealedKeys = json['sealedKeys'];
    if (createdBy is! String || sealedKeys is! Map) {
      throw const FormatException('Malformed key generation');
    }
    return KeyGeneration(
      createdBy: createdBy,
      sealedKeys: {
        for (final entry in sealedKeys.entries)
          entry.key as String: SealedChatKey.fromJson(
            entry.value is Map
                ? entry.value as Map
                : throw FormatException('No sealed key for ${entry.key}'),
          ),
      },
    );
  }

  /// A chat's `keyGenerations` field, keyed by generation number.
  static Map<int, KeyGeneration> mapFromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('The chat has no key generations');
    }
    return {
      for (final entry in json.entries)
        int.parse(entry.key as String): KeyGeneration.fromJson(
          entry.value is Map
              ? entry.value as Map
              : throw FormatException('Malformed generation ${entry.key}'),
        ),
    };
  }

  /// Firestore map keys are strings, so generation numbers are stored as such.
  static Map<String, Object> mapToJson(Map<int, KeyGeneration> generations) => {
    for (final entry in generations.entries)
      '${entry.key}': entry.value.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is KeyGeneration &&
      other.createdBy == createdBy &&
      mapEquals(other.sealedKeys, sealedKeys);

  @override
  int get hashCode => Object.hash(
    createdBy,
    Object.hashAllUnordered(
      sealedKeys.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}

/// A message encrypted with a chat key, stored as the message's `content`.
///
/// Version 2, the one written, encrypts a [MessagePayload]: the text and, for
/// a reply, the message it answers. Version 1 encrypted the text alone;
/// messages stored that way still decrypt.
@immutable
final class EncryptedContent {
  static const currentVersion = 2;
  static const readableVersions = {1, currentVersion};

  /// The format version, which decides how the ciphertext is read.
  final int version;

  /// Which of the chat's key generations it is encrypted under.
  final int keyGeneration;
  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List mac;

  const EncryptedContent({
    this.version = currentVersion,
    required this.keyGeneration,
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  Map<String, Object> toJson() => {
    'v': version,
    'e': keyGeneration,
    'nonce': base64Encode(nonce),
    'cipherText': base64Encode(cipherText),
    'mac': base64Encode(mac),
  };

  factory EncryptedContent.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('The message content is not encrypted');
    }
    final version = json['v'];
    if (version is! int || !readableVersions.contains(version)) {
      throw FormatException('Unsupported content version: $version');
    }
    return EncryptedContent(
      version: version,
      keyGeneration: _intField(json, 'e'),
      nonce: _decodeField(json, 'nonce'),
      cipherText: _decodeField(json, 'cipherText'),
      mac: _decodeField(json, 'mac'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EncryptedContent &&
      other.version == version &&
      other.keyGeneration == keyGeneration &&
      listEquals(other.nonce, nonce) &&
      listEquals(other.cipherText, cipherText) &&
      listEquals(other.mac, mac);

  @override
  int get hashCode => Object.hash(
    version,
    keyGeneration,
    Object.hashAll(nonce),
    Object.hashAll(cipherText),
    Object.hashAll(mac),
  );
}

/// What a message's ciphertext holds: its text and, for a reply, the message
/// it answers. Encrypted together, so the server cannot tell a reply from any
/// other message.
@immutable
final class MessagePayload {
  final String text;
  final QuotedMessage? replyTo;

  const MessagePayload(this.text, {this.replyTo});

  Map<String, Object> toJson() => {
    'text': text,
    if (replyTo case final replyTo?) 'replyTo': replyTo.toJson(),
  };

  /// Throws [FormatException] for anything [toJson] could not have made.
  /// Fields it does not know are passed over, so a later version of the app
  /// can add some.
  factory MessagePayload.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('Malformed message payload');
    }
    final text = json['text'];
    final replyTo = json['replyTo'];
    if (text is! String) {
      throw const FormatException('Malformed message payload');
    }
    return MessagePayload(
      text,
      replyTo: replyTo == null ? null : QuotedMessage.fromJson(replyTo),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MessagePayload && other.text == text && other.replyTo == replyTo;

  @override
  int get hashCode => Object.hash(text, replyTo);

  /// Lengths only: the text is decrypted content, which does not belong in
  /// logs.
  @override
  String toString() =>
      'MessagePayload(${text.length} code units, reply: ${replyTo != null})';
}

/// The message a reply answers, as the reply carries it: its id, its sender
/// and the start of its text.
@immutable
final class QuotedMessage {
  final String messageId;
  final String senderId;
  final String text;

  const QuotedMessage({
    required this.messageId,
    required this.senderId,
    required this.text,
  });

  Map<String, Object> toJson() => {
    'id': messageId,
    'senderId': senderId,
    'text': text,
  };

  factory QuotedMessage.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('Malformed quote');
    }
    final messageId = json['id'];
    final senderId = json['senderId'];
    final text = json['text'];
    if (messageId is! String || senderId is! String || text is! String) {
      throw const FormatException('Malformed quote');
    }
    return QuotedMessage(messageId: messageId, senderId: senderId, text: text);
  }

  @override
  bool operator ==(Object other) =>
      other is QuotedMessage &&
      other.messageId == messageId &&
      other.senderId == senderId &&
      other.text == text;

  @override
  int get hashCode => Object.hash(messageId, senderId, text);

  /// The id only, for the same reason as [MessagePayload.toString].
  @override
  String toString() => 'QuotedMessage($messageId)';
}

Uint8List _decodeField(Map<dynamic, dynamic> json, String field) {
  final value = json[field];
  if (value is! String) {
    throw FormatException('Missing $field');
  }
  return base64Decode(value);
}

int _intField(Map<dynamic, dynamic> json, String field) {
  final value = json[field];
  if (value is! int) {
    throw FormatException('Missing $field');
  }
  return value;
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

  // Built on use rather than once, so they always come from the current
  // Cryptography.instance. See UserKeyManager.
  AesGcm get _aead => AesGcm.with256bits();
  X25519 get _x25519 => X25519();
  Hkdf get _hkdf => Hkdf(hmac: Hmac.sha256(), outputLength: chatKeyLength);

  SecretKeyData newChatKey() => SecretKeyData.random(length: chatKeyLength);

  /// Seals [chatKey] so only the holder of [recipientPublicKey]'s private key
  /// can open it, and only as generation [keyGeneration] of [chatId], for
  /// [recipientId] at [recipientKeyVersion].
  ///
  /// Throws [InvalidPublicKey] if [recipientPublicKey] is unusable.
  Future<SealedChatKey> seal(
    SecretKey chatKey, {
    required List<int> recipientPublicKey,
    required int recipientKeyVersion,
    required String chatId,
    required int keyGeneration,
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
      aad: _chatKeyAssociatedData(
        chatId: chatId,
        keyGeneration: keyGeneration,
        recipientId: recipientId,
        recipientKeyVersion: recipientKeyVersion,
      ),
    );
    return SealedChatKey(
      ephemeralPublicKey: Uint8List.fromList(ephemeralPublicKey),
      nonce: Uint8List.fromList(box.nonce),
      cipherText: Uint8List.fromList(box.cipherText),
      mac: Uint8List.fromList(box.mac.bytes),
      recipientKeyVersion: recipientKeyVersion,
    );
  }

  /// Opens a chat key sealed to [recipientKeyPair].
  ///
  /// Throws [UnreadableCiphertext] if it was sealed to someone else, for
  /// another chat or generation, or altered.
  Future<SecretKeyData> open(
    SealedChatKey sealed, {
    required SimpleKeyPair recipientKeyPair,
    required String chatId,
    required int keyGeneration,
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
        _chatKeyAssociatedData(
          chatId: chatId,
          keyGeneration: keyGeneration,
          recipientId: recipientId,
          recipientKeyVersion: sealed.recipientKeyVersion,
        ),
      ),
    );
  }

  /// Encrypts [payload] in the current version of the format.
  Future<EncryptedContent> encrypt(
    MessagePayload payload, {
    required SecretKey chatKey,
    required String chatId,
    required int keyGeneration,
    required String messageId,
    required String senderId,
  }) async {
    final box = await _aead.encrypt(
      utf8.encode(jsonEncode(payload.toJson())),
      secretKey: chatKey,
      aad: _messageAssociatedData(
        EncryptedContent.currentVersion,
        chatId: chatId,
        keyGeneration: keyGeneration,
        messageId: messageId,
        senderId: senderId,
      ),
    );
    return EncryptedContent(
      keyGeneration: keyGeneration,
      nonce: Uint8List.fromList(box.nonce),
      cipherText: Uint8List.fromList(box.cipherText),
      mac: Uint8List.fromList(box.mac.bytes),
    );
  }

  /// What [content] holds, which [chatKey] must be the key of generation
  /// [EncryptedContent.keyGeneration] for.
  ///
  /// Throws [UnreadableCiphertext] if [chatKey] is wrong, [content] belongs to
  /// another chat, message or sender or was altered, or it holds no message.
  Future<MessagePayload> decrypt(
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
      _messageAssociatedData(
        content.version,
        chatId: chatId,
        keyGeneration: content.keyGeneration,
        messageId: messageId,
        senderId: senderId,
      ),
    );
    try {
      final plaintext = utf8.decode(bytes);
      return content.version == 1
          ? MessagePayload(plaintext)
          : MessagePayload.fromJson(jsonDecode(plaintext));
    } on FormatException {
      throw const UnreadableCiphertext();
    }
  }

  /// A message's associated data. Each format version has its own purpose, so
  /// relabelling a message's version makes it fail to decrypt rather than
  /// read another way.
  static Uint8List _messageAssociatedData(
    int version, {
    required String chatId,
    required int keyGeneration,
    required String messageId,
    required String senderId,
  }) => _associatedData('routes_chat/v$version/message', [
    chatId,
    '$keyGeneration',
    messageId,
    senderId,
  ]);

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

  static Uint8List _chatKeyAssociatedData({
    required String chatId,
    required int keyGeneration,
    required String recipientId,
    required int recipientKeyVersion,
  }) => _associatedData(_chatKeyPurpose, [
    chatId,
    '$keyGeneration',
    recipientId,
    '$recipientKeyVersion',
  ]);

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
