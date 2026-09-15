import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/outbox/message_outbox.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../helpers/outbox_fakes.dart';
import '../../helpers/unused_media_repository.dart';

Message _fromBob(String id, String text) => Message(
  id: UniqueId.fromUniqueString(id),
  senderId: UniqueId.fromUniqueString('uid-bob'),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content(text),
  lastUpdatedAt: DateTime.utc(2026, 9, 14),
  isEdited: false,
);

void main() {
  late FakeMessageSender messages;
  late ChatBarBloc bloc;

  setUp(() async {
    messages = FakeMessageSender();
    final store = MemoryChatStore();
    final session = signedInAlice();
    addTearDown(session.end);
    bloc = ChatBarBloc(
      session,
      UnusedMediaRepository(),
      store,
      MessageOutbox(messages, FakeChatStarter(), store, session),
    );
    addTearDown(bloc.close);
    bloc.add(ChatBarEvent.started(UniqueId.fromUniqueString('uid-bob')));
    await pumpEventQueue();
  });

  Future<void> send(ChatBarEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  ChatBarEvent sent(String text) => ChatBarEvent.sent(text, chatExists: true);

  test('a message sent while replying carries the quote', () async {
    final original = _fromBob('message-1', 'Ne vedem mâine?');

    await send(ChatBarEvent.replyStarted(original));
    expect(bloc.state.replyingTo, MessageQuote.of(original));
    await send(sent('Da!'));

    expect(messages.sent.single.replyTo, MessageQuote.of(original));
    expect(bloc.state.replyingTo, isNull);
  });

  test('only the next message is a reply', () async {
    await send(ChatBarEvent.replyStarted(_fromBob('message-1', 'Salut')));
    await send(sent('Da!'));
    await send(sent('Și tu?'));

    expect(messages.sent.last.replyTo, isNull);
  });

  test('a cancelled reply sends the message on its own', () async {
    await send(ChatBarEvent.replyStarted(_fromBob('message-1', 'Salut')));
    await send(const ChatBarEvent.replyCancelled());
    await send(sent('Da!'));

    expect(messages.sent.single.replyTo, isNull);
  });

  test('replying to another message replaces the first', () async {
    final second = _fromBob('message-2', 'Sau poimâine?');

    await send(ChatBarEvent.replyStarted(_fromBob('message-1', 'Mâine?')));
    await send(ChatBarEvent.replyStarted(second));
    await send(sent('Poimâine'));

    expect(messages.sent.single.replyTo, MessageQuote.of(second));
  });
}
