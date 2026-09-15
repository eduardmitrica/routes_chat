import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/outbox/message_outbox.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';

import '../../helpers/outbox_fakes.dart';
import '../../helpers/presence_fakes.dart';
import '../../helpers/unused_media_repository.dart';

void main() {
  late FakePresence presence;
  late FakePrivacy privacy;

  setUp(() {
    presence = FakePresence();
    privacy = FakePrivacy();
    addTearDown(presence.close);
    addTearDown(privacy.close);
  });

  Future<ChatBarBloc> open({
    Duration typingRefresh = const Duration(hours: 1),
    Duration typingPause = const Duration(hours: 1),
  }) async {
    final store = MemoryChatStore();
    final session = signedInAlice();
    addTearDown(session.end);
    final bloc = ChatBarBloc(
      session,
      UnusedMediaRepository(),
      store,
      MessageOutbox(FakeMessageSender(), FakeChatStarter(), store, session),
      presence: presence,
      privacy: privacy,
      typingRefresh: typingRefresh,
      typingPause: typingPause,
    );
    addTearDown(bloc.close);
    bloc.add(ChatBarEvent.started(UniqueId.fromUniqueString('uid-bob')));
    await pumpEventQueue();
    return bloc;
  }

  Future<void> type(ChatBarBloc bloc, String text) async {
    bloc.add(ChatBarEvent.messageContentChanged(text));
    await pumpEventQueue();
  }

  const typing = 'typing uid-alice_uid-bob';
  const stopped = 'stopped uid-alice_uid-bob';

  test('typing is said once, not with every key', () async {
    final bloc = await open();

    await type(bloc, 'S');
    await type(bloc, 'Sa');
    await type(bloc, 'Sal');

    expect(presence.calls, [typing]);
  });

  test('typing is said again while it goes on', () async {
    final bloc = await open(typingRefresh: const Duration(milliseconds: 20));

    await type(bloc, 'S');
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await type(bloc, 'Sa');

    expect(presence.calls, [typing, typing]);
  });

  test('a pause in typing says it stopped', () async {
    final bloc = await open(typingPause: const Duration(milliseconds: 20));

    await type(bloc, 'Salut');
    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(presence.calls, [typing, stopped]);
  });

  test('sending, or emptying the field, says it stopped', () async {
    final bloc = await open();

    await type(bloc, 'Salut');
    bloc.add(const ChatBarEvent.sent('Salut', chatExists: true));
    await pumpEventQueue();
    await type(bloc, 'Și');
    await type(bloc, '');

    expect(presence.calls, [typing, stopped, typing, stopped]);
  });

  test('leaving the chat says it stopped', () async {
    final bloc = await open();

    await type(bloc, 'Salut');
    await bloc.close();

    expect(presence.calls, [typing, stopped]);
  });

  test('nothing is said while the user hides their typing', () async {
    privacy = FakePrivacy(const PrivacySettings(shareTyping: false));
    final bloc = await open();

    await type(bloc, 'Salut');
    await bloc.close();

    expect(presence.calls, isEmpty);
  });
}
