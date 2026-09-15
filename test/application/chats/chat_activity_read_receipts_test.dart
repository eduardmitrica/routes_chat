import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_activity/chat_activity_bloc.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';

import '../../helpers/presence_fakes.dart';

final _chatId = UniqueId.fromUniqueString('uid-alice_uid-bob');
final _bob = UniqueId.fromUniqueString('uid-bob');
final _noon = DateTime.utc(2026, 9, 16, 12);

Message _message(String id, int minute, {String from = 'uid-bob'}) => Message(
  id: UniqueId.fromUniqueString(id),
  senderId: UniqueId.fromUniqueString(from),
  imageUrls: const KtList.empty(),
  content: Content('Salut'),
  lastUpdatedAt: _noon.add(Duration(minutes: minute)),
  isEdited: false,
);

class _Reads implements IChatReads {
  final marked = <(String, DateTime)>[];

  @override
  Future<void> markRead(UniqueId chatId, DateTime sentAt) async =>
      marked.add((chatId.getOrCrash(), sentAt));

  @override
  Stream<ChatReads> watch() => const Stream.empty();
}

void main() {
  late FakePresence presence;
  late FakePrivacy privacy;
  late _Reads reads;

  setUp(() {
    presence = FakePresence();
    privacy = FakePrivacy();
    reads = _Reads();
    addTearDown(presence.close);
    addTearDown(privacy.close);
  });

  Future<ChatActivityBloc> open() async {
    final bloc = ChatActivityBloc(presence, privacy, reads: reads);
    addTearDown(bloc.close);
    bloc.add(ChatActivityEvent.started(chatId: _chatId, otherUserId: _bob));
    await pumpEventQueue();
    return bloc;
  }

  Future<void> show(ChatActivityBloc bloc, Message newest) async {
    bloc.add(ChatActivityEvent.messagesShown(newest));
    await pumpEventQueue();
  }

  List<String> readCalls() =>
      presence.calls.where((call) => call.startsWith('read')).toList();

  test(
    'messages shown are read, on the phone and for the other person',
    () async {
      final bloc = await open();

      await show(bloc, _message('message-1', 1));

      expect(readCalls(), ['read uid-alice_uid-bob message-1']);
      expect(reads.marked, [
        ('uid-alice_uid-bob', _noon.add(const Duration(minutes: 1))),
      ]);
    },
  );

  test('the other person is told only when the user read further', () async {
    final bloc = await open();

    await show(bloc, _message('message-2', 2));
    await show(bloc, _message('message-2', 2));
    await show(bloc, _message('message-1', 1));
    await show(bloc, _message('message-3', 3, from: 'uid-alice'));

    expect(readCalls(), [
      'read uid-alice_uid-bob message-2',
      'read uid-alice_uid-bob message-3',
    ]);
  });

  test('shows how far the other person read', () async {
    final bloc = await open();

    presence.reads.add(_noon.add(const Duration(minutes: 4)));
    await pumpEventQueue();

    expect(bloc.state.seenUpTo, _noon.add(const Duration(minutes: 4)));
  });

  group('with read receipts off', () {
    setUp(
      () => privacy = FakePrivacy(
        const PrivacySettings(shareReadReceipts: false),
      ),
    );

    test('reading is kept on the phone only', () async {
      final bloc = await open();

      await show(bloc, _message('message-1', 1));

      expect(readCalls(), isEmpty);
      expect(reads.marked, hasLength(1));
    });

    test("the other person's reading is not watched", () async {
      final bloc = await open();

      presence.reads.add(_noon);
      await pumpEventQueue();

      expect(presence.readWatches, 0);
      expect(bloc.state.seenUpTo, isNull);
    });

    test('turning them on tells the other person what is on screen', () async {
      final bloc = await open();
      await show(bloc, _message('message-1', 1));

      privacy.change(const PrivacySettings());
      await pumpEventQueue();

      expect(readCalls(), ['read uid-alice_uid-bob message-1']);
      expect(presence.readWatches, 1);
      expect(bloc.state.seenUpTo, isNull);
    });
  });

  test('turning them off hides how far the other person read', () async {
    final bloc = await open();
    presence.reads.add(_noon);
    await pumpEventQueue();

    privacy.change(const PrivacySettings(shareReadReceipts: false));
    await pumpEventQueue();

    expect(bloc.state.seenUpTo, isNull);
  });
}
