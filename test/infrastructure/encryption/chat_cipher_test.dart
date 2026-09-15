import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

const _chatId = 'alice_bob';

/// Associated data as docs/e2ee.md describes it: the purpose, then each field,
/// each as UTF-8 prefixed with its length as a 32-bit big-endian integer.
List<int> _associatedData(String purpose, List<String> fields) => [
  for (final part in [purpose, ...fields]) ...[
    ...(ByteData(
      4,
    )..setUint32(0, utf8.encode(part).length)).buffer.asUint8List(),
    ...utf8.encode(part),
  ],
];

void main() {
  final cipher = ChatCipher();
  late SimpleKeyPair alice;
  late SimpleKeyPair bob;
  late List<int> bobPublicKey;

  setUpAll(() async {
    alice = await X25519().newKeyPair();
    bob = await X25519().newKeyPair();
    bobPublicKey = (await bob.extractPublicKey()).bytes;
  });

  Future<SealedChatKey> sealForBob(
    SecretKey chatKey, {
    int keyGeneration = 1,
    int keyVersion = 1,
  }) => cipher.seal(
    chatKey,
    recipientPublicKey: bobPublicKey,
    recipientKeyVersion: keyVersion,
    chatId: _chatId,
    keyGeneration: keyGeneration,
    recipientId: 'bob',
  );

  Future<SecretKeyData> open(
    SealedChatKey sealed, {
    SimpleKeyPair? keyPair,
    String chatId = _chatId,
    int keyGeneration = 1,
    String recipientId = 'bob',
  }) => cipher.open(
    sealed,
    recipientKeyPair: keyPair ?? bob,
    chatId: chatId,
    keyGeneration: keyGeneration,
    recipientId: recipientId,
  );

  group('sealing a chat key', () {
    test('the recipient opens it', () async {
      final chatKey = cipher.newChatKey();

      final opened = await open(await sealForBob(chatKey));

      expect(opened.bytes, chatKey.bytes);
    });

    test('someone else cannot open it', () async {
      final sealed = await sealForBob(cipher.newChatKey());

      await expectLater(
        open(sealed, keyPair: alice),
        throwsA(isA<UnreadableCiphertext>()),
      );
    });

    test('it opens only for its chat, key generation and recipient', () async {
      final sealed = await sealForBob(cipher.newChatKey());

      for (final wrong in [
        () => open(sealed, chatId: 'bob_carol'),
        () => open(sealed, keyGeneration: 2),
        () => open(sealed, recipientId: 'alice'),
      ]) {
        await expectLater(wrong(), throwsA(isA<UnreadableCiphertext>()));
      }
    });

    test('the key version it was sealed to cannot be changed', () async {
      // Lowering it would make the recipient's app think the key belongs to
      // older keys, and raising it that it is current.
      final sealed = await sealForBob(cipher.newChatKey(), keyVersion: 2);
      final relabelled = SealedChatKey(
        ephemeralPublicKey: sealed.ephemeralPublicKey,
        nonce: sealed.nonce,
        cipherText: sealed.cipherText,
        mac: sealed.mac,
        recipientKeyVersion: 1,
      );

      await expectLater(open(relabelled), throwsA(isA<UnreadableCiphertext>()));
    });

    test('each seal uses a new ephemeral key', () async {
      final chatKey = cipher.newChatKey();

      final first = await sealForBob(chatKey);
      final second = await sealForBob(chatKey);

      expect(first.ephemeralPublicKey, isNot(second.ephemeralPublicKey));
      expect(first.cipherText, isNot(second.cipherText));
    });

    test('a low-order or malformed public key is refused', () async {
      for (final publicKey in [List.filled(32, 0), List.filled(31, 9)]) {
        await expectLater(
          cipher.seal(
            cipher.newChatKey(),
            recipientPublicKey: publicKey,
            recipientKeyVersion: 1,
            chatId: _chatId,
            keyGeneration: 1,
            recipientId: 'bob',
          ),
          throwsA(isA<InvalidPublicKey>()),
        );
      }
    });

    test('a key sealed with a low-order ephemeral key does not open', () async {
      final sealed = await sealForBob(cipher.newChatKey());
      final forged = SealedChatKey(
        ephemeralPublicKey: Uint8List(32),
        nonce: sealed.nonce,
        cipherText: sealed.cipherText,
        mac: sealed.mac,
        recipientKeyVersion: sealed.recipientKeyVersion,
      );

      await expectLater(open(forged), throwsA(isA<UnreadableCiphertext>()));
    });

    test('it is stored in the shape firestore.rules requires', () async {
      final sealed = await sealForBob(cipher.newChatKey(), keyVersion: 3);
      final json = sealed.toJson();

      expect(
        json.keys,
        unorderedEquals([
          'ephemeralPublicKey',
          'nonce',
          'cipherText',
          'mac',
          'keyVersion',
        ]),
      );
      expect(json['ephemeralPublicKey'], hasLength(44));
      expect(json['nonce'], hasLength(16));
      expect(json['cipherText'], hasLength(44));
      expect(json['mac'], hasLength(24));
      expect(json['keyVersion'], 3);

      final generations = {
        2: KeyGeneration(createdBy: 'alice', sealedKeys: {'bob': sealed}),
      };
      expect(
        KeyGeneration.mapFromJson(
          jsonDecode(jsonEncode(KeyGeneration.mapToJson(generations))),
        ),
        generations,
      );
    });
  });

  group('encrypting a message', () {
    late SecretKeyData chatKey;

    setUp(() => chatKey = cipher.newChatKey());

    const quote = QuotedMessage(
      messageId: 'message-0',
      senderId: 'bob',
      text: 'Ne vedem mâine?',
    );

    Future<EncryptedContent> encrypt(
      String text, {
      int keyGeneration = 1,
      QuotedMessage? replyTo,
    }) => cipher.encrypt(
      MessagePayload(text, replyTo: replyTo),
      chatKey: chatKey,
      chatId: _chatId,
      keyGeneration: keyGeneration,
      messageId: 'message-1',
      senderId: 'alice',
    );

    Future<MessagePayload> decrypt(
      EncryptedContent content, {
      SecretKey? key,
      String chatId = _chatId,
      String messageId = 'message-1',
      String senderId = 'alice',
    }) => cipher.decrypt(
      content,
      chatKey: key ?? chatKey,
      chatId: chatId,
      messageId: messageId,
      senderId: senderId,
    );

    /// Encrypts [plaintext] as version [version] content by hand, following
    /// docs/e2ee.md rather than ChatCipher.
    Future<EncryptedContent> encryptByHand(
      String plaintext,
      int version,
    ) async {
      final box = await AesGcm.with256bits().encrypt(
        utf8.encode(plaintext),
        secretKey: chatKey,
        aad: _associatedData('routes_chat/v$version/message', [
          _chatId,
          '1',
          'message-1',
          'alice',
        ]),
      );
      return EncryptedContent(
        version: version,
        keyGeneration: 1,
        nonce: Uint8List.fromList(box.nonce),
        cipherText: Uint8List.fromList(box.cipherText),
        mac: Uint8List.fromList(box.mac.bytes),
      );
    }

    test('the text comes back', () async {
      const text = 'Salut! Ce faci? 👋 ăîșț';

      expect(await decrypt(await encrypt(text)), const MessagePayload(text));
    });

    test('a reply comes back with the message it answers', () async {
      expect(
        await decrypt(await encrypt('Da, la 10', replyTo: quote)),
        const MessagePayload('Da, la 10', replyTo: quote),
      );
    });

    test('an empty message comes back', () async {
      expect((await decrypt(await encrypt(''))).text, '');
    });

    test('text that looks like the format stays text', () async {
      const text = '{"text": "not this", "replyTo": null}';

      expect(await decrypt(await encrypt(text)), const MessagePayload(text));
    });

    test('it records the key generation it is encrypted under', () async {
      expect((await encrypt('hello', keyGeneration: 4)).keyGeneration, 4);
    });

    test('it decrypts only for its chat, message and sender', () async {
      final content = await encrypt('hello', replyTo: quote);

      for (final wrong in [
        () => decrypt(content, chatId: 'alice_carol'),
        () => decrypt(content, messageId: 'message-2'),
        () => decrypt(content, senderId: 'bob'),
        () => decrypt(content, key: cipher.newChatKey()),
      ]) {
        await expectLater(wrong(), throwsA(isA<UnreadableCiphertext>()));
      }
    });

    test('its key generation cannot be changed', () async {
      final content = await encrypt('hello');
      final relabelled = EncryptedContent(
        keyGeneration: 2,
        nonce: content.nonce,
        cipherText: content.cipherText,
        mac: content.mac,
      );

      await expectLater(
        decrypt(relabelled),
        throwsA(isA<UnreadableCiphertext>()),
      );
    });

    test('its format version cannot be changed', () async {
      final content = await encrypt('hello');
      final relabelled = EncryptedContent(
        version: 1,
        keyGeneration: content.keyGeneration,
        nonce: content.nonce,
        cipherText: content.cipherText,
        mac: content.mac,
      );

      await expectLater(
        decrypt(relabelled),
        throwsA(isA<UnreadableCiphertext>()),
      );
    });

    test('version 1 and 2 content made by hand decrypts', () async {
      expect(
        await decrypt(await encryptByHand('Salut', 1)),
        const MessagePayload('Salut'),
      );
      expect(
        await decrypt(
          await encryptByHand(
            '{"text":"Da","replyTo":{"id":"m","senderId":"b","text":"Mâine?"}}',
            2,
          ),
        ),
        const MessagePayload(
          'Da',
          replyTo: QuotedMessage(messageId: 'm', senderId: 'b', text: 'Mâine?'),
        ),
      );
    });

    test('version 2 content that holds no message is unreadable', () async {
      for (final plaintext in [
        'hello',
        '[]',
        '{"text": 5}',
        '{"text": "Da", "replyTo": {"id": "m"}}',
        '{"text": "Da", "replyTo": "m"}',
      ]) {
        await expectLater(
          decrypt(await encryptByHand(plaintext, 2)),
          throwsA(isA<UnreadableCiphertext>()),
          reason: plaintext,
        );
      }
    });

    test('fields a later version adds are passed over', () async {
      expect(
        await decrypt(await encryptByHand('{"text":"Da","sticker":7}', 2)),
        const MessagePayload('Da'),
      );
    });

    test('moving a boundary between the ids changes what is bound', () async {
      final content = await cipher.encrypt(
        const MessagePayload('hi'),
        chatKey: chatKey,
        chatId: 'ab',
        keyGeneration: 1,
        messageId: 'c',
        senderId: 'x',
      );

      await expectLater(
        decrypt(content, chatId: 'a', messageId: 'bc', senderId: 'x'),
        throwsA(isA<UnreadableCiphertext>()),
      );
    });

    test('altered ciphertext is rejected', () async {
      final content = await encrypt('hello');
      final altered = EncryptedContent(
        keyGeneration: content.keyGeneration,
        nonce: content.nonce,
        cipherText: Uint8List.fromList(content.cipherText)..[0] ^= 1,
        mac: content.mac,
      );

      await expectLater(decrypt(altered), throwsA(isA<UnreadableCiphertext>()));
    });

    test('it is stored in the shape firestore.rules requires', () async {
      final content = await encrypt('hello', replyTo: quote);
      final json = content.toJson();

      expect(
        json.keys,
        unorderedEquals(['v', 'e', 'nonce', 'cipherText', 'mac']),
      );
      expect(json['v'], 2);
      expect(json['e'], 1);
      expect(json['nonce'], hasLength(16));
      expect(json['mac'], hasLength(24));
      expect(EncryptedContent.fromJson(jsonDecode(jsonEncode(json))), content);
    });

    test('the longest message and quote fit the rules size limit', () async {
      // Content allows 1000 UTF-16 code units, and a quote 100 and an
      // ellipsis. A control character, which JSON escapes as \u0001, is the
      // most bytes per code unit. Ids are a UUID and a Firebase uid.
      final longestQuote = QuotedMessage(
        messageId: 'm' * 36,
        senderId: 'u' * 28,
        text: '\u0001' * 101,
      );
      for (final character in ['\u0001', '€', '"', '\\']) {
        final json = (await encrypt(
          character * 1000,
          replyTo: longestQuote,
        )).toJson();

        expect(
          json['cipherText'],
          hasLength(lessThanOrEqualTo(48000)),
          reason: 'U+${character.codeUnitAt(0).toRadixString(16)}',
        );
      }
    });

    test('version 1 content is still read', () {
      final json = (EncryptedContent(
        version: 1,
        keyGeneration: 1,
        nonce: Uint8List(12),
        cipherText: Uint8List(5),
        mac: Uint8List(16),
      )).toJson();

      expect(EncryptedContent.fromJson(json).version, 1);
    });

    test('plaintext or an unknown version is not taken for encrypted', () {
      expect(() => EncryptedContent.fromJson('hello'), throwsFormatException);
      expect(
        () => EncryptedContent.fromJson({
          'v': 3,
          'e': 1,
          'nonce': '',
          'cipherText': '',
          'mac': '',
        }),
        throwsFormatException,
      );
    });

    test('what a message says stays out of logs', () {
      const payload = MessagePayload('secret plans', replyTo: quote);

      expect(payload.toString(), isNot(contains('secret')));
      expect(payload.toString(), isNot(contains('mâine')));
    });
  });
}
