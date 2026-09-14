import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/messages/messages_watcher/messages_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_page.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

const _pageSize = MessagesWatcherBloc.pageSize;

Message _message(int number, {String? text, bool readable = true}) => Message(
  id: UniqueId.fromUniqueString('m${number.toString().padLeft(4, '0')}'),
  senderId: UniqueId.fromUniqueString('alice'),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content(text ?? 'message $number'),

  lastUpdatedAt: DateTime.utc(2026, 9, 14).add(Duration(minutes: number)),
  isEdited: false,
  isReadable: readable,
);

/// A chat held in memory, served a page at a time like MessageRepository.
class _FakeMessages implements IMessageRepository {
  /// The whole chat, oldest first.
  final List<Message> chat;

  final _latest = StreamController<Either<MessageFailure, MessagePage>>();

  /// The id each older page was requested before, in order.
  final pagesRequestedBefore = <String>[];

  /// When set, older pages wait for it.
  Completer<void>? pageGate;

  /// When set, older pages fail with it.
  MessageFailure? pageFailure;

  _FakeMessages(this.chat);

  /// Sends the newest page, as a live query does when the chat changes.
  void sendLatest() {
    final start = max(0, chat.length - _pageSize);
    _latest.add(
      Right(
        MessagePage(
          chat.sublist(start).toImmutableList(),
          reachesStart: chat.length < _pageSize,
        ),
      ),
    );
  }

  @override
  Stream<Either<MessageFailure, MessagePage>> watchLatestForChatWithId(
    UniqueId chatId, {
    required int limit,
  }) => _latest.stream;

  @override
  Future<Either<MessageFailure, MessagePage>> getPageBefore(
    UniqueId chatId,
    UniqueId messageId, {
    required int limit,
  }) async {
    pagesRequestedBefore.add(messageId.getOrCrash());
    await pageGate?.future;
    final failure = pageFailure;
    if (failure != null) return Left(failure);
    final end = chat.indexWhere((message) => message.id == messageId);
    final start = max(0, end - limit);
    return Right(
      MessagePage(
        chat.sublist(start, end).toImmutableList(),
        reachesStart: end - start < limit,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<String> _ids(KtList<Message> messages) =>
    messages.asList().map((message) => message.id.getOrCrash()).toList();

void main() {
  late _FakeMessages messages;
  late MessagesWatcherBloc bloc;

  Future<void> open(List<Message> chat) async {
    messages = _FakeMessages(chat);
    bloc = MessagesWatcherBloc(messages);
    addTearDown(bloc.close);
    bloc.add(
      MessagesWatcherEvent.watchStarted(UniqueId.fromUniqueString('chat')),
    );
    await pumpEventQueue();
    messages.sendLatest();
    await pumpEventQueue();
  }

  Future<void> send(MessagesWatcherEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  group('paging', () {
    test('opening a chat shows only the newest page, oldest first', () async {
      await open(List.generate(45, _message));

      expect(bloc.state.status, MessagesStatus.loaded);
      expect(bloc.state.messages.size, _pageSize);
      expect(_ids(bloc.state.messages).first, 'm0015');
      expect(_ids(bloc.state.messages).last, 'm0044');
      expect(bloc.state.reachedStart, isFalse);
    });

    test('a chat shorter than a page is known to be complete', () async {
      await open(List.generate(10, _message));

      expect(bloc.state.messages.size, 10);
      expect(bloc.state.reachedStart, isTrue);
    });

    test('scrolling up loads the page before the oldest message', () async {
      await open(List.generate(45, _message));

      await send(const MessagesWatcherEvent.olderRequested());

      expect(messages.pagesRequestedBefore, ['m0015']);
      expect(bloc.state.messages.size, 45);
      expect(_ids(bloc.state.messages).first, 'm0000');
      expect(bloc.state.reachedStart, isTrue);
      expect(bloc.state.loadingOlder, isFalse);
    });

    test(
      'a second request while a page loads does not load it twice',
      () async {
        await open(List.generate(100, _message));
        messages.pageGate = Completer<void>();

        bloc
          ..add(const MessagesWatcherEvent.olderRequested())
          ..add(const MessagesWatcherEvent.olderRequested());
        await pumpEventQueue();
        expect(bloc.state.loadingOlder, isTrue);
        messages.pageGate!.complete();
        await pumpEventQueue();

        expect(messages.pagesRequestedBefore, hasLength(1));
        expect(bloc.state.messages.size, 60);
      },
    );

    test('nothing more is requested once the start is loaded', () async {
      await open(List.generate(45, _message));
      await send(const MessagesWatcherEvent.olderRequested());

      await send(const MessagesWatcherEvent.olderRequested());

      expect(messages.pagesRequestedBefore, hasLength(1));
    });

    test('new messages keep the older ones already loaded', () async {
      await open(List.generate(45, _message));
      await send(const MessagesWatcherEvent.olderRequested());

      messages.chat.addAll([_message(45), _message(46)]);
      messages.sendLatest();
      await pumpEventQueue();

      expect(bloc.state.messages.size, 47);
      expect(_ids(bloc.state.messages).last, 'm0046');
      expect(bloc.state.reachedStart, isTrue);
    });

    test('a page that fails keeps the messages shown', () async {
      await open(List.generate(45, _message));
      messages.pageFailure = Unexpected();

      await send(const MessagesWatcherEvent.olderRequested());

      expect(bloc.state.messages.size, _pageSize);
      expect(bloc.state.failureOption.isSome(), isTrue);
      expect(bloc.state.loadingOlder, isFalse);
    });
  });

  group('searching', () {
    test('finds loaded messages, newest first, ignoring accents', () async {
      await open([
        _message(0, text: 'Să mergem la mare'),
        _message(1, text: 'Nu azi'),
        _message(2, text: 'SA fie mâine'),
      ]);

      await send(const MessagesWatcherEvent.searchChanged('sa'));

      expect(_ids(bloc.state.searchResults), ['m0002', 'm0000']);
      expect(bloc.state.isSearching, isTrue);
    });

    test('loads older pages until it reaches the start of the chat', () async {
      final chat = List.generate(100, _message);
      chat[3] = _message(3, text: 'the needle');
      await open(chat);

      await send(const MessagesWatcherEvent.searchChanged('needle'));

      expect(messages.pagesRequestedBefore, hasLength(3));
      expect(bloc.state.reachedStart, isTrue);
      expect(bloc.state.searchingOlder, isFalse);
      expect(_ids(bloc.state.searchResults), ['m0003']);
    });

    test('does not search messages that could not be decrypted', () async {
      await open([
        _message(
          0,
          text: 'This message could not be decrypted.',
          readable: false,
        ),
        _message(1, text: 'decrypted fine'),
      ]);

      await send(const MessagesWatcherEvent.searchChanged('decrypted'));

      expect(_ids(bloc.state.searchResults), ['m0001']);
    });

    test('a changed query stops loading pages for the old one', () async {
      await open(List.generate(200, _message));
      messages.pageGate = Completer<void>();

      bloc.add(const MessagesWatcherEvent.searchChanged('first'));
      await pumpEventQueue();
      bloc.add(const MessagesWatcherEvent.searchClosed());
      await pumpEventQueue();
      messages.pageGate!.complete();
      await pumpEventQueue();

      expect(messages.pagesRequestedBefore, hasLength(1));
      expect(bloc.state.isSearching, isFalse);
      expect(bloc.state.searchingOlder, isFalse);
    });

    test('closing the search clears it and keeps the messages', () async {
      await open(List.generate(10, _message));
      await send(const MessagesWatcherEvent.searchChanged('message 1'));

      await send(const MessagesWatcherEvent.searchClosed());

      expect(bloc.state.searchQuery, isEmpty);
      expect(bloc.state.searchResults.isEmpty(), isTrue);
      expect(bloc.state.messages.size, 10);
    });

    test('never prints what is searched for', () async {
      await open([_message(0, text: 'secret plans')]);

      await send(const MessagesWatcherEvent.searchChanged('secret'));

      expect(bloc.state.toString(), isNot(contains('secret')));
    });
  });

  group('revealing a message', () {
    UniqueId id(String value) => UniqueId.fromUniqueString(value);

    test('a loaded message is revealed without loading more', () async {
      await open(List.generate(45, _message));

      await send(MessagesWatcherEvent.messageRevealRequested(id('m0040')));

      expect(messages.pagesRequestedBefore, isEmpty);
      expect(bloc.state.lastReveal?.message?.id, id('m0040'));
      expect(bloc.state.revealingMessage, isFalse);
    });

    test('an older message loads the pages up to it', () async {
      await open(List.generate(100, _message));

      await send(MessagesWatcherEvent.messageRevealRequested(id('m0003')));

      expect(messages.pagesRequestedBefore, hasLength(3));
      expect(bloc.state.lastReveal?.message?.id, id('m0003'));
      expect(bloc.state.revealingMessage, isFalse);
    });

    test('a message the chat does not have is not found', () async {
      await open(List.generate(45, _message));

      await send(MessagesWatcherEvent.messageRevealRequested(id('elsewhere')));

      expect(bloc.state.reachedStart, isTrue);
      expect(bloc.state.lastReveal?.messageId, id('elsewhere'));
      expect(bloc.state.lastReveal?.message, isNull);
    });

    test('a page that fails stops the search for it', () async {
      await open(List.generate(100, _message));
      messages.pageFailure = Unexpected();

      await send(MessagesWatcherEvent.messageRevealRequested(id('m0003')));

      expect(messages.pagesRequestedBefore, hasLength(1));
      expect(bloc.state.lastReveal?.message, isNull);
      expect(bloc.state.revealingMessage, isFalse);
    });

    test('asking for the same message again is a new reveal', () async {
      await open(List.generate(10, _message));

      await send(MessagesWatcherEvent.messageRevealRequested(id('m0005')));
      final first = bloc.state.lastReveal;
      await send(MessagesWatcherEvent.messageRevealRequested(id('m0005')));

      expect(bloc.state.lastReveal, isNot(first));
    });
  });
}
