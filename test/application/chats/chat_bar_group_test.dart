import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/outbox/message_outbox.dart';
import 'package:routes_chat/domain/chats/chat_requests.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

import '../../helpers/outbox_fakes.dart';
import '../../helpers/presence_fakes.dart';

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MemoryChatStore store;
  late FakeMessageSender sender;
  late FakeChatStarter starter;
  late CurrentUserSession session;
  late FakePresence presence;
  late _Requests requests;
  late ChatBarBloc bloc;
  final group = UniqueId.fromUniqueString(
    'group-00000000-0000-4000-8000-000000000000',
  );

  setUp(() async {
    store = MemoryChatStore();
    sender = FakeMessageSender();
    starter = FakeChatStarter();
    session = signedInAlice();
    addTearDown(session.end);
    presence = FakePresence();
    requests = _Requests();
    final outbox = MessageOutbox(
      sender,
      starter,
      store,
      session,
      retryDelays: const [Duration(hours: 1)],
    );
    bloc = ChatBarBloc(
      session,
      _NoMedia(),
      store,
      outbox,
      draftDelay: const Duration(milliseconds: 10),
      presence: presence,
      privacy: FakePrivacy(),
      requests: requests,
    );
    addTearDown(bloc.close);
    bloc.add(ChatBarEvent.startedInGroup(group));
    await pumpEventQueue();
  });

  test('writes in the group under its own id', () async {
    expect(bloc.state.chatId, group);
  });

  test('a message goes to the group, starting and accepting nothing', () async {
    bloc.add(const ChatBarEvent.sent('Salut tuturor', chatExists: true));
    await pumpEventQueue();

    expect(sender.sent.map((message) => message.content.getOrCrash()), [
      'Salut tuturor',
    ]);
    expect(starter.created, isEmpty);
    expect(requests.accepted, isEmpty);
  });

  test('typing is not shared in a group yet', () async {
    bloc.add(const ChatBarEvent.messageContentChanged('Sal'));
    await pumpEventQueue();

    expect(presence.calls.where((call) => call.startsWith('typing')), isEmpty);
  });
}
