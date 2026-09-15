import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/chat_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_data_transfer_object.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

void main() {
  final sentAt = Timestamp.fromDate(DateTime.utc(2026, 9, 15, 12));

  MessageDataTransferObject read(Map<String, dynamic> json) =>
      MessageDataTransferObject.fromJson(
        json,
      ).copyWith(id: 'message-1', timeStamp: sentAt.toDate());

  test('a deleted message reads as deleted, with nothing it said', () {
    final message = read({
      'senderId': 'alice',
      'serverTimeStamp': sentAt,
      'deleted': true,
    }).toDomain(content: 'what it said');

    expect(message.isDeleted, isTrue);
    expect(message.content.getOrCrash(), isEmpty);
    expect(message.attachments.isEmpty(), isTrue);
    expect(message.replyTo, isNull);
    expect(message.senderId.getOrCrash(), 'alice');
    expect(message.lastUpdatedAt, sentAt.toDate());
  });

  test('a message without content that is not deleted is malformed', () {
    final message = read({
      'senderId': 'alice',
      'serverTimeStamp': sentAt,
      'imageUrls': <String>[],
      'reactions': <String>[],
      'isEdited': false,
    });

    expect(() => message.encryptedContent, throwsFormatException);
  });

  test('a message sent is stored without a deleted mark or reactions', () {
    final json = MessageDataTransferObject.fromDomain(
      Message(
        id: UniqueId.fromUniqueString('message-1'),
        senderId: UniqueId.fromUniqueString('alice'),
        imageUrls: const KtList.empty(),
        content: Content('Salut'),
        lastUpdatedAt: null,
        isEdited: false,
      ),
      content: EncryptedContent(
        keyGeneration: 1,
        nonce: Uint8List(12),
        cipherText: Uint8List(5),
        mac: Uint8List(16),
      ),
    ).toJson();

    expect(json, isNot(contains('deleted')));
    expect(json['reactions'], isEmpty);
  });

  test("a chat's deleted last message reads as deleted", () {
    final lastMessage = const MessageDataTransferObjectConverter().fromJson({
      'id': 'message-1',
      'senderId': 'alice',
      'serverTimeStamp': sentAt,
      'deleted': true,
    });

    expect(lastMessage.isDeleted, isTrue);
    expect(lastMessage.content, isNull);
  });
}
