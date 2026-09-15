import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../helpers/outbox_fakes.dart';

final _noon = DateTime.utc(2026, 9, 16, 12);

Chat _chatWith(String other, {required String lastFrom, required int minute}) =>
    Chat(
      id: UniqueId.fromUniqueString('uid-alice_$other'),
      participantsList: ParticipantsList(
        KtList.of(
          Tuple2(UniqueId.fromUniqueString('uid-alice'), UniqueId.empty()),
          Tuple2(UniqueId.fromUniqueString(other), UniqueId.empty()),
        ),
      ),
      lastMessage: Message(
        id: UniqueId.fromUniqueString('last-$other'),
        senderId: UniqueId.fromUniqueString(lastFrom),
        imageUrls: const KtList.empty(),
        content: Content('Salut'),
        lastUpdatedAt: _noon.add(Duration(minutes: minute)),
        isEdited: false,
      ),
    );

class _Chats implements IChatRepository {
  final chats = StreamController<Either<ChatFailure, KtList<Chat>>>();

  @override
  Stream<Either<ChatFailure, KtList<Chat>>> watchAllForCurrentUser() =>
      chats.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Reads implements IChatReads {
  final reads = StreamController<ChatReads>.broadcast();

  @override
  Stream<ChatReads> watch() => reads.stream;

  @override
  Future<void> markRead(UniqueId chatId, DateTime sentAt) async {}
}

void main() {
  test(
    'chats with messages the user has not read stand out, until read',
    () async {
      final session = signedInAlice();
      addTearDown(session.end);
      final repository = _Chats();
      final reads = _Reads();
      final bloc = ChatsWatcherBloc(repository, session, reads: reads);
      addTearDown(bloc.close);
      bloc.add(const ChatsWatcherEvent.watchAllStarted());
      await pumpEventQueue();

      reads.reads.add(ChatReads(since: _noon));
      repository.chats.add(
        right(
          KtList.of(
            _chatWith('uid-bob', lastFrom: 'uid-bob', minute: 5),
            _chatWith('uid-carol', lastFrom: 'uid-alice', minute: 6),
            _chatWith('uid-dan', lastFrom: 'uid-dan', minute: -5),
          ),
        ),
      );
      await pumpEventQueue();
      expect((bloc.state as ChatsWatcherLoadSuccess).unreadChatIds, {
        'uid-alice_uid-bob',
      });

      reads.reads.add(
        ChatReads(
          since: _noon,
          readUpTo: {
            'uid-alice_uid-bob': _noon.add(const Duration(minutes: 5)),
          },
        ),
      );
      await pumpEventQueue();
      expect((bloc.state as ChatsWatcherLoadSuccess).unreadChatIds, isEmpty);
    },
  );
}
