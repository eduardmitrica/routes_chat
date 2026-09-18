import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_changes.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

final _sentAt = DateTime.utc(2026, 9, 15, 12);

Message _message({
  String id = 'message-1',
  String text = 'Ne vedem mâine?',
  DateTime? sentAt,
  bool readable = true,
  bool deleted = false,
  KtList<MessageAttachment> attachments = const KtList.empty(),
}) => Message(
  id: UniqueId.fromUniqueString(id),
  senderId: UniqueId.fromUniqueString('alice'),
  imageUrls: const KtList.empty(),
  content: Content(text),
  attachments: attachments,
  lastUpdatedAt: sentAt ?? _sentAt,
  isEdited: false,
  isReadable: readable,
  isDeleted: deleted,
);

void main() {
  group('editing', () {
    test('the sender can edit a message for 15 minutes after sending', () {
      final message = _message();

      expect(
        message.canBeEditedBy(
          'alice',
          _sentAt.add(const Duration(minutes: 14, seconds: 59)),
        ),
        isTrue,
      );
      expect(
        message.canBeEditedBy('alice', _sentAt.add(messageEditWindow)),
        isFalse,
      );
    });

    test('nobody else can edit it', () {
      expect(_message().canBeEditedBy('bob', _sentAt), isFalse);
    });

    test('a voice message stays as it was recorded', () {
      final voice = _message(
        text: '',
        attachments: KtList.of(
          MessageAttachment(
            id: UniqueId.fromUniqueString('voice-1'),
            kind: AttachmentKind.voice,
            width: 0,
            height: 0,
            byteSize: 100,
            key: Uint8List(32),
            duration: const Duration(seconds: 3),
          ),
        ),
      );
      expect(voice.canBeEditedBy('alice', _sentAt), isFalse);
      expect(voice.canBeDeletedBy('alice'), isTrue);
    });

    test('a message on its way, unreadable or deleted is not edited', () {
      final onItsWay = Message(
        id: UniqueId.fromUniqueString('message-1'),
        senderId: UniqueId.fromUniqueString('alice'),
        imageUrls: const KtList.empty(),
        content: Content('Salut'),
        lastUpdatedAt: null,
        isEdited: false,
      );

      expect(onItsWay.canBeEditedBy('alice', _sentAt), isFalse);
      expect(
        _message(readable: false).canBeEditedBy('alice', _sentAt),
        isFalse,
      );
      expect(_message(deleted: true).canBeEditedBy('alice', _sentAt), isFalse);
    });

    test('the rules give an edit started in time a while to be saved', () {
      expect(messageEditSaveWindow, greaterThan(messageEditWindow));
    });
  });

  group('deleting', () {
    test('the sender can delete a message however old it is', () {
      final yearOld = _message(sentAt: DateTime.utc(2025, 9, 15));

      expect(yearOld.canBeDeletedBy('alice'), isTrue);
      expect(yearOld.canBeDeletedBy('bob'), isFalse);
    });

    test('a message deleted already is not deleted again', () {
      expect(_message(deleted: true).canBeDeletedBy('alice'), isFalse);
    });
  });

  group('reacting', () {
    test('is for a message that arrived and is not deleted', () {
      expect(_message().canBeReactedTo, isTrue);
      expect(_message(deleted: true).canBeReactedTo, isFalse);
      expect(_message(readable: false).canBeReactedTo, isFalse);
    });
  });

  group('a quote', () {
    final photo = MessageAttachment(
      id: UniqueId.fromUniqueString('photo-1'),
      kind: AttachmentKind.photo,
      width: 10,
      height: 10,
      byteSize: 100,
      key: Uint8List(32),
      thumbnail: Uint8List.fromList([1, 2, 3]),
    );

    test('of a deleted message keeps nothing of it', () {
      final original = _message(attachments: KtList.of(photo));
      final quote = MessageQuote.of(original);

      final followed = quote.following(
        original.copyWith(
          content: Content(''),
          attachments: const KtList.empty(),
          isDeleted: true,
        ),
      );

      expect(followed.messageId, quote.messageId);
      expect(followed.senderId, quote.senderId);
      expect(followed.text, isEmpty);
      expect(followed.thumbnail, isNull);
      expect(followed.originalDeleted, isTrue);
    });

    test('of an edited message shows its new text', () {
      final original = _message();

      final followed = MessageQuote.of(original).following(
        original.copyWith(
          content: Content('Ne vedem poimâine?'),
          isEdited: true,
        ),
      );

      expect(followed.text, 'Ne vedem poimâine?');
      expect(followed.originalDeleted, isFalse);
    });

    test('of a message not changed stays as the reply carries it', () {
      final quote = MessageQuote(
        messageId: UniqueId.fromUniqueString('message-1'),
        senderId: UniqueId.fromUniqueString('alice'),
        text: 'Ne vedem mâine?',
      );

      expect(quote.following(_message()), same(quote));
    });

    test('follows only the message it quotes', () {
      final quote = MessageQuote.of(_message());

      expect(
        quote.following(_message(id: 'message-2', deleted: true)),
        same(quote),
      );
    });
  });
}
