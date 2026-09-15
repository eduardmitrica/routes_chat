import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/outbox/message_outbox.dart';
import 'package:routes_chat/domain/chats/messages/emoji_usage.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../helpers/outbox_fakes.dart';
import '../../helpers/unused_media_repository.dart';

Message _message(
  String id,
  String text, {
  String sender = 'uid-alice',
  Duration age = const Duration(minutes: 1),
  KtList<MessageAttachment> attachments = const KtList.empty(),
}) => Message(
  id: UniqueId.fromUniqueString(id),
  senderId: UniqueId.fromUniqueString(sender),
  imageUrls: const KtList.empty(),
  content: Content(text),
  attachments: attachments,
  lastUpdatedAt: DateTime.now().subtract(age),
  isEdited: false,
);

/// Saves edits in memory, answering with the failures queued up first.
class _EditingMessages extends FakeMessageSender {
  final edits = <(String, String)>[];
  final editFailures = <MessageFailure>[];

  @override
  Future<Either<MessageFailure, Message>> editMessage(
    UniqueId chatId,
    Message message,
    String text,
  ) async {
    edits.add((message.id.getOrCrash(), text));
    if (editFailures.isNotEmpty) return Left(editFailures.removeAt(0));
    return Right(message.copyWith(content: Content(text), isEdited: true));
  }
}

class _Emojis implements IEmojiPreferences {
  final used = <String>[];

  @override
  Future<List<String>> favourites({required int count}) async => used;

  @override
  Future<void> recordUse(Iterable<String> emojis) async => used.addAll(emojis);
}

void main() {
  late _EditingMessages messages;
  late MemoryChatStore store;
  late _Emojis emojis;
  late ChatBarBloc bloc;
  final mine = _message('message-1', 'Ne vedem mâine?');
  final bobs = _message('message-2', 'Da, la 10', sender: 'uid-bob');

  setUp(() async {
    messages = _EditingMessages();
    store = MemoryChatStore();
    emojis = _Emojis();
    final session = signedInAlice();
    addTearDown(session.end);
    bloc = ChatBarBloc(
      session,
      UnusedMediaRepository(),
      store,
      MessageOutbox(messages, FakeChatStarter(), store, session),
      messages: messages,
      emojis: emojis,
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

  Future<ChatDraft?> savedDraft() =>
      store.loadDraft(UniqueId.fromUniqueString(aliceAndBob));

  test('editing shows the message in the field and keeps the draft', () async {
    await send(const ChatBarEvent.messageContentChanged('Și încă ceva'));
    await send(ChatBarEvent.replyStarted(bobs));
    final revision = bloc.state.textRevision;

    await send(ChatBarEvent.editStarted(mine));

    expect(bloc.state.editing, mine);
    expect(bloc.state.text, 'Ne vedem mâine?');
    expect(bloc.state.textRevision, greaterThan(revision));
    expect(bloc.state.replyingTo, isNull);
    final draft = await savedDraft();
    expect(draft?.text, 'Și încă ceva');
    expect(draft?.replyTo, MessageQuote.of(bobs));
  });

  test('cancelling brings back what the user was writing', () async {
    await send(const ChatBarEvent.messageContentChanged('Și încă ceva'));
    await send(ChatBarEvent.replyStarted(bobs));
    await send(ChatBarEvent.editStarted(mine));

    await send(const ChatBarEvent.editCancelled());

    expect(bloc.state.editing, isNull);
    expect(bloc.state.text, 'Și încă ceva');
    expect(bloc.state.replyingTo, MessageQuote.of(bobs));
    expect(messages.edits, isEmpty);
  });

  test('saving edits the message, and sends nothing new', () async {
    await send(const ChatBarEvent.messageContentChanged('Și încă ceva'));
    await send(ChatBarEvent.editStarted(mine));

    await send(sent('Ne vedem poimâine?'));

    expect(messages.edits, [('message-1', 'Ne vedem poimâine?')]);
    expect(messages.sent, isEmpty);
    expect(bloc.state.editing, isNull);
    expect(bloc.state.text, 'Și încă ceva');
    expect(bloc.state.lastEdited?.content.getOrCrash(), 'Ne vedem poimâine?');
    expect(bloc.state.lastEdited?.isEdited, isTrue);
  });

  test('saving the same text ends the edit without saving', () async {
    await send(ChatBarEvent.editStarted(mine));

    await send(sent('Ne vedem mâine?'));

    expect(messages.edits, isEmpty);
    expect(bloc.state.editing, isNull);
  });

  test('an edit that fails stays, to try again or cancel', () async {
    messages.editFailures.add(EditTimeExpired());
    await send(ChatBarEvent.editStarted(mine));
    final revision = bloc.state.textRevision;

    await send(sent('Ne vedem poimâine?'));

    expect(bloc.state.editing, mine);
    expect(bloc.state.savingEdit, isFalse);
    expect(bloc.state.text, 'Ne vedem poimâine?');
    expect(bloc.state.textRevision, greaterThan(revision));
    expect(bloc.state.lastEditFailure, isA<EditTimeExpired>());
    expect(bloc.state.editFailures, 1);
  });

  test("a message too old to edit, or someone else's, is not edited", () async {
    await send(
      ChatBarEvent.editStarted(
        _message('message-3', 'Demult', age: const Duration(minutes: 16)),
      ),
    );
    expect(bloc.state.editing, isNull);

    await send(ChatBarEvent.editStarted(bobs));
    expect(bloc.state.editing, isNull);
  });

  test('what is typed while editing is not kept as the draft', () async {
    await send(const ChatBarEvent.messageContentChanged('Și încă ceva'));
    await send(ChatBarEvent.editStarted(mine));

    await send(const ChatBarEvent.messageContentChanged('Ne vedem'));
    await bloc.close();

    expect((await savedDraft())?.text, 'Și încă ceva');
  });

  test('a text cannot be emptied, a caption can', () async {
    await send(ChatBarEvent.editStarted(mine));
    await send(sent(''));
    expect(messages.edits, isEmpty);
    expect(bloc.state.editing, mine);

    await send(const ChatBarEvent.editCancelled());
    final photo = _message(
      'message-4',
      'Uite',
      attachments: KtList.of(
        MessageAttachment(
          id: UniqueId.fromUniqueString('photo-1'),
          kind: AttachmentKind.photo,
          width: 10,
          height: 10,
          byteSize: 100,
          key: Uint8List(32),
        ),
      ),
    );
    await send(ChatBarEvent.editStarted(photo));
    await send(sent(''));
    expect(messages.edits, [('message-4', '')]);
  });

  test('starting a reply ends the edit', () async {
    await send(ChatBarEvent.editStarted(mine));

    await send(ChatBarEvent.replyStarted(bobs));

    expect(bloc.state.editing, isNull);
    expect(bloc.state.replyingTo, MessageQuote.of(bobs));
  });

  test('the emojis sent are counted, to offer them for reactions', () async {
    await send(sent('Super 🔥🔥 ❤️'));

    expect(emojis.used, ['🔥', '🔥', '❤️']);
  });
}
