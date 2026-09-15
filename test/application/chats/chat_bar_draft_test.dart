import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/outbox/message_outbox.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

import '../../helpers/outbox_fakes.dart';

/// Prepares every path as a photo.
class _PreparedMedia implements IMediaRepository {
  @override
  Future<Either<MediaFailure, MediaDraft>> prepare(String path) async =>
      Right(photoDraft('draft-$path'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MemoryChatStore store;
  late FakeMessageSender sender;
  late CurrentUserSession session;
  late MessageOutbox outbox;
  final bob = UniqueId.fromUniqueString('uid-bob');

  setUp(() {
    store = MemoryChatStore();
    sender = FakeMessageSender();
    session = signedInAlice();
    outbox = MessageOutbox(
      sender,
      FakeChatStarter(),
      store,
      session,
      retryDelays: const [Duration(hours: 1)],
    );
    addTearDown(session.end);
  });

  Future<ChatBarBloc> open() async {
    final bloc = ChatBarBloc(
      session,
      _PreparedMedia(),
      store,
      outbox,
      draftDelay: const Duration(milliseconds: 10),
    );
    addTearDown(bloc.close);
    bloc.add(ChatBarEvent.started(bob));
    await pumpEventQueue();
    return bloc;
  }

  Future<void> send(ChatBarBloc bloc, ChatBarEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  ChatDraft? draft() => store.drafts[aliceAndBob];

  test('what the user types is kept as a draft once they pause', () async {
    final bloc = await open();

    await send(bloc, const ChatBarEvent.messageContentChanged('Ne vedem'));
    expect(draft(), isNull);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(draft()?.text, 'Ne vedem');
  });

  test('a reply and photos are kept straight away', () async {
    final bloc = await open();
    final original = outgoingMessage('message-1', text: 'Unde ești?').message;

    await send(bloc, ChatBarEvent.replyStarted(original));
    await send(bloc, const ChatBarEvent.mediaPicked(['a.jpg']));

    expect(draft()?.replyTo, MessageQuote.of(original));
    expect(draft()?.media.single().id.getOrCrash(), 'draft-a.jpg');
  });

  test('the draft comes back when the chat opens again', () async {
    final quote = MessageQuote(
      messageId: UniqueId.fromUniqueString('message-1'),
      senderId: bob,
      text: 'Unde ești?',
      thumbnail: Uint8List.fromList([1]),
    );
    store.drafts[aliceAndBob] = ChatDraft(
      text: 'Aici',
      replyTo: quote,
      media: KtList.of(photoDraft('a')),
    );

    final bloc = await open();

    expect(bloc.state.chatId?.getOrCrash(), aliceAndBob);
    expect(bloc.state.text, 'Aici');
    expect(bloc.state.textRevision, 1);
    expect(bloc.state.replyingTo, quote);
    expect(bloc.state.media.single().id.getOrCrash(), 'a');
  });

  test('what was typed just before leaving the chat is kept', () async {
    final bloc = await open();

    await send(bloc, const ChatBarEvent.messageContentChanged('Ne vedem'));
    await bloc.close();

    expect(draft()?.text, 'Ne vedem');
  });

  test('sending empties the draft and puts the message on its way', () async {
    final bloc = await open();
    await send(bloc, const ChatBarEvent.messageContentChanged('Salut'));
    await send(bloc, const ChatBarEvent.mediaPicked(['a.jpg']));

    await send(bloc, const ChatBarEvent.sent('Salut', chatExists: true));

    expect(draft(), isNull);
    expect(bloc.state.text, '');
    expect(bloc.state.media.isEmpty(), isTrue);
    expect(sender.sent.single.content.getOrCrash(), 'Salut');
    expect(sender.sent.single.attachments.size, 1);
  });

  test('a message not sent yet stays below the chat', () async {
    final bloc = await open();
    sender.sendFailures.add(Unexpected());

    await send(bloc, const ChatBarEvent.sent('Salut', chatExists: true));

    final entry = bloc.state.outgoing.single();
    expect(entry.status, OutgoingStatus.waiting);
    expect(entry.message.content.getOrCrash(), 'Salut');
  });

  test('a message not sent can be sent again or given up', () async {
    final bloc = await open();
    sender.sendFailures.addAll([Unexpected(), Unexpected()]);
    await send(bloc, const ChatBarEvent.sent('Salut', chatExists: true));
    final first = bloc.state.outgoing.single().id;
    await send(bloc, ChatBarEvent.retryRequested(first));
    expect(sender.log.where((entry) => entry.startsWith('send')), hasLength(2));
    expect(bloc.state.outgoing.single().status, OutgoingStatus.waiting);

    await send(bloc, ChatBarEvent.discardRequested(first));

    expect(bloc.state.outgoing.isEmpty(), isTrue);
    expect(bloc.state.discardsRefused, 0);
    expect(sender.sent, isEmpty);
  });

  test('a message being sent is not given up, and the page is told', () async {
    final bloc = await open();
    sender.gate = Completer();
    await send(bloc, const ChatBarEvent.sent('Salut', chatExists: true));

    await send(
      bloc,
      ChatBarEvent.discardRequested(bloc.state.outgoing.single().id),
    );

    expect(bloc.state.discardsRefused, 1);
    sender.gate!.complete();
    await pumpEventQueue();
    expect(sender.sent, hasLength(1));
    expect(bloc.state.outgoing.isEmpty(), isTrue);
  });
}
