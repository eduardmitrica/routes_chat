import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/chat_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

final _message = Message(
  id: UniqueId.fromUniqueString('message-1'),
  senderId: UniqueId.fromUniqueString('user-a'),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content('hello'),
  repliedMessageId: UniqueId.empty(),
  lastUpdatedAt: null,
  isEdited: false,
);

final _content = EncryptedContent(
  keyGeneration: 1,
  nonce: Uint8List(12),
  cipherText: Uint8List(5),
  mac: Uint8List(16),
);

final _sealed = SealedChatKey(
  ephemeralPublicKey: Uint8List(32),
  nonce: Uint8List(12),
  cipherText: Uint8List(32),
  mac: Uint8List(16),
  recipientKeyVersion: 1,
);

final _generation = KeyGeneration(
  createdBy: 'user-a',
  sealedKeys: {'user-a': _sealed, 'user-b': _sealed},
);

Map<String, dynamic> _storedChat() => ChatDataTransferObject.fromDomain(
  Chat(
    id: UniqueId.fromUniqueString('user-a_user-b'),
    participantsList: ParticipantsList(
      KtList.of(
        Tuple2(UniqueId.fromUniqueString('user-a'), UniqueId.empty()),
        Tuple2(UniqueId.fromUniqueString('user-b'), UniqueId.empty()),
      ),
    ),
    lastMessage: _message,
  ),
  lastMessageContent: _content,
  firstKeyGeneration: _generation,
).toJson();

final _rules = File('firestore.rules').readAsStringSync();

/// The string list a rules function such as `chatFields()` returns.
Set<String> _listReturnedBy(String function) {
  final body = RegExp(
    'function $function\\(\\)\\s*\\{\\s*return\\s*\\[([^\\]]*)\\]',
  ).firstMatch(_rules);
  expect(body, isNotNull, reason: '$function() not found in firestore.rules');
  return RegExp(
    r"'([^']+)'",
  ).allMatches(body!.group(1)!).map((match) => match.group(1)!).toSet();
}

void main() {
  // The rules use keys().hasOnly(...) on chats and messages. A field added to
  // a DTO but not to the rules would make every chat or message write fail in
  // production while the app still compiles.

  test('a stored chat has exactly the fields chatFields() allows', () {
    expect(_storedChat().keys.toSet(), _listReturnedBy('chatFields'));
  });

  test('a stored message has exactly the fields messageFields() allows', () {
    final json = MessageDataTransferObject.fromDomain(
      _message,
      content: _content,
    ).toJson();

    expect(json.keys.toSet(), _listReturnedBy('messageFields'));
  });

  test("a chat's last message has messageFields() and its id", () {
    final lastMessage = _storedChat()['lastMessage'] as Map<String, dynamic>;

    expect(lastMessage.keys.toSet(), {
      ..._listReturnedBy('messageFields'),
      'id',
    });
  });

  test('a new chat starts at key generation 1, as the rules require', () {
    final chat = _storedChat();

    expect(chat['currentKeyGeneration'], 1);
    expect((chat['keyGenerations'] as Map).keys, ['1']);
    expect(_rules, contains('request.resource.data.currentKeyGeneration == 1'));
    expect(
      _rules,
      contains("request.resource.data.keyGenerations.keys().hasOnly(['1'])"),
    );
  });

  test('the rules check the encrypted formats the app writes', () {
    // Sizes are base64 lengths, checked against real output in
    // chat_cipher_test.dart.
    for (final check in [
      "content.keys().hasOnly(['v', 'e', 'nonce', 'cipherText', 'mac'])",
      'content.v == 1',
      'content.e == generation',
      'content.nonce.size() == 16',
      'content.mac.size() == 24',
      'content.cipherText.size() <= 4000',
      "'cipherText', 'mac', 'keyVersion']",
      'sealed.ephemeralPublicKey.size() == 44',
      'sealed.nonce.size() == 16',
      'sealed.cipherText.size() == 44',
      'sealed.mac.size() == 24',
      'sealed.keyVersion is int',
      "generation.keys().hasOnly(['createdBy', 'sealedKeys'])",
    ]) {
      expect(_rules, contains(check));
    }
    expect(_content.toJson().keys.toSet(), {
      'v',
      'e',
      'nonce',
      'cipherText',
      'mac',
    });
    expect(_sealed.toJson().keys.toSet(), {
      'ephemeralPublicKey',
      'nonce',
      'cipherText',
      'mac',
      'keyVersion',
    });
    expect(_generation.toJson().keys.toSet(), {'createdBy', 'sealedKeys'});
  });
}
