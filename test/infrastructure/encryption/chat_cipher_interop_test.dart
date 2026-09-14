import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

/// A chat key sealed and a message encrypted by a separate implementation of
/// the format in docs/e2ee.md, written with Node's crypto (OpenSSL) rather
/// than the `cryptography` package. Every key here is a throwaway made for
/// this test.
///
/// If ChatCipher stops reading it, the stored format has changed: messages
/// already in Firestore would stop decrypting.
const _vector = {
  'recipientPrivateKey': '+CnSQhAQKfb3v+TnezFFDljrjDYHfhUfBXUwo233lFs=',
  'recipientPublicKey': 'JN0Zxk9Oqme7NHQCp2jxEb0C9R0eUP58oJ40KVrb+HQ=',
  'chatId': 'alice_bob',
  'recipientId': 'bob',
  'sealedChatKey': {
    'ephemeralPublicKey': 'nQxfBleFLQ3l3sIbts/H4EKBw27+oCVuMaW6x6HS7QQ=',
    'nonce': 'HtS9/XhvfD/H9Egj',
    'cipherText': '93JijEXjwoTEuxpQFNT86UTwlQzPWId3cKwjBtmZ0zk=',
    'mac': 'htqxa/fCfjYonyX6tI3oTw==',
  },
  'chatKey': 'hmKJMZwe37m9CLHLjQHmAZmp8OYBVhhWPEs1KMnBz88=',
  'messageId': 'message-1',
  'senderId': 'alice',
  'content': {
    'v': 1,
    'nonce': '6IOx7tWsggza4Q1Z',
    'cipherText': 'oDmNnarRkwCHxvdaXXMyVAIvhpQpMEnjDy2KGbc=',
    'mac': 'tbHX1JJUgIV+F3LUKMr8Bw==',
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
      recipientId: _vector['recipientId']! as String,
    );

    expect(chatKey.bytes, base64Decode(_vector['chatKey']! as String));
  });

  test('a message encrypted by the other implementation decrypts', () async {
    final text = await cipher.decrypt(
      EncryptedContent.fromJson(_vector['content']),
      chatKey: SecretKeyData(base64Decode(_vector['chatKey']! as String)),
      chatId: _vector['chatId']! as String,
      messageId: _vector['messageId']! as String,
      senderId: _vector['senderId']! as String,
    );

    expect(text, _vector['text']);
  });
}
