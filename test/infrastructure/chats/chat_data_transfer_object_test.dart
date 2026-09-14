import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/key_reset.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/chat_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

Chat _chatBetween(List<String> participantIds) => Chat(
  id: UniqueId.fromUniqueString('chat-1'),
  participantsList: ParticipantsList(
    participantIds
        .map(
          (id) => Tuple2(
            UniqueId.fromUniqueString(id),
            UniqueId.fromUniqueString('last-seen-$id'),
          ),
        )
        .toImmutableList(),
  ),
  lastMessage: Message(
    id: UniqueId.fromUniqueString('message-1'),
    senderId: UniqueId.fromUniqueString(participantIds.first),
    imageUrls: const KtList.empty(),
    reactions: const KtList.empty(),
    content: Content('hello'),

    lastUpdatedAt: null,
    isEdited: false,
  ),
);

ChatDataTransferObject _stored(Chat chat) => ChatDataTransferObject.fromDomain(
  chat,
  lastMessageContent: EncryptedContent(
    keyGeneration: 1,
    nonce: Uint8List(12),
    cipherText: Uint8List(5),
    mac: Uint8List(16),
  ),
  firstKeyGeneration: const KeyGeneration(createdBy: 'user-a', sealedKeys: {}),
);

void main() {
  // firestore.rules enforces chat writes with
  // `request.auth.uid in request.resource.data.participantIds`. If this field
  // ever drifts from `participants`, every chat write is denied in production
  // while everything still compiles.
  test('participantIds mirrors the ids in participants', () {
    final dto = _stored(_chatBetween(['user-a', 'user-b']));

    expect(dto.participantIds, ['user-a', 'user-b']);
    expect(
      dto.participantIds,
      dto.participants.map((participant) => participant.keys.single).toList(),
      reason: 'participantIds must contain exactly the keys of participants',
    );
  });

  test('participantIds is carried into the Firestore payload', () {
    final json = _stored(_chatBetween(['user-a', 'user-b'])).toJson();

    expect(json['participantIds'], ['user-a', 'user-b']);
  });

  test('participantIds covers group chats, not just pairs', () {
    final dto = _stored(_chatBetween(['user-a', 'user-b', 'user-c']));

    expect(dto.participantIds, ['user-a', 'user-b', 'user-c']);
  });

  test('the last message is stored encrypted, never as its text', () {
    final json = _stored(_chatBetween(['user-a', 'user-b'])).toJson();
    final lastMessage = json['lastMessage'] as Map<String, dynamic>;

    expect(lastMessage['content'], isA<Map<String, Object>>());
    expect(json.toString(), isNot(contains('hello')));
  });

  test('every key generation after the first is a key reset', () {
    // Generation 1 comes with the chat; a participant adds each later one
    // after resetting their keys.
    final dto = _stored(_chatBetween(['user-a', 'user-b'])).copyWith(
      keyGenerations: const {
        3: KeyGeneration(createdBy: 'user-a', sealedKeys: {}),
        1: KeyGeneration(createdBy: 'user-a', sealedKeys: {}),
        2: KeyGeneration(createdBy: 'user-b', sealedKeys: {}),
      },
      currentKeyGeneration: 3,
    );

    final chat = dto.toDomain(
      lastMessageContent: 'hello',
      lastMessageReadable: true,
    );

    expect(
      chat.keyResets,
      KtList.of(
        KeyReset(userId: UniqueId.fromUniqueString('user-b'), keyGeneration: 2),
        KeyReset(userId: UniqueId.fromUniqueString('user-a'), keyGeneration: 3),
      ),
    );
  });
}
