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

/// A version 2 message, a reply, encrypted by the same separate
/// implementation: JSON built by Node's JSON.stringify, with a quote holding a
/// quotation mark, a newline and an emoji with a skin tone.
const _replyVector = {
  'chatKey': 'CtYG+Izq+c2drflPL2ied+HdchSoT7s1vCHYr7h1Kq8=',
  'chatId': 'alice_bob',
  'messageId': 'message-1',
  'senderId': 'alice',
  'content': {
    'v': 2,
    'e': 2,
    'nonce': 'vqVszKE/PBj1JQnO',
    'cipherText':
        'Z2gBvikkNAKCiIU5+kR7fRTfB9Sf8acujSg/AOqXDhcFzEel/IdpgmNQRG3GPpl98dUuDeSSONxf/wdzDfY/Zfo7ExFXVKNDsEbwbrvSjKd0G8MfRSyuPD0rwMBJg0M4zdAzkTLwJItfzp+Pn1wH8fqqzVAkAC+SbzOj3gmo',
    'mac': 'Og/iKQnBCFLCTFfeS+ouyw==',
  },
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

    final payload = await cipher.decrypt(
      content,
      chatKey: SecretKeyData(base64Decode(_vector['chatKey']! as String)),
      chatId: _vector['chatId']! as String,
      messageId: _vector['messageId']! as String,
      senderId: _vector['senderId']! as String,
    );

    expect(payload, MessagePayload(_vector['text']! as String));
  });

  test('a reply encrypted by the other implementation decrypts', () async {
    final payload = await cipher.decrypt(
      EncryptedContent.fromJson(_replyVector['content']),
      chatKey: SecretKeyData(base64Decode(_replyVector['chatKey']! as String)),
      chatId: _replyVector['chatId']! as String,
      messageId: _replyVector['messageId']! as String,
      senderId: _replyVector['senderId']! as String,
    );

    expect(
      payload,
      const MessagePayload(
        'Salut din Node! 👋 ăîșț',
        replyTo: QuotedMessage(
          messageId: 'message-0',
          senderId: 'bob',
          text: 'Ne vedem "mâine"?\n👍🏽',
        ),
      ),
    );
  });

  test('a photo encrypted by the other implementation decrypts', () async {
    // Node's AES-256-GCM, a key of the file's own, stored as nonce, ciphertext
    // and tag, with associated data routes_chat/v2/file, chat id, file id.
    const file = {
      'chatId': 'alice_bob',
      'fileId': 'file-1',
      'key': 'wis7hJscslkEl+C6vBmnrmB5LFgxhb1VugIM23BevYY=',
      'stored':
          'sCfk4MI6Gce6g0AuXp8CnYZFyi9GP+TTxeHZ4D3bUGoDA8bvSXypuLomUncBdmouZkYK7W1jOD64L4trfMkx',
      'content': 'R0lGODlhIHJvdXRlc19jaGF0IGZpbGUgdmVjdG9yIPCfkYs=',
    };

    final content = await cipher.decryptFile(
      base64Decode(file['stored']!),
      key: base64Decode(file['key']!),
      chatId: file['chatId']!,
      fileId: file['fileId']!,
    );

    expect(content, base64Decode(file['content']!));
  });
}
