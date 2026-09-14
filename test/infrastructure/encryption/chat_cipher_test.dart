import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

const _chatId = 'alice_bob';

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

    Future<EncryptedContent> encrypt(String text, {int keyGeneration = 1}) =>
        cipher.encrypt(
          text,
          chatKey: chatKey,
          chatId: _chatId,
          keyGeneration: keyGeneration,
          messageId: 'message-1',
          senderId: 'alice',
        );

    Future<String> decrypt(
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

    test('the text comes back', () async {
      const text = 'Salut! Ce faci? 👋 ăîșț';

      expect(await decrypt(await encrypt(text)), text);
    });

    test('an empty message comes back', () async {
      expect(await decrypt(await encrypt('')), '');
    });

    test('it records the key generation it is encrypted under', () async {
      expect((await encrypt('hello', keyGeneration: 4)).keyGeneration, 4);
    });

    test('it decrypts only for its chat, message and sender', () async {
      final content = await encrypt('hello');

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

    test('moving a boundary between the ids changes what is bound', () async {
      final content = await cipher.encrypt(
        'hi',
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
      final content = await encrypt('hello');
      final json = content.toJson();

      expect(
        json.keys,
        unorderedEquals(['v', 'e', 'nonce', 'cipherText', 'mac']),
      );
      expect(json['v'], 1);
      expect(json['e'], 1);
      expect(json['nonce'], hasLength(16));
      expect(json['mac'], hasLength(24));
      expect(EncryptedContent.fromJson(jsonDecode(jsonEncode(json))), content);
    });

    test('the longest allowed message fits the rules size limit', () async {
      // Content allows 1000 UTF-16 code units. Three UTF-8 bytes per code unit
      // is the worst case, so the base64 ciphertext is at most 4000 characters.
      final json = (await encrypt('€' * 1000)).toJson();

      expect(json['cipherText'], hasLength(lessThanOrEqualTo(4000)));
    });

    test('plaintext or another version is not taken for encrypted', () {
      expect(() => EncryptedContent.fromJson('hello'), throwsFormatException);
      expect(
        () => EncryptedContent.fromJson({
          'v': 2,
          'e': 1,
          'nonce': '',
          'cipherText': '',
          'mac': '',
        }),
        throwsFormatException,
      );
    });
  });
}
