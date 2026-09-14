import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/key_reset.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_timeline.dart';

Message _message(String id, {int generation = 1}) => Message(
  id: UniqueId.fromUniqueString(id),
  senderId: UniqueId.fromUniqueString('alice'),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content(id),
  repliedMessageId: UniqueId.empty(),
  lastUpdatedAt: null,
  isEdited: false,
  keyGeneration: generation,
);

KeyReset _resetBy(String userId, int generation) => KeyReset(
  userId: UniqueId.fromUniqueString(userId),
  keyGeneration: generation,
);

void main() {
  // With only the latest messages loaded, a reset that would come before the
  // first of them may really belong anywhere in the older, unloaded part.

  test('a reset before the oldest loaded message waits for older pages', () {
    final first = _message('first', generation: 2);
    final reset = _resetBy('bob', 2);

    expect(
      chatTimeline(KtList.of(first), KtList.of(reset), reachStart: false),
      [MessageItem(first)],
    );
    expect(chatTimeline(KtList.of(first), KtList.of(reset)), [
      KeyResetItem(reset),
      MessageItem(first),
    ]);
  });

  test('a reset between loaded messages shows before the start is loaded', () {
    final before = _message('before');
    final after = _message('after', generation: 2);
    final reset = _resetBy('bob', 2);

    expect(
      chatTimeline(
        KtList.of(before, after),
        KtList.of(reset),
        reachStart: false,
      ),
      [MessageItem(before), KeyResetItem(reset), MessageItem(after)],
    );
  });

  test('a reset after the newest loaded message still shows', () {
    final before = _message('before');
    final reset = _resetBy('bob', 2);

    expect(
      chatTimeline(KtList.of(before), KtList.of(reset), reachStart: false),
      [MessageItem(before), KeyResetItem(reset)],
    );
  });

  test('with nothing loaded, resets wait unless the chat is empty', () {
    final reset = _resetBy('bob', 2);

    expect(
      chatTimeline(const KtList.empty(), KtList.of(reset), reachStart: false),
      isEmpty,
    );
    expect(chatTimeline(const KtList.empty(), KtList.of(reset)), [
      KeyResetItem(reset),
    ]);
  });
}
