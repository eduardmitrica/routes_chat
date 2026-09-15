import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

const _chatId = 'alice_bob';

void main() {
  final cipher = ChatCipher();
  late SecretKeyData chatKey;

  setUp(() => chatKey = cipher.newChatKey());

  Future<EncryptedContent> encrypt(String emoji, {int keyGeneration = 1}) =>
      cipher.encryptReaction(
        emoji,
        chatKey: chatKey,
        chatId: _chatId,
        keyGeneration: keyGeneration,
        messageId: 'message-1',
        reactorId: 'bob',
      );

  Future<String> decrypt(
    EncryptedContent content, {
    SecretKey? key,
    String chatId = _chatId,
    String messageId = 'message-1',
    String reactorId = 'bob',
  }) => cipher.decryptReaction(
    content,
    chatKey: key ?? chatKey,
    chatId: chatId,
    messageId: messageId,
    reactorId: reactorId,
  );

  test('the emoji comes back as it was, skin tone and all', () async {
    expect(await decrypt(await encrypt('👍🏽')), '👍🏽');
  });

  test('every reaction is as long, in the shape the rules require', () async {
    for (final emoji in ['❤️', '👍', '👩🏽‍❤️‍💋‍👨🏿', '🏴󠁧󠁢󠁳󠁣󠁴󠁿']) {
      final json = (await encrypt(emoji)).toJson();

      expect(
        json.keys,
        unorderedEquals(['v', 'e', 'nonce', 'cipherText', 'mac']),
      );
      expect(json['v'], 1);
      expect(json['nonce'], hasLength(16));
      expect(json['mac'], hasLength(24));
      expect(
        json['cipherText'],
        hasLength(
          base64Encode(Uint8List(ChatCipher.reactionPayloadBytes)).length,
        ),
        reason: 'the length would tell which emoji it is',
      );
    }
  });

  test('it opens only for its chat, message and person', () async {
    final content = await encrypt('❤️');

    for (final attempt in [
      () => decrypt(content, chatId: 'alice_carol'),
      () => decrypt(content, messageId: 'message-2'),
      () => decrypt(content, reactorId: 'alice'),
      () => decrypt(content, key: cipher.newChatKey()),
    ]) {
      await expectLater(attempt(), throwsA(isA<UnreadableCiphertext>()));
    }
  });

  test('its key generation cannot be changed', () async {
    final content = await encrypt('❤️');
    final relabelled = EncryptedContent(
      version: 1,
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

  test('a message cannot pass for a reaction', () async {
    final message = await cipher.encrypt(
      const MessagePayload('❤️'),
      chatKey: chatKey,
      chatId: _chatId,
      keyGeneration: 1,
      messageId: 'message-1',
      senderId: 'bob',
    );
    final relabelled = EncryptedContent(
      version: 1,
      keyGeneration: 1,
      nonce: message.nonce,
      cipherText: message.cipherText,
      mac: message.mac,
    );

    await expectLater(decrypt(message), throwsA(isA<UnreadableCiphertext>()));
    await expectLater(
      decrypt(relabelled),
      throwsA(isA<UnreadableCiphertext>()),
    );
  });

  test('nothing, or more than an emoji, is refused', () async {
    await expectLater(encrypt(''), throwsArgumentError);
    await expectLater(encrypt('😀' * 20), throwsArgumentError);
  });
}
