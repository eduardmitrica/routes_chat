import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/chats/message_requests/message_requests_bloc.dart';
import 'package:routes_chat/domain/chats/chat_requests.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../helpers/outbox_fakes.dart';

final _noon = DateTime.utc(2026, 9, 16, 12);

class _Repository implements IChatRequestsRepository {
  final decisions = StreamController<ChatRequests>.broadcast();
  final accepted = <String>[];
  final deleted = <String>[];
  bool? allowedFromAnyone;

  @override
  Stream<ChatRequests> watch() => decisions.stream;

  @override
  Future<void> accept(UniqueId chatId) async =>
      accepted.add(chatId.getOrCrash());

  @override
  Future<void> delete(UniqueId chatId) async =>
      deleted.add(chatId.getOrCrash());

  @override
  Future<void> setAllowFromAnyone({required bool allow}) async =>
      allowedFromAnyone = allow;
}

void main() {
  late _Repository repository;
  late MessageRequestsBloc bloc;

  setUp(() {
    repository = _Repository();
  });

  MessageRequestsBloc blocFor(dynamic session) {
    bloc = MessageRequestsBloc(repository, session);
    addTearDown(bloc.close);
    bloc.add(const MessageRequestsEvent.started());
    return bloc;
  }

  test(
    'what is decided comes through, and is offered to the screens',
    () async {
      final session = signedInAlice();
      addTearDown(session.end);
      blocFor(session);
      await pumpEventQueue();
      expect(bloc.requests, const ChatRequests());

      final decided = ChatRequests(
        byChatId: {
          'uid-alice_uid-bob': ChatRequestDecision(
            ChatRequestState.accepted,
            _noon,
          ),
        },
        allowFromAnyone: false,
      );
      repository.decisions.add(decided);
      await pumpEventQueue();
      expect(bloc.state.requests, decided);
      expect(bloc.requests, decided);
    },
  );

  test('accepting, deleting and the setting reach the repository', () async {
    final session = signedInAlice();
    addTearDown(session.end);
    blocFor(session);
    final chatId = UniqueId.fromUniqueString('uid-alice_uid-bob');

    bloc
      ..add(MessageRequestsEvent.accepted(chatId))
      ..add(MessageRequestsEvent.deleted(chatId))
      ..add(const MessageRequestsEvent.allowFromAnyoneChanged(false));
    await pumpEventQueue();

    expect(repository.accepted, ['uid-alice_uid-bob']);
    expect(repository.deleted, ['uid-alice_uid-bob']);
    expect(repository.allowedFromAnyone, isFalse);
  });

  test('signing out leaves nothing behind', () async {
    final session = signedInAlice();
    blocFor(session);
    await pumpEventQueue();
    repository.decisions.add(
      ChatRequests(
        byChatId: {
          'uid-alice_uid-bob': ChatRequestDecision(
            ChatRequestState.accepted,
            _noon,
          ),
        },
      ),
    );
    await pumpEventQueue();
    expect(bloc.requests.byChatId, isNotEmpty);

    session.end();
    await pumpEventQueue();
    expect(bloc.requests, const ChatRequests());
  });
}
