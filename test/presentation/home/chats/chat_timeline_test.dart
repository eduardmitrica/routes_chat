import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/key_reset.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_timeline.dart';

Message _message(String id, {int generation = 1, bool readable = true}) =>
    Message(
      id: UniqueId.fromUniqueString(id),
      senderId: UniqueId.fromUniqueString('alice'),
      imageUrls: const KtList.empty(),
      reactions: const KtList.empty(),
      content: Content(id),
      repliedMessageId: UniqueId.empty(),
      lastUpdatedAt: null,
      isEdited: false,
      isReadable: readable,
      keyGeneration: generation,
    );

KeyReset _resetBy(String userId, int generation) => KeyReset(
  userId: UniqueId.fromUniqueString(userId),
  keyGeneration: generation,
);

void main() {
  test('readable messages are listed as they are', () {
    final first = _message('first');
    final second = _message('second');

    expect(chatTimeline(KtList.of(first, second), const KtList.empty()), [
      MessageItem(first),
      MessageItem(second),
    ]);
  });

  test('each run of unreadable messages becomes one row', () {
    final readable = _message('readable');

    expect(
      chatTimeline(
        KtList.of(
          _message('a', readable: false),
          _message('b', readable: false),
          readable,
          _message('c', readable: false),
        ),
        const KtList.empty(),
      ),
      [
        const UnreadableMessagesItem(2),
        MessageItem(readable),
        const UnreadableMessagesItem(1),
      ],
    );
  });

  test('a reset comes before the first message under its generation', () {
    final before = _message('before');
    final after = _message('after', generation: 2);
    final reset = _resetBy('bob', 2);

    expect(chatTimeline(KtList.of(before, after), KtList.of(reset)), [
      MessageItem(before),
      KeyResetItem(reset),
      MessageItem(after),
    ]);
  });

  test('a reset with no message after it yet comes last', () {
    final before = _message('before');
    final reset = _resetBy('bob', 2);

    expect(chatTimeline(KtList.of(before), KtList.of(reset)), [
      MessageItem(before),
      KeyResetItem(reset),
    ]);
  });

  test('the messages a reset made unreadable stay above the reset', () {
    final after = _message('after', generation: 2);
    final reset = _resetBy('alice', 2);

    expect(
      chatTimeline(
        KtList.of(
          _message('old', readable: false),
          _message('older', readable: false),
          after,
        ),
        KtList.of(reset),
      ),
      [
        const UnreadableMessagesItem(2),
        KeyResetItem(reset),
        MessageItem(after),
      ],
    );
  });

  test('resets are placed in generation order', () {
    final first = _message('first');
    final latest = _message('latest', generation: 3);
    final byBob = _resetBy('bob', 2);
    final byAlice = _resetBy('alice', 3);

    expect(chatTimeline(KtList.of(first, latest), KtList.of(byAlice, byBob)), [
      MessageItem(first),
      KeyResetItem(byBob),
      KeyResetItem(byAlice),
      MessageItem(latest),
    ]);
  });
}
