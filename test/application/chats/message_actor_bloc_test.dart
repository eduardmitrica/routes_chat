import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/messages/message_actor/message_actor_bloc.dart';
import 'package:routes_chat/domain/chats/messages/emoji_usage.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_reaction.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../helpers/outbox_fakes.dart';

final _chatId = UniqueId.fromUniqueString(aliceAndBob);

Message _message({
  String sender = 'uid-alice',
  KtList<MessageReaction> reactions = const KtList.empty(),
  bool deleted = false,
}) => Message(
  id: UniqueId.fromUniqueString('message-1'),
  senderId: UniqueId.fromUniqueString(sender),
  imageUrls: const KtList.empty(),
  reactions: reactions,
  content: Content(deleted ? '' : 'Ne vedem mâine?'),
  lastUpdatedAt: DateTime.utc(2026, 9, 15, 12),
  isEdited: false,
  isDeleted: deleted,
);

MessageReaction _reaction(String userId, String emoji) => MessageReaction(
  messageId: UniqueId.fromUniqueString('message-1'),
  userId: UniqueId.fromUniqueString(userId),
  emoji: emoji,
);

class _Messages implements IMessageRepository {
  final reactions = <(String, String?)>[];
  final deleted = <String>[];
  MessageFailure? failure;
  Completer<void>? deleteGate;

  @override
  Future<Either<MessageFailure, Unit>> react(
    UniqueId chatId,
    Message message,
    String? emoji,
  ) async {
    reactions.add((message.id.getOrCrash(), emoji));
    return failure == null ? right(unit) : left(failure!);
  }

  @override
  Future<Either<MessageFailure, Message>> deleteMessage(
    UniqueId chatId,
    Message message,
  ) async {
    deleted.add(message.id.getOrCrash());
    await deleteGate?.future;
    return failure == null
        ? right(message.copyWith(content: Content(''), isDeleted: true))
        : left(failure!);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The most recently used first, each once.
class _Emojis implements IEmojiPreferences {
  final uses = <String>[];

  @override
  Future<List<String>> favourites({required int count}) async =>
      uses.reversed.toSet().take(count).toList();

  @override
  Future<void> recordUse(Iterable<String> emojis) async => uses.addAll(emojis);
}

void main() {
  late _Messages messages;
  late _Emojis emojis;
  late MessageActorBloc bloc;

  setUp(() {
    messages = _Messages();
    emojis = _Emojis();
    final session = signedInAlice();
    addTearDown(session.end);
    bloc = MessageActorBloc(messages, emojis, session);
    addTearDown(bloc.close);
  });

  Future<void> send(MessageActorEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  MessageActorEvent pick(Message message, String emoji) =>
      MessageActorEvent.reactionPicked(
        chatId: _chatId,
        message: message,
        emoji: emoji,
      );

  group('reacting', () {
    test('offers no emojis before the user used any', () async {
      await send(const MessageActorEvent.quickEmojisRequested());

      expect(bloc.state.quickEmojis, isEmpty);
    });

    test('with an emoji saves it, and offers it first from then on', () async {
      await send(pick(_message(), '🔥'));

      expect(messages.reactions, [('message-1', '🔥')]);
      expect(emojis.uses, ['🔥']);
      expect(bloc.state.quickEmojis, ['🔥']);
    });

    test('with the emoji the user reacted with takes it back', () async {
      final message = _message(
        reactions: KtList.of(_reaction('uid-alice', '🔥')),
      );

      await send(pick(message, '🔥'));

      expect(messages.reactions, [('message-1', null)]);
      expect(emojis.uses, isEmpty);
    });

    test('with another emoji replaces the reaction', () async {
      final message = _message(
        reactions: KtList.of(
          _reaction('uid-bob', '❤️'),
          _reaction('uid-alice', '🔥'),
        ),
      );

      await send(pick(message, '❤️'));

      expect(messages.reactions, [('message-1', '❤️')]);
    });

    test('to a deleted message does nothing', () async {
      await send(pick(_message(deleted: true), '🔥'));

      expect(messages.reactions, isEmpty);
    });

    test('can be taken back', () async {
      await send(
        MessageActorEvent.reactionRemoved(chatId: _chatId, message: _message()),
      );

      expect(messages.reactions, [('message-1', null)]);
    });
  });

  group('deleting', () {
    test("deletes the user's message, once while it is under way", () async {
      messages.deleteGate = Completer<void>();

      await send(
        MessageActorEvent.deleteRequested(chatId: _chatId, message: _message()),
      );
      expect(bloc.state.deleting, {'message-1'});
      await send(
        MessageActorEvent.deleteRequested(chatId: _chatId, message: _message()),
      );
      messages.deleteGate!.complete();
      await pumpEventQueue();

      expect(messages.deleted, ['message-1']);
      expect(bloc.state.deleting, isEmpty);
      expect(bloc.state.lastDeleted?.isDeleted, isTrue);
    });

    test("does not delete someone else's message", () async {
      await send(
        MessageActorEvent.deleteRequested(
          chatId: _chatId,
          message: _message(sender: 'uid-bob'),
        ),
      );

      expect(messages.deleted, isEmpty);
    });

    test('says each time it failed', () async {
      messages.failure = Unexpected();

      await send(
        MessageActorEvent.deleteRequested(chatId: _chatId, message: _message()),
      );
      final first = bloc.state.lastProblem;
      await send(
        MessageActorEvent.deleteRequested(chatId: _chatId, message: _message()),
      );

      expect(first?.action, MessageAction.delete);
      expect(bloc.state.lastProblem, isNot(first));
      expect(bloc.state.deleting, isEmpty);
      expect(bloc.state.lastDeleted, isNull);
    });
  });
}
