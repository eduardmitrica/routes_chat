import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

MessageAttachment _attachment(
  AttachmentKind kind, {
  Uint8List? thumbnail,
  int width = 400,
  int height = 300,
}) => MessageAttachment(
  id: UniqueId(),
  kind: kind,
  width: width,
  height: height,
  byteSize: 1000,
  key: Uint8List.fromList(List.generate(32, (index) => index)),
  thumbnail: thumbnail,
);

Message _message(String text, List<MessageAttachment> attachments) => Message(
  id: UniqueId.fromUniqueString('message-1'),
  senderId: UniqueId.fromUniqueString('uid-bob'),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content(text),
  attachments: attachments.toImmutableList(),
  lastUpdatedAt: null,
  isEdited: false,
);

void main() {
  const photo = AttachmentKind.photo;
  const gif = AttachmentKind.gif;

  test('photos and GIFs are described in a few words', () {
    expect(describeAttachments([]), '');
    expect(describeAttachments([photo]), 'Photo');
    expect(describeAttachments([photo, photo, photo]), '3 photos');
    expect(describeAttachments([gif]), 'GIF');
    expect(describeAttachments([gif, gif]), '2 GIFs');
    expect(describeAttachments([photo, gif]), '2 photos and GIFs');
  });

  test('a message is summed up by its text, or by what it holds', () {
    expect(summaryOf('Uite!', [photo]), 'Uite!');
    expect(summaryOf('', [photo, photo]), '2 photos');
    expect(summaryOf('   ', [gif]), 'GIF');
  });

  test('a reply to a photo without a caption says Photo and shows it', () {
    final preview = Uint8List.fromList([1, 2, 3]);
    final quote = MessageQuote.of(
      _message('', [
        _attachment(photo, thumbnail: preview),
        _attachment(photo),
      ]),
    );

    expect(quote.text, '2 photos');
    expect(quote.thumbnail, preview);
  });

  test('a reply to a photo with a caption quotes the caption', () {
    final quote = MessageQuote.of(_message('La mare', [_attachment(gif)]));

    expect(quote.text, 'La mare');
  });

  test('a reply to a text message has no preview', () {
    expect(MessageQuote.of(_message('Salut', [])).thumbnail, isNull);
  });

  test('a photo of unknown size is shown square', () {
    expect(_attachment(photo, width: 0, height: 0).aspectRatio, 1);
    expect(_attachment(photo, width: 400, height: 200).aspectRatio, 2);
  });

  test('the key and the preview of a photo stay out of logs', () {
    final attachment = _attachment(photo, thumbnail: Uint8List(8));

    expect(
      attachment.toString(),
      isNot(contains(base64Encode(attachment.key))),
    );
    expect(attachment.toString(), isNot(contains('AAAA')));
  });
}
