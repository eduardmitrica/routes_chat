import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/outbox/message_outbox.dart';
import 'package:routes_chat/domain/chats/chat_requests.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:dartz/dartz.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

import '../../helpers/outbox_fakes.dart';

class _NoMedia implements IMediaRepository {
  @override
  Future<Either<MediaFailure, MediaDraft>> prepare(String path) async =>
      throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Requests implements IChatRequestsRepository {
  final accepted = <String>[];

  @override
  Future<void> accept(UniqueId chatId) async =>
      accepted.add(chatId.getOrCrash());

  @override
  Future<void> delete(UniqueId chatId) async => throw UnimplementedError();

  @override
  Future<void> setAllowFromAnyone({required bool allow}) async =>
      throw UnimplementedError();

  @override
  Stream<ChatRequests> watch() => const Stream.empty();
}

void main() {
  late MemoryChatStore store;
  late CurrentUserSession session;
  late MessageOutbox outbox;
  late _Requests requests;
  final bob = UniqueId.fromUniqueString('uid-bob');

  setUp(() {
    store = MemoryChatStore();
    session = signedInAlice();
    requests = _Requests();
    outbox = MessageOutbox(
      FakeMessageSender(),
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
      _NoMedia(),
      store,
      outbox,
      draftDelay: const Duration(milliseconds: 10),
      requests: requests,
    );
    addTearDown(bloc.close);
    bloc.add(ChatBarEvent.started(bob));
    await pumpEventQueue();
    return bloc;
  }

  test('writing to someone first makes the chat the user\'s own', () async {
    final bloc = await open();
    bloc.add(const ChatBarEvent.sent('Salut', chatExists: false));
    await pumpEventQueue();
    // Nothing waits in the user's own requests when Bob answers.
    expect(requests.accepted, [aliceAndBob]);
  });

  test('answering in a chat that exists decides nothing', () async {
    final bloc = await open();
    bloc.add(const ChatBarEvent.sent('Salut', chatExists: true));
    await pumpEventQueue();
    expect(requests.accepted, isEmpty);
  });
}
