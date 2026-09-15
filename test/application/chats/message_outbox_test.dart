import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/outbox/message_outbox.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart' as chat_failure;
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

import '../../helpers/outbox_fakes.dart';

void main() {
  late ActionLog log;
  late MemoryChatStore store;
  late FakeMessageSender sender;
  late FakeChatStarter chats;
  late CurrentUserSession session;
  late StreamController<void> reconnected;

  setUp(() {
    log = [];
    store = MemoryChatStore(log);
    sender = FakeMessageSender(log);
    chats = FakeChatStarter(log);
    session = signedInAlice();
    reconnected = StreamController<void>.broadcast();
    // Signing out also stops the pauses still running.
    addTearDown(session.end);
    addTearDown(reconnected.close);
  });

  /// An outbox whose pause before each retry is [pause]: an hour unless a
  /// test waits for it.
  MessageOutbox outbox({Duration pause = const Duration(hours: 1)}) =>
      MessageOutbox(
        sender,
        chats,
        store,
        session,
        reconnected: reconnected.stream,
        retryDelays: [pause],
      );

  Future<List<OutgoingMessage>> onItsWay(
    MessageOutbox outbox, [
    String chatId = aliceAndBob,
  ]) async =>
      (await outbox.watch(UniqueId.fromUniqueString(chatId)).first).asList();

  OutgoingStatus? statusOf(String id) => store.kept[id]?.status;

  List<String> sentIds() => [for (final m in sender.sent) m.id.getOrCrash()];

  test('a message is kept on the phone until it has been sent', () async {
    final messages = outbox();
    sender.gate = Completer();

    await messages.enqueue(outgoingMessage('m1'));
    await pumpEventQueue();

    expect(store.kept.keys, ['m1']);
    expect((await onItsWay(messages)).single.status, OutgoingStatus.sending);

    sender.gate!.complete();
    await pumpEventQueue();

    expect(sentIds(), ['m1']);
    expect(store.kept, isEmpty);
    expect(await onItsWay(messages), isEmpty);
  });

  test(
    'photos upload one by one, then the message that carries them',
    () async {
      await outbox().enqueue(
        outgoingMessage('m1', media: [photoDraft('a'), photoDraft('b')]),
      );
      await pumpEventQueue();

      expect(log.where((entry) => !entry.startsWith('keep')), [
        'upload a',
        'upload b',
        'send m1',
      ]);
      final attachments = sender.sent.single.attachments.asList();
      expect(
        [for (final file in attachments) file.id.getOrCrash()],
        ['a', 'b'],
      );
      expect(
        [for (final file in attachments) file.key],
        [for (final (_, key) in sender.uploads) key],
      );
    },
  );

  test('a photo is uploaded only once its key is kept on the phone', () async {
    await outbox().enqueue(outgoingMessage('m1', media: [photoDraft('a')]));
    await pumpEventQueue();

    expect(
      log.indexOf('keep m1 with 1 keys'),
      lessThan(log.indexOf('upload a')),
    );
    expect(log.indexOf('keep m1 with 1 keys'), isNot(-1));
  });

  test('a photo whose key could not be kept waits, not uploaded', () async {
    final messages = outbox();
    store.keepFailure = Exception('disk full');

    await messages.enqueue(outgoingMessage('m1', media: [photoDraft('a')]));
    await pumpEventQueue();

    expect(log, isNot(contains('upload a')));
    expect((await onItsWay(messages)).single.status, OutgoingStatus.waiting);

    store.keepFailure = null;
    messages.retryNow();
    await pumpEventQueue();

    expect(sentIds(), ['m1']);
  });

  test(
    'a lost connection is tried again after a pause, with the same keys',
    () async {
      final messages = outbox(pause: const Duration(milliseconds: 20));
      sender.sendFailures.add(Unexpected());

      await messages.enqueue(outgoingMessage('m1', media: [photoDraft('a')]));
      await pumpEventQueue();

      expect(statusOf('m1'), OutgoingStatus.waiting);
      expect(store.kept['m1']!.failures, 1);
      expect(sender.sent, isEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 60));
      await pumpEventQueue();

      expect(sentIds(), ['m1']);
      expect(sender.uploads, hasLength(2));
      expect(sender.uploads.first.$2, sender.uploads.last.$2);
      expect(sender.keysMade, 1);
    },
  );

  test('a message the server refuses waits for the user', () async {
    final messages = outbox(pause: const Duration(milliseconds: 20));
    sender.sendFailures.add(InsufficientPermissions());

    await messages.enqueue(outgoingMessage('m1'));
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await pumpEventQueue();

    expect(statusOf('m1'), OutgoingStatus.failed);
    expect(sender.sent, isEmpty);

    await messages.retry(UniqueId.fromUniqueString('m1'));
    await pumpEventQueue();

    expect(sentIds(), ['m1']);
  });

  test('a message refused does not hold up the ones after it', () async {
    final messages = outbox();
    chats.failures.add(chat_failure.InsufficientPermissions());

    await messages.enqueue(outgoingMessage('m1', startsChatWith: ['uid-bob']));
    await messages.enqueue(outgoingMessage('m2'));
    await pumpEventQueue();

    expect(statusOf('m1'), OutgoingStatus.failed);
    expect(sentIds(), ['m2']);
  });

  test('the messages of a chat go one at a time, in order', () async {
    final messages = outbox();
    sender.gate = Completer();

    await messages.enqueue(outgoingMessage('m1'));
    await messages.enqueue(outgoingMessage('m2', media: [photoDraft('a')]));
    await pumpEventQueue();

    expect(log.where((entry) => !entry.startsWith('keep')), ['send m1']);

    sender.gate!.complete();
    await pumpEventQueue();

    expect(log.where((entry) => !entry.startsWith('keep')), [
      'send m1',
      'upload a',
      'send m2',
    ]);
  });

  test('a message waiting to try again holds up the ones after it', () async {
    final messages = outbox();
    sender.sendFailures.add(Unexpected());

    await messages.enqueue(outgoingMessage('m1'));
    await messages.enqueue(outgoingMessage('m2'));
    await pumpEventQueue();

    expect(sender.sent, isEmpty);
    expect(statusOf('m2'), OutgoingStatus.sending);

    messages.retryNow();
    await pumpEventQueue();

    expect(sentIds(), ['m1', 'm2']);
  });

  test('the messages of other chats do not wait', () async {
    final messages = outbox();
    sender.sendFailures.add(Unexpected());

    await messages.enqueue(outgoingMessage('m1'));
    await messages.enqueue(
      outgoingMessage('m2', chatId: 'uid-alice_uid-carol'),
    );
    await pumpEventQueue();

    expect(sentIds(), ['m2']);
  });

  test('the first message of a chat starts it, with its photos', () async {
    await outbox().enqueue(
      outgoingMessage(
        'm1',
        media: [photoDraft('a')],
        startsChatWith: ['uid-bob'],
      ),
    );
    await pumpEventQueue();

    final chat = chats.created.single;
    expect(chat.id.getOrCrash(), aliceAndBob);
    expect(
      chat.participantsList
          .getOrCrash()
          .map((p) => p.value1.getOrCrash())
          .asList(),
      ['uid-alice', 'uid-bob'],
    );
    expect(chat.lastMessage.attachments.size, 1);
    expect(sender.sent, isEmpty);
  });

  test('messages kept when the app closed are sent when it opens', () async {
    final key = sender.attachmentFor(photoDraft('a'));
    final left = outgoingMessage(
      'm1',
      media: [photoDraft('a')],
    ).copyWith(attachments: {'a': key}, status: OutgoingStatus.sending);
    store.kept['m1'] = left;
    sender.keysMade = 0;

    await outbox().resume();
    await pumpEventQueue();

    expect(sentIds(), ['m1']);
    expect(sender.keysMade, 0, reason: 'the kept key is used again');
    expect(sender.uploads.single.$2, key.key);
  });

  test(
    'messages refused before the app closed still wait for the user',
    () async {
      store.kept['m1'] = outgoingMessage(
        'm1',
      ).copyWith(status: OutgoingStatus.failed, failures: 1);

      await outbox().resume();
      await pumpEventQueue();

      expect(sender.sent, isEmpty);
    },
  );

  test('a message given up takes its uploaded files with it', () async {
    final messages = outbox();
    sender.sendFailures.add(Unexpected());
    await messages.enqueue(outgoingMessage('m1', media: [photoDraft('a')]));
    await pumpEventQueue();

    final given = await messages.discard(UniqueId.fromUniqueString('m1'));
    await pumpEventQueue();

    expect(given, isTrue);
    expect(log, contains('delete a'));
    expect(store.kept, isEmpty);
    expect(store.toDelete, isEmpty);
    expect(await onItsWay(messages), isEmpty);

    messages.retryNow();
    await pumpEventQueue();
    expect(sender.sent, isEmpty);
  });

  test('files that could not be deleted are deleted later', () async {
    final messages = outbox();
    sender
      ..sendFailures.add(Unexpected())
      ..deleteFailures.add(Unexpected());
    await messages.enqueue(outgoingMessage('m1', media: [photoDraft('a')]));
    await pumpEventQueue();
    await messages.discard(UniqueId.fromUniqueString('m1'));
    await pumpEventQueue();

    expect(store.toDelete, hasLength(1));

    await outbox().resume();
    await pumpEventQueue();

    expect(store.toDelete, isEmpty);
    expect(log.where((entry) => entry == 'delete a'), hasLength(2));
  });

  test('a message being sent cannot be given up', () async {
    final messages = outbox();
    sender.gate = Completer();
    await messages.enqueue(outgoingMessage('m1'));
    await pumpEventQueue();

    final given = await messages.discard(UniqueId.fromUniqueString('m1'));
    sender.gate!.complete();
    await pumpEventQueue();

    expect(given, isFalse);
    expect(sentIds(), ['m1']);
  });

  test('the connection coming back tries waiting messages at once', () async {
    final messages = outbox();
    sender.sendFailures.add(Unexpected());
    await messages.enqueue(outgoingMessage('m1'));
    await pumpEventQueue();
    expect(sender.sent, isEmpty);

    reconnected.add(null);
    await pumpEventQueue();

    expect(sentIds(), ['m1']);
  });

  test('signing out stops the messages on their way', () async {
    final messages = outbox();
    sender.sendFailures.add(Unexpected());
    await messages.enqueue(outgoingMessage('m1'));
    await pumpEventQueue();

    session.end();
    // Signing out also deletes the phone's copy (LocalVault).
    store.kept.clear();
    reconnected.add(null);
    await pumpEventQueue();

    expect(sender.sent, isEmpty);
    expect(await onItsWay(messages), isEmpty);
  });

  test('a photo on its way is shown as it will be sent', () {
    final message = outgoingMessage(
      'm1',
      media: [photoDraft('a'), photoDraft('b')],
    ).copyWith(attachments: {'b': sender.attachmentFor(photoDraft('b'))});

    expect(
      message.withAttachments.attachments.asList().map(
        (a) => a.id.getOrCrash(),
      ),
      ['b'],
    );
    expect(
      message.withAttachments.attachments.first().kind,
      AttachmentKind.photo,
    );
  });

  test(
    'a send that hangs counts as failed, and lands once if it ends',
    () async {
      final messages = MessageOutbox(
        sender,
        chats,
        store,
        session,
        retryDelays: const [Duration(hours: 1)],
        sendTimeout: const Duration(milliseconds: 20),
      );
      sender.gate = Completer();

      await messages.enqueue(outgoingMessage('m1'));
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await pumpEventQueue();

      expect(statusOf('m1'), OutgoingStatus.waiting);

      sender.gate!.complete();
      messages.retryNow();
      await pumpEventQueue();

      expect(sentIds(), ['m1']);
      expect(store.kept, isEmpty);
    },
  );
}
