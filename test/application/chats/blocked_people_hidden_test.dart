import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_activity/chat_activity_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/chats/messages/messages_watcher/messages_watcher_bloc.dart';
import 'package:routes_chat/application/friend_requests/received_friend_requests_watcher/received_friend_requests_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_page.dart';
import 'package:routes_chat/domain/chats/messages/message_reaction.dart';
import 'package:routes_chat/domain/chats/messages/message_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/failures.dart';
import 'package:routes_chat/domain/friend_requests/friend_request.dart';
import 'package:routes_chat/domain/friend_requests/friend_requests_repository_interface.dart';
import 'package:routes_chat/domain/friend_requests/value_objects.dart';

import '../../helpers/outbox_fakes.dart';
import '../../helpers/presence_fakes.dart';
import '../../helpers/safety_fakes.dart';

final _noon = DateTime.utc(2026, 9, 16, 12);

Message _message(String id, String from, int minute) => Message(
  id: UniqueId.fromUniqueString(id),
  senderId: UniqueId.fromUniqueString(from),
  imageUrls: const KtList.empty(),
  content: Content('Salut'),
  lastUpdatedAt: _noon.add(Duration(minutes: minute)),
  isEdited: false,
);

class _Messages implements IMessageRepository {
  final latest = StreamController<Either<MessageFailure, MessagePage>>();
  final reactions =
      StreamController<
        Either<MessageFailure, KtList<MessageReaction>>
      >.broadcast();

  @override
  Stream<Either<MessageFailure, MessagePage>> watchLatestForChatWithId(
    UniqueId chatId, {
    required int limit,
  }) => latest.stream;

  @override
  Stream<Either<MessageFailure, KtList<MessageReaction>>> watchReactions(
    UniqueId chatId, {
    required DateTime since,
  }) => reactions.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

class _FriendRequests implements IFriendRequestsRepository {
  final received =
      StreamController<Either<FriendRequestFailure, KtList<FriendRequest>>>();

  @override
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
  watchReceivedForCurrentUser() => received.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeBlockList blockList;

  setUp(() {
    blockList = FakeBlockList();
    addTearDown(blockList.close);
  });

  Future<void> changeBlocks(dynamic blocks) async {
    blockList.change(blocks);
    await pumpEventQueue();
  }

  group('in a chat', () {
    late _Messages messages;
    late MessagesWatcherBloc bloc;

    setUp(() async {
      messages = _Messages();
      bloc = MessagesWatcherBloc(messages, blocks: blockList);
      addTearDown(bloc.close);
      bloc.add(
        MessagesWatcherEvent.watchStarted(
          UniqueId.fromUniqueString('uid-alice_uid-bob'),
        ),
      );
      await pumpEventQueue();
      messages.latest.add(
        Right(
          MessagePage(
            KtList.of(
              _message('before', 'uid-bob', 1),
              _message('mine', 'uid-alice', 5),
              _message('while-blocked', 'uid-bob', 10),
            ),
            reachesStart: true,
          ),
        ),
      );
      await pumpEventQueue();
    });

    List<String> shown() => [
      for (final message in bloc.state.messages.iter) message.id.getOrCrash(),
    ];

    test(
      'what a blocked person sent while blocked is hidden, for good',
      () async {
        expect(shown(), ['before', 'mine', 'while-blocked']);

        await changeBlocks(
          blocking('uid-bob', since: _noon.add(const Duration(minutes: 8))),
        );
        expect(shown(), ['before', 'mine']);

        await changeBlocks(
          blocking(
            'uid-bob',
            earlier: [
              (
                from: _noon.add(const Duration(minutes: 8)),
                to: _noon.add(const Duration(minutes: 20)),
              ),
            ],
          ),
        );
        expect(shown(), ['before', 'mine']);
      },
    );

    test("a blocked person's reactions are hidden", () async {
      messages.reactions.add(
        Right(
          KtList.of(
            MessageReaction(
              messageId: UniqueId.fromUniqueString('mine'),
              userId: UniqueId.fromUniqueString('uid-bob'),
              emoji: '😡',
            ),
          ),
        ),
      );
      await pumpEventQueue();

      await changeBlocks(blocking('uid-bob', since: _noon));

      expect(
        bloc.state.messages
            .first((message) => message.id.getOrCrash() == 'mine')
            .reactions
            .isEmpty(),
        isTrue,
      );
    });
  });

  test('in the chat list, a chat with a blocked person says so, and is never '
      'unread', () async {
    final session = signedInAlice();
    addTearDown(session.end);
    final chats = _Chats();
    final reads = _Reads();
    final bloc = ChatsWatcherBloc(
      chats,
      session,
      reads: reads,
      blocks: blockList,
    );
    addTearDown(bloc.close);
    bloc.add(const ChatsWatcherEvent.watchAllStarted());
    await pumpEventQueue();
    reads.reads.add(ChatReads(since: _noon));
    final chat = Chat(
      id: UniqueId.fromUniqueString(aliceAndBob),
      participantsList: ParticipantsList(
        KtList.of(
          Tuple2(UniqueId.fromUniqueString('uid-alice'), UniqueId.empty()),
          Tuple2(UniqueId.fromUniqueString('uid-bob'), UniqueId.empty()),
        ),
      ),
      lastMessage: _message('last', 'uid-bob', 30),
    );
    chats.chats.add(right(KtList.of(chat)));
    await pumpEventQueue();
    expect((bloc.state as ChatsWatcherLoadSuccess).unreadChatIds, {
      aliceAndBob,
    });

    await changeBlocks(blocking('uid-bob', since: _noon));
    final blocked = bloc.state as ChatsWatcherLoadSuccess;
    expect(blocked.blockedChatIds, {aliceAndBob});
    expect(blocked.hiddenPreviewChatIds, {aliceAndBob});
    expect(blocked.unreadChatIds, isEmpty);

    await changeBlocks(
      blocking(
        'uid-bob',
        earlier: [(from: _noon, to: _noon.add(const Duration(hours: 1)))],
      ),
    );
    final unblocked = bloc.state as ChatsWatcherLoadSuccess;
    expect(unblocked.blockedChatIds, isEmpty);
    expect(unblocked.hiddenPreviewChatIds, {aliceAndBob});
    expect(unblocked.unreadChatIds, isEmpty);
  });

  test('friend requests from a blocked person are hidden', () async {
    final friendRequests = _FriendRequests();
    final bloc = ReceivedFriendRequestsWatcherBloc(
      friendRequests,
      blocks: blockList,
    );
    addTearDown(bloc.close);
    bloc.add(const ReceivedFriendRequestsWatcherEvent.watchAllStarted());
    await pumpEventQueue();
    FriendRequest from(String sender) => FriendRequest(
      id: UniqueId.fromUniqueString('uid-alice_$sender'),
      senderId: UniqueId.fromUniqueString(sender),
      receiverId: UniqueId.fromUniqueString('uid-alice'),
      status: Status(Pending()),
    );
    friendRequests.received.add(
      right(KtList.of(from('uid-bob'), from('uid-carol'))),
    );
    await pumpEventQueue();

    await changeBlocks(blocking('uid-bob', since: _noon));
    List<String> senders() => [
      for (final request
          in (bloc.state as ReceivedFriendRequestsWatcherLoadSuccess)
              .friendRequests
              .iter)
        request.senderId.getOrCrash(),
    ];
    expect(senders(), ['uid-carol']);

    await changeBlocks(blocking('uid-bob'));
    expect(senders(), ['uid-bob', 'uid-carol']);
  });

  group('with a blocked person', () {
    late FakePresence presence;
    late FakePrivacy privacy;
    late ChatActivityBloc bloc;

    setUp(() async {
      presence = FakePresence();
      privacy = FakePrivacy();
      addTearDown(presence.close);
      addTearDown(privacy.close);
      blockList.blocks = blocking('uid-bob', since: _noon);
      bloc = ChatActivityBloc(presence, privacy, blocks: blockList);
      addTearDown(bloc.close);
      bloc.add(
        ChatActivityEvent.started(
          chatId: UniqueId.fromUniqueString(aliceAndBob),
          otherUserId: UniqueId.fromUniqueString('uid-bob'),
        ),
      );
      await pumpEventQueue();
    });

    test('the user is never shown reading', () async {
      bloc.add(
        ChatActivityEvent.messagesShown(_message('message-1', 'uid-bob', 1)),
      );
      await pumpEventQueue();

      expect(presence.calls.where((call) => call.startsWith('read')), isEmpty);
    });

    test('nothing they do shows', () async {
      presence.typing.add(DateTime.now());
      presence.reads.add(_noon.add(const Duration(hours: 1)));
      await pumpEventQueue();

      expect(bloc.state, const ChatActivityState());
    });
  });
}
