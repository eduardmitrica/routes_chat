import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

/// A chat key sealed and a message encrypted by a separate implementation of
/// the format in docs/e2ee.md, written with Node's crypto (OpenSSL) rather
/// than the `cryptography` package. It uses key generation 2 and recipient key
/// version 3, so both are known to be bound the same way. Every key here is a
/// throwaway made for this test.
///
/// If ChatCipher stops reading it, the stored format has changed: messages
/// already in Firestore would stop decrypting.
const _vector = {
  'recipientPrivateKey': '+P64+MGQjjOgVFqNiM1b5yHtnIp7/Qxk+unyvqHAbGw=',
  'recipientPublicKey': 'qubBnh2HkJ3mrYlUJ8fgcLAtMhlSplf5ri8EeECJbW0=',
  'chatId': 'alice_bob',
  'keyGeneration': 2,
  'recipientId': 'bob',
  'sealedChatKey': {
    'ephemeralPublicKey': 'RnC5ogLTzQHZUDIpbjX7qVzaSgqRJ+EMjiGral81+XM=',
    'nonce': '7vpwfq7bOzyNvFmK',
    'cipherText': 'XETrp07nMPxh0QRFDIQXXhCyf2uy3RzMHyOuJ6khx4k=',
    'mac': 't72mIuQVMJDQAhXhR4wpCw==',
    'keyVersion': 3,
  },
  'chatKey': 'cTUiZG9Zh4ir6OXiHxEot5lm91X1kI5PVqAYKwWsano=',
  'messageId': 'message-1',
  'senderId': 'alice',
  'content': {
    'v': 1,
    'e': 2,
    'nonce': 'ylmPG0fI81sQlEQ0',
    'cipherText': 'P0x6ylKvPCxXug4RiFL5HycwTylb1nMVuCP83AQ=',
    'mac': 'dCepylDgYJXjfQ246j7scw==',
  },
  'text': 'Salut din Node! 👋 ăîșț',
};

void main() {
  final cipher = ChatCipher();

  test('a chat key sealed by the other implementation opens', () async {
    final recipient = await X25519().newKeyPairFromSeed(
      base64Decode(_vector['recipientPrivateKey']! as String),
    );
    expect(
      (await recipient.extractPublicKey()).bytes,
      base64Decode(_vector['recipientPublicKey']! as String),
    );

    final chatKey = await cipher.open(
      SealedChatKey.fromJson(_vector['sealedChatKey']! as Map),
      recipientKeyPair: recipient,
      chatId: _vector['chatId']! as String,
      keyGeneration: _vector['keyGeneration']! as int,
      recipientId: _vector['recipientId']! as String,
    );

    expect(chatKey.bytes, base64Decode(_vector['chatKey']! as String));
  });

  test('a message encrypted by the other implementation decrypts', () async {
    final content = EncryptedContent.fromJson(_vector['content']);
    expect(content.keyGeneration, 2);

    final text = await cipher.decrypt(
      content,
      chatKey: SecretKeyData(base64Decode(_vector['chatKey']! as String)),
      chatId: _vector['chatId']! as String,
      messageId: _vector['messageId']! as String,
      senderId: _vector['senderId']! as String,
    );

    expect(text, _vector['text']);
  });
}
