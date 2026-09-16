import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/messages/messages_watcher/messages_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_page.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/message_reaction.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

DateTime _sentAt(int number) =>
    DateTime.utc(2026, 9, 15).add(Duration(minutes: number));

Message _message(int number, {String? text, MessageQuote? replyTo}) => Message(
  id: UniqueId.fromUniqueString('m${number.toString().padLeft(4, '0')}'),
  senderId: UniqueId.fromUniqueString('alice'),
  imageUrls: const KtList.empty(),
  content: Content(text ?? 'message $number'),
  replyTo: replyTo,
  lastUpdatedAt: _sentAt(number),
  isEdited: false,
);

Message _deleted(Message message) =>
    message.copyWith(content: Content(''), replyTo: null, isDeleted: true);

MessageReaction _reaction(int number, String userId, String emoji) =>
    MessageReaction(
      messageId: _message(number).id,
      userId: UniqueId.fromUniqueString(userId),
      emoji: emoji,
    );

class _Messages implements IMessageRepository {
  final latest = StreamController<Either<MessageFailure, MessagePage>>();
  final reactions =
      StreamController<
        Either<MessageFailure, KtList<MessageReaction>>
      >.broadcast();

  /// When the reactions were watched from, each time the watch started.
  final reactionsWatchedSince = <DateTime>[];

  /// The page before the live one.
  List<Message> older = const [];

  @override
  Stream<Either<MessageFailure, MessagePage>> watchLatestForChatWithId(
    UniqueId chatId, {
    required int limit,
  }) => latest.stream;

  @override
  Future<Either<MessageFailure, MessagePage>> getPageBefore(
    UniqueId chatId,
    UniqueId messageId, {
    required int limit,
  }) async => Right(MessagePage(older.toImmutableList(), reachesStart: true));

  @override
  Stream<Either<MessageFailure, KtList<MessageReaction>>> watchReactions(
    UniqueId chatId, {
    required DateTime since,
  }) {
    reactionsWatchedSince.add(since);
    return reactions.stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Messages messages;
  late MessagesWatcherBloc bloc;

  Future<void> showLatest(
    List<Message> page, {
    bool reachesStart = true,
  }) async {
    messages.latest.add(
      Right(MessagePage(page.toImmutableList(), reachesStart: reachesStart)),
    );
    await pumpEventQueue();
  }

  Future<void> open(
    List<Message> page, {
    bool reachesStart = true,
    String chatId = 'chat',
  }) async {
    messages = _Messages();
    bloc = MessagesWatcherBloc(messages);
    addTearDown(bloc.close);
    bloc.add(
      MessagesWatcherEvent.watchStarted(UniqueId.fromUniqueString(chatId)),
    );
    await pumpEventQueue();
    await showLatest(page, reachesStart: reachesStart);
  }

  Future<void> react(List<MessageReaction> reactions) async {
    messages.reactions.add(Right(reactions.toImmutableList()));
    await pumpEventQueue();
  }

  Future<void> send(MessagesWatcherEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  Message shown(int number) =>
      bloc.state.messages.first((message) => message.id == _message(number).id);

  group('reactions', () {
    test('show in a group too', () async {
      await open([
        _message(1),
      ], chatId: 'group-00000000-0000-4000-8000-000000000000');

      await react([_reaction(1, 'bob', '❤️')]);

      expect(messages.reactionsWatchedSince, isNotEmpty);
      expect(shown(1).reactions.asList(), [_reaction(1, 'bob', '❤️')]);
    });

    test('each message shows with the reactions to it', () async {
      await open([_message(1), _message(2)]);

      await react([
        _reaction(1, 'bob', '❤️'),
        _reaction(1, 'alice', '👍'),
        _reaction(2, 'bob', '😂'),
      ]);

      expect(shown(1).reactions.asList(), [
        _reaction(1, 'bob', '❤️'),
        _reaction(1, 'alice', '👍'),
      ]);
      expect(shown(2).reactions.asList(), [_reaction(2, 'bob', '😂')]);
    });

    test('are watched from the oldest message loaded, and further back once '
        'older messages load', () async {
      await open([
        for (var number = 10; number < 40; number++) _message(number),
      ], reachesStart: false);
      expect(messages.reactionsWatchedSince, [_sentAt(10)]);

      await showLatest([
        for (var number = 11; number < 41; number++) _message(number),
      ], reachesStart: false);
      expect(messages.reactionsWatchedSince, [
        _sentAt(10),
      ], reason: 'the oldest message loaded did not change');

      messages.older = [
        for (var number = 0; number < 10; number++) _message(number),
      ];
      await send(const MessagesWatcherEvent.olderRequested());

      expect(messages.reactionsWatchedSince, [_sentAt(10), _sentAt(0)]);
    });

    test('that cannot be loaded leave the messages as they are', () async {
      await open([_message(1)]);

      messages.reactions.add(Left(Unexpected()));
      await pumpEventQueue();

      expect(bloc.state.status, MessagesStatus.loaded);
      expect(shown(1), _message(1));
    });
  });

  group('deleted messages', () {
    test('show no reactions and are not found by search', () async {
      await open([_deleted(_message(1)), _message(2)]);
      await react([_reaction(1, 'bob', '❤️')]);

      await send(const MessagesWatcherEvent.searchChanged('message'));

      expect(shown(1).reactions.isEmpty(), isTrue);
      expect(bloc.state.searchResults.map((message) => message.id).asList(), [
        _message(2).id,
      ]);
    });
  });

  group('a reply', () {
    test('follows the original once it is edited, then deleted', () async {
      final original = _message(1, text: 'Ne vedem?');
      final reply = _message(2, text: 'Da', replyTo: MessageQuote.of(original));
      await open([original, reply]);

      await showLatest([
        original.copyWith(content: Content('Ne vedem mâine?'), isEdited: true),
        reply,
      ]);
      expect(shown(2).replyTo!.text, 'Ne vedem mâine?');

      await showLatest([_deleted(original), reply]);
      expect(shown(2).replyTo!.originalDeleted, isTrue);
      expect(shown(2).replyTo!.text, isEmpty);
    });
  });

  group("the user's own change", () {
    test('shows at once', () async {
      await open([_message(1), _message(2)]);

      await send(
        MessagesWatcherEvent.messageChanged(
          _message(1).copyWith(content: Content('Nou'), isEdited: true),
        ),
      );

      expect(shown(1).content.getOrCrash(), 'Nou');
      expect(shown(1).isEdited, isTrue);
    });

    test('to a message not loaded changes nothing', () async {
      await open([_message(1)]);
      final before = bloc.state;

      await send(MessagesWatcherEvent.messageChanged(_deleted(_message(7))));

      expect(bloc.state, before);
    });
  });
}
