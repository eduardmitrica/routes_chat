import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_payloads.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

final _voice = MessageAttachment(
  id: UniqueId.fromUniqueString('5b0b6f3e-7c1d-4a8e-9f0a-2b3c4d5e6f70'),
  kind: AttachmentKind.voice,
  width: 0,
  height: 0,
  byteSize: 56000,
  key: Uint8List.fromList(List.generate(32, (index) => index)),
  duration: const Duration(milliseconds: 7350),
  waveform: Uint8List.fromList(List.generate(64, (index) => index * 4)),
);

Message _messageWith(MessageAttachment attachment) => Message(
  id: UniqueId.fromUniqueString('message-1'),
  senderId: UniqueId.fromUniqueString('alice'),
  imageUrls: const KtList.empty(),
  content: Content(''),
  attachments: KtList.of(attachment),
  lastUpdatedAt: null,
  isEdited: false,
);

void main() {
  final cipher = ChatCipher();

  test('a voice message comes back with its length and waveform', () async {
    final chatKey = cipher.newChatKey();
    final content = await cipher.encrypt(
      payloadOf(_messageWith(_voice)),
      chatKey: chatKey,
      chatId: 'alice_bob',
      keyGeneration: 1,
      messageId: 'message-1',
      senderId: 'alice',
    );

    final payload = await cipher.decrypt(
      content,
      chatKey: chatKey,
      chatId: 'alice_bob',
      messageId: 'message-1',
      senderId: 'alice',
    );

    expect(attachmentsIn(payload).single(), _voice);
    expect(payload.summary, 'Voice message');
  });

  test('versions from before voice messages never see it among photos, '
      'so they show the message rather than failing it', () {
    final json = payloadOf(_messageWith(_voice)).toJson();

    expect(json.containsKey('attachments'), isFalse);
    expect((json['voice'] as Map)['kind'], 'voice');
    // What those versions accept for a photo's kind.
    final olderKinds = {'photo', 'gif'};
    final attachments = json['attachments'] as List? ?? const [];
    expect(
      attachments.every((file) => olderKinds.contains((file as Map)['kind'])),
      isTrue,
    );
  });

  test('its length and waveform travel only inside the encryption', () async {
    final content = await cipher.encrypt(
      payloadOf(_messageWith(_voice)),
      chatKey: cipher.newChatKey(),
      chatId: 'alice_bob',
      keyGeneration: 1,
      messageId: 'message-1',
      senderId: 'alice',
    );

    final stored = jsonEncode(content.toJson());
    expect(stored, isNot(contains('durationMs')));
    expect(stored, isNot(contains('waveform')));
  });

  test('a voice file in the wrong place is refused', () {
    final file = payloadOf(_messageWith(_voice)).voice!.toJson();

    expect(
      () => MessagePayload.fromJson({
        'text': '',
        'attachments': [file],
      }),
      throwsFormatException,
    );
    expect(
      () => MessagePayload.fromJson({
        'text': '',
        'voice': {...file, 'kind': 'photo'},
      }),
      throwsFormatException,
    );
  });
}
