import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/groups/groups_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/failures.dart';
import 'package:routes_chat/domain/friend_requests/friend_request.dart';
import 'package:routes_chat/domain/friend_requests/friend_requests_repository_interface.dart';
import 'package:routes_chat/domain/friend_requests/value_objects.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/domain/groups/group_failure.dart';
import 'package:routes_chat/domain/groups/group_repository_interface.dart';

import '../../helpers/outbox_fakes.dart';
import '../../helpers/safety_fakes.dart';

Group _invitation(String id, {required String from}) => Group(
  id: UniqueId.fromUniqueString(id),
  memberIds: [from],
  invitedIds: const ['uid-alice'],
  invitedBy: {'uid-alice': from},
  adminIds: [from],
);

class _Groups implements IGroupRepository {
  final joined = StreamController<Either<GroupFailure, KtList<Group>>>();
  final invitations = StreamController<Either<GroupFailure, KtList<Group>>>();
  final accepted = <String>[];
  final declined = <String>[];

  @override
  Stream<Either<GroupFailure, KtList<Group>>> watchJoined() => joined.stream;

  @override
  Stream<Either<GroupFailure, KtList<Group>>> watchInvitations() =>
      invitations.stream;

  @override
  Future<Either<GroupFailure, Unit>> accept(UniqueId groupId) async {
    accepted.add(groupId.getOrCrash());
    return right(unit);
  }

  @override
  Future<Either<GroupFailure, Unit>> decline(UniqueId groupId) async {
    declined.add(groupId.getOrCrash());
    return right(unit);
  }

  @override
  Future<Either<GroupFailure, UniqueId>> create(
    List<UniqueId> invitees, {
    String name = '',
  }) => throw UnimplementedError();

  void invite(List<Group> groups) =>
      invitations.add(right(groups.toImmutableList()));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Friends implements IFriendRequestsRepository {
  final friends =
      StreamController<Either<FriendRequestFailure, KtList<FriendRequest>>>();

  @override
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
  watchFriendsForCurrentUser() => friends.stream;

  void are(List<String> ids) => friends.add(
    right(
      KtList.from(
        ids.map(
          (id) => FriendRequest(
            id: UniqueId.fromUniqueString('friendship-$id'),
            senderId: UniqueId.fromUniqueString(id),
            receiverId: UniqueId.fromUniqueString('uid-alice'),
            status: Status(Accepted()),
          ),
        ),
      ),
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Groups groups;
  late _Friends friends;
  late FakeBlockList blocks;
  late GroupsWatcherBloc bloc;

  setUp(() async {
    groups = _Groups();
    friends = _Friends();
    blocks = FakeBlockList();
    addTearDown(blocks.close);
    final session = signedInAlice();
    addTearDown(session.end);
    bloc = GroupsWatcherBloc(
      groups,
      session,
      friendRequests: friends,
      blocks: blocks,
    );
    addTearDown(bloc.close);
    bloc.add(const GroupsWatcherEvent.started());
    await pumpEventQueue();
  });

  test('a friend\'s group is joined by itself, once', () async {
    friends.are(['uid-bob']);
    groups.invite([_invitation('group-bob', from: 'uid-bob')]);
    await pumpEventQueue();

    expect(groups.accepted, ['group-bob']);
    expect(bloc.state.invitations.isEmpty(), isTrue);

    // The same invitation arriving again, before the join shows, is not
    // accepted twice.
    groups.invite([_invitation('group-bob', from: 'uid-bob')]);
    await pumpEventQueue();
    expect(groups.accepted, ['group-bob']);
  });

  test('a group from someone who is not a friend asks first', () async {
    friends.are(['uid-bob']);
    groups.invite([_invitation('group-dan', from: 'uid-dan')]);
    await pumpEventQueue();

    expect(groups.accepted, isEmpty);
    expect(
      bloc.state.invitations.map((group) => group.id.getOrCrash()).asList(),
      ['group-dan'],
    );

    bloc.add(
      GroupsWatcherEvent.accepted(UniqueId.fromUniqueString('group-dan')),
    );
    await pumpEventQueue();
    expect(groups.accepted, ['group-dan']);
  });

  test('nothing is asked before the friends are known', () async {
    groups.invite([_invitation('group-bob', from: 'uid-bob')]);
    await pumpEventQueue();
    // Bob may yet turn out to be a friend.
    expect(bloc.state.invitations.isEmpty(), isTrue);
    expect(groups.accepted, isEmpty);

    friends.are(['uid-bob']);
    await pumpEventQueue();
    expect(groups.accepted, ['group-bob']);
  });

  test(
    'a group from someone blocked never shows, and is never joined',
    () async {
      friends.are(['uid-bob']);
      blocks.change(blocking('uid-bob', since: DateTime.utc(2026, 9, 16)));
      groups.invite([
        _invitation('group-bob', from: 'uid-bob'),
        _invitation('group-dan', from: 'uid-dan'),
      ]);
      await pumpEventQueue();

      expect(groups.accepted, isEmpty);
      expect(
        bloc.state.invitations.map((group) => group.id.getOrCrash()).asList(),
        ['group-dan'],
      );
    },
  );

  test('turning a group down tells the server, and nobody else', () async {
    friends.are([]);
    groups.invite([_invitation('group-dan', from: 'uid-dan')]);
    await pumpEventQueue();

    bloc.add(
      GroupsWatcherEvent.declined(UniqueId.fromUniqueString('group-dan')),
    );
    await pumpEventQueue();

    expect(groups.declined, ['group-dan']);
    expect(groups.accepted, isEmpty);
  });

  test('keeps the groups the user is in', () async {
    final joined = Group(
      id: UniqueId.fromUniqueString('group-1'),
      memberIds: const ['uid-alice', 'uid-bob'],
      invitedIds: const [],
      invitedBy: const {},
      adminIds: const ['uid-alice'],
    );
    groups.joined.add(right(KtList.of(joined)));
    await pumpEventQueue();

    expect(bloc.state.loaded, isTrue);
    expect(bloc.state.joined.asList(), [joined]);
  });

  group('unread', () {
    late StreamController<ChatReads> reads;
    late GroupsWatcherBloc withReads;
    final noon = DateTime.utc(2026, 9, 17, 12);

    Group joined(String id, {required String from, required int minute}) =>
        Group(
          id: UniqueId.fromUniqueString(id),
          memberIds: ['uid-alice', from],
          invitedIds: const [],
          invitedBy: const {},
          adminIds: [from],
          lastMessage: Message(
            id: UniqueId.fromUniqueString('m-$id'),
            senderId: UniqueId.fromUniqueString(from),
            imageUrls: const KtList.empty(),
            content: Content('Salut'),
            lastUpdatedAt: noon.add(Duration(minutes: minute)),
            isEdited: false,
          ),
        );

    setUp(() async {
      reads = StreamController<ChatReads>.broadcast();
      addTearDown(reads.close);
      final session = signedInAlice();
      addTearDown(session.end);
      groups = _Groups();
      withReads = GroupsWatcherBloc(
        groups,
        session,
        blocks: blocks,
        reads: _Reads(reads.stream),
      );
      addTearDown(withReads.close);
      withReads.add(const GroupsWatcherEvent.started());
      await pumpEventQueue();
    });

    test(
      "a group ending with someone else's newer message stands out",
      () async {
        reads.add(
          ChatReads(
            since: noon,
            readUpTo: {'group-b': noon.add(const Duration(minutes: 5))},
          ),
        );
        groups.joined.add(
          right(
            KtList.of(
              joined('group-a', from: 'uid-bob', minute: 2),
              joined('group-b', from: 'uid-bob', minute: 4),
              joined('group-c', from: 'uid-alice', minute: 6),
            ),
          ),
        );
        await pumpEventQueue();

        expect(withReads.state.unreadIds, {'group-a'});
      },
    );

    test('reading it, or blocking who wrote, clears it', () async {
      reads.add(ChatReads(since: noon));
      groups.joined.add(
        right(KtList.of(joined('group-a', from: 'uid-bob', minute: 2))),
      );
      await pumpEventQueue();
      expect(withReads.state.unreadIds, {'group-a'});

      reads.add(
        ChatReads(
          since: noon,
          readUpTo: {'group-a': noon.add(const Duration(minutes: 2))},
        ),
      );
      await pumpEventQueue();
      expect(withReads.state.unreadIds, isEmpty);

      reads.add(ChatReads(since: noon));
      await pumpEventQueue();
      blocks.change(blocking('uid-bob', since: noon));
      await pumpEventQueue();
      expect(withReads.state.unreadIds, isEmpty);
    });
  });
}

class _Reads implements IChatReads {
  final Stream<ChatReads> _stream;

  _Reads(this._stream);

  @override
  Stream<ChatReads> watch() => _stream;

  @override
  Future<void> markRead(UniqueId chatId, DateTime sentAt) async {}
}
