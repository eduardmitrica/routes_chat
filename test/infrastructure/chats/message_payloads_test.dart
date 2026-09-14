import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/messages/message_payloads.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

Message _message(
  String id,
  String senderId,
  String text, {
  MessageQuote? replyTo,
}) => Message(
  id: UniqueId.fromUniqueString(id),
  senderId: UniqueId.fromUniqueString(senderId),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content(text),
  replyTo: replyTo,
  lastUpdatedAt: null,
  isEdited: false,
);

void main() {
  final cipher = ChatCipher();

  test('a reply keeps what it quotes through encryption', () async {
    final original = _message('message-1', 'uid-bob', 'Ne vedem mâine?');
    final reply = _message(
      'message-2',
      'uid-alice',
      'Da, la 10',
      replyTo: MessageQuote.of(original),
    );
    final chatKey = cipher.newChatKey();

    final content = await cipher.encrypt(
      payloadOf(reply),
      chatKey: chatKey,
      chatId: 'uid-alice_uid-bob',
      keyGeneration: 1,
      messageId: 'message-2',
      senderId: 'uid-alice',
    );
    final payload = await cipher.decrypt(
      content,
      chatKey: chatKey,
      chatId: 'uid-alice_uid-bob',
      messageId: 'message-2',
      senderId: 'uid-alice',
    );

    expect(payload.text, 'Da, la 10');
    expect(quoteIn(payload), MessageQuote.of(original));
  });

  test('a message that is not a reply carries no quote', () {
    final payload = payloadOf(_message('message-1', 'uid-bob', 'Salut'));

    expect(payload, const MessagePayload('Salut'));
    expect(quoteIn(payload), isNull);
  });
}
