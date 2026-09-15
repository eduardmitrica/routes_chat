import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/chats/chat_activity/chat_activity_bloc.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/presence/presence.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';

import '../../helpers/presence_fakes.dart';

void main() {
  late FakePresence presence;
  late FakePrivacy privacy;
  late DateTime now;

  final chatId = UniqueId.fromUniqueString('uid-alice_uid-bob');
  final bob = UniqueId.fromUniqueString('uid-bob');

  setUp(() {
    presence = FakePresence();
    privacy = FakePrivacy();
    now = DateTime.utc(2026, 9, 15, 12);
    addTearDown(presence.close);
    addTearDown(privacy.close);
  });

  Future<ChatActivityBloc> open({
    Duration typingShownFor = const Duration(milliseconds: 40),
  }) async {
    final bloc = ChatActivityBloc(
      presence,
      privacy,
      now: () => now,
      typingShownFor: typingShownFor,
    );
    addTearDown(bloc.close);
    bloc.add(ChatActivityEvent.started(chatId: chatId, otherUserId: bob));
    await pumpEventQueue();
    return bloc;
  }

  group('typing', () {
    test('shows while their phone says so, then ends by itself', () async {
      final bloc = await open();

      presence.typing.add(now);
      await pumpEventQueue();
      expect(bloc.state.typing, isTrue);

      now = now.add(const Duration(milliseconds: 60));
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await pumpEventQueue();
      expect(bloc.state.typing, isFalse);
    });

    test('ends at once when they stop', () async {
      final bloc = await open(typingShownFor: const Duration(hours: 1));
      presence.typing.add(now);
      await pumpEventQueue();

      presence.typing.add(null);
      await pumpEventQueue();

      expect(bloc.state.typing, isFalse);
    });

    test('a mark from long ago is not typing now', () async {
      final bloc = await open(typingShownFor: const Duration(hours: 1));

      presence.typing.add(now.subtract(const Duration(minutes: 5)));
      await pumpEventQueue();

      expect(bloc.state.typing, isFalse);
    });

    test('is not watched while the user hides their own typing', () async {
      privacy = FakePrivacy(const PrivacySettings(shareTyping: false));
      final bloc = await open();

      presence.typing.add(now);
      await pumpEventQueue();

      expect(presence.typingWatches, 0);
      expect(bloc.state.typing, isFalse);
    });

    test('stops showing as soon as the user hides their own', () async {
      final bloc = await open(typingShownFor: const Duration(hours: 1));
      presence.typing.add(now);
      await pumpEventQueue();

      privacy.change(const PrivacySettings(shareTyping: false));
      await pumpEventQueue();

      expect(bloc.state.typing, isFalse);
    });
  });

  group('online', () {
    test('while their app said so recently', () async {
      final bloc = await open();

      presence.presence.add(
        Presence(
          online: true,
          lastSeenAt: now.subtract(const Duration(seconds: 20)),
        ),
      );
      await pumpEventQueue();

      expect(bloc.state.online, isTrue);
      expect(bloc.state.lastSeen, isNull);
    });

    test('an app that stopped saying so shows when it was last seen', () async {
      final bloc = await open();
      final lastSeenAt = now.subtract(const Duration(minutes: 10));

      presence.presence.add(Presence(online: true, lastSeenAt: lastSeenAt));
      await pumpEventQueue();

      expect(bloc.state.online, isFalse);
      expect(bloc.state.lastSeen, lastSeenAt);
    });

    test('an app that left the screen shows when', () async {
      final bloc = await open();

      presence.presence.add(Presence(online: false, lastSeenAt: now));
      await pumpEventQueue();

      expect(bloc.state.online, isFalse);
      expect(bloc.state.lastSeen, now);
    });

    test('nothing shows while the user hides their own', () async {
      final bloc = await open();
      presence.presence.add(Presence(online: true, lastSeenAt: now));
      await pumpEventQueue();

      privacy.change(const PrivacySettings(shareOnline: false));
      await pumpEventQueue();

      expect(bloc.state, const ChatActivityState());
    });
  });
}
