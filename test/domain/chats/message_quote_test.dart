import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

Message _message(String text) => Message(
  id: UniqueId.fromUniqueString('message-1'),
  senderId: UniqueId.fromUniqueString('uid-bob'),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content(text),
  lastUpdatedAt: null,
  isEdited: false,
);

void main() {
  test('a short message is quoted whole, with its id and sender', () {
    final quote = MessageQuote.of(_message('Ne vedem mâine?'));

    expect(quote.text, 'Ne vedem mâine?');
    expect(quote.messageId.getOrCrash(), 'message-1');
    expect(quote.senderId.getOrCrash(), 'uid-bob');
  });

  test('a message exactly as long as a quote is not cut', () {
    expect(MessageQuote.of(_message('a' * 100)).text, 'a' * 100);
  });

  test('a longer message is cut to the quote length, with an ellipsis', () {
    expect(MessageQuote.of(_message('a' * 300)).text, '${'a' * 100}…');
  });

  test('the cut never splits a character', () {
    // 👍🏽 is four UTF-16 code units, which do not fit after 98 letters.
    final quote = MessageQuote.of(_message('${'a' * 98}👍🏽 and more'));

    expect(quote.text, '${'a' * 98}…');
  });

  test('the cut does not leave a space before the ellipsis', () {
    final quote = MessageQuote.of(_message('${'a' * 99} and more'));

    expect(quote.text, '${'a' * 99}…');
  });

  test('what a quote says stays out of logs', () {
    expect(
      MessageQuote.of(_message('secret plans')).toString(),
      isNot(contains('secret')),
    );
  });
}
