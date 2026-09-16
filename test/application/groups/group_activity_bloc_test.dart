import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/groups/group_activity_bloc.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/safety/blocks.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';

import '../../helpers/presence_fakes.dart';

final _groupId = UniqueId.fromUniqueString(
  'group-00000000-0000-4000-8000-000000000000',
);
final _noon = DateTime.utc(2026, 9, 17, 12);

Message _message(String id, int minute, {String from = 'uid-ana'}) => Message(
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

class _Blocks implements IBlockList {
  final _changes = StreamController<Blocks>.broadcast();

  @override
  Blocks blocks = const Blocks();

  @override
  Stream<Blocks> get blocksChanges => _changes.stream;

  void block(String userId) {
    blocks = Blocks({
      userId: BlockRecord(
        userId: UniqueId.fromUniqueString(userId),
        blockedSince: _noon,
      ),
    });
    _changes.add(blocks);
  }
}

void main() {
  late FakePresence presence;
  late FakePrivacy privacy;
  late _Reads reads;
  late _Blocks blocks;
  late DateTime now;

  setUp(() {
    presence = FakePresence();
    privacy = FakePrivacy();
    reads = _Reads();
    blocks = _Blocks();
    now = _noon;
    addTearDown(presence.close);
    addTearDown(privacy.close);
  });

  Future<GroupActivityBloc> open() async {
    final bloc = GroupActivityBloc(
      presence,
      privacy,
      reads: reads,
      blocks: blocks,
      now: () => now,
      typingShownFor: const Duration(milliseconds: 50),
    );
    addTearDown(bloc.close);
    bloc.add(GroupActivityEvent.started(_groupId));
    await pumpEventQueue();
    return bloc;
  }

  group('typing', () {
    test('shows who types, who started first first', () async {
      final bloc = await open();

      presence.groupTyping.add({
        'uid-radu': _noon.subtract(const Duration(seconds: 1)),
        'uid-ana': _noon.subtract(const Duration(seconds: 3)),
      });
      await pumpEventQueue();

      expect(bloc.state.typingIds, ['uid-ana', 'uid-radu']);
    });

    test('ends by itself when nobody says so again', () async {
      final bloc = await open();

      presence.groupTyping.add({'uid-ana': _noon});
      await pumpEventQueue();
      expect(bloc.state.typingIds, ['uid-ana']);

      now = _noon.add(const Duration(milliseconds: 60));
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(bloc.state.typingIds, isEmpty);
    });

    test('an old mark, or one that stopped, shows nothing', () async {
      final bloc = await open();

      presence.groupTyping.add({
        'uid-ana': _noon.subtract(const Duration(minutes: 1)),
      });
      await pumpEventQueue();
      expect(bloc.state.typingIds, isEmpty);

      presence.groupTyping.add({'uid-radu': _noon});
      await pumpEventQueue();
      presence.groupTyping.add({});
      await pumpEventQueue();
      expect(bloc.state.typingIds, isEmpty);
    });

    test('nobody blocked shows typing', () async {
      final bloc = await open();

      presence.groupTyping.add({'uid-ana': _noon, 'uid-radu': _noon});
      await pumpEventQueue();
      blocks.block('uid-radu');
      await pumpEventQueue();

      expect(bloc.state.typingIds, ['uid-ana']);
    });

    test('is not watched while the user does not share it', () async {
      privacy = FakePrivacy(const PrivacySettings(shareTyping: false));
      final bloc = await open();

      expect(presence.groupTypingWatches, 0);
      expect(bloc.state.typingIds, isEmpty);
    });
  });

  group('reading', () {
    test('what is shown is read, on the phone and for the group', () async {
      final bloc = await open();

      bloc.add(GroupActivityEvent.messagesShown(_message('message-1', 1)));
      await pumpEventQueue();

      expect(presence.calls, [
        'read group-00000000-0000-4000-8000-000000000000 message-1',
      ]);
      expect(reads.marked.single.$2, _noon.add(const Duration(minutes: 1)));
    });

    test('the group is told only when the user read further', () async {
      final bloc = await open();

      for (final message in [
        _message('message-2', 2),
        _message('message-2', 2),
        _message('message-1', 1),
        _message('message-3', 3, from: 'uid-me'),
      ]) {
        bloc.add(GroupActivityEvent.messagesShown(message));
        await pumpEventQueue();
      }

      expect(presence.calls.map((call) => call.split(' ').last), [
        'message-2',
        'message-3',
      ]);
    });

    test('says who has seen a message, who read furthest last', () async {
      final bloc = await open();

      presence.groupReads.add({
        'uid-ana': _noon.add(const Duration(minutes: 5)),
        'uid-radu': _noon.add(const Duration(minutes: 3)),
        'uid-bogdan': _noon.add(const Duration(minutes: 1)),
      });
      await pumpEventQueue();

      expect(bloc.state.seenBy(_noon.add(const Duration(minutes: 2))), [
        'uid-radu',
        'uid-ana',
      ]);
    });

    test('someone blocked is never shown as having seen', () async {
      final bloc = await open();

      presence.groupReads.add({'uid-ana': _noon, 'uid-radu': _noon});
      blocks.block('uid-ana');
      await pumpEventQueue();

      expect(bloc.state.seenBy(_noon), ['uid-radu']);
    });

    test('with read receipts off, reading stays on the phone', () async {
      privacy = FakePrivacy(const PrivacySettings(shareReadReceipts: false));
      final bloc = await open();

      bloc.add(GroupActivityEvent.messagesShown(_message('message-1', 1)));
      await pumpEventQueue();

      expect(presence.calls, isEmpty);
      expect(reads.marked, hasLength(1));
      expect(presence.groupReadWatches, 0);
    });

    test('turning read receipts off hides who has seen', () async {
      final bloc = await open();
      presence.groupReads.add({'uid-ana': _noon});
      await pumpEventQueue();

      privacy.change(const PrivacySettings(shareReadReceipts: false));
      await pumpEventQueue();

      expect(bloc.state.readUpTo, isEmpty);
    });
  });

  test('its description holds counts only', () {
    final state = GroupActivityState(
      typingIds: const ['uid-ana'],
      readUpTo: {'uid-radu': _noon},
    );
    expect(state.toString(), 'GroupActivityState(1 typing, 1 read markers)');
  });
}
