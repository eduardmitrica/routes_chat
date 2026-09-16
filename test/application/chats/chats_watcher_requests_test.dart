import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/chats/chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/chat_requests.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/failures.dart';
import 'package:routes_chat/domain/friend_requests/friend_request.dart';
import 'package:routes_chat/domain/friend_requests/friend_requests_repository_interface.dart';
import 'package:routes_chat/domain/friend_requests/value_objects.dart';

import '../../helpers/outbox_fakes.dart';

final _noon = DateTime.utc(2026, 9, 16, 12);

Chat _chatWith(String other, {required String lastFrom, int minute = 0}) =>
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

class _Friends implements IFriendRequestsRepository {
  final friends =
      StreamController<
        Either<FriendRequestFailure, KtList<FriendRequest>>
      >.broadcast();

  @override
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
  watchFriendsForCurrentUser() => friends.stream;

  /// Alice is friends with everyone in [ids].
  void friendsAre(List<String> ids) => friends.add(
    right(
      KtList.from(
        ids.map(
          (id) => FriendRequest(
            id: UniqueId.fromUniqueString('friendship-$id'),
            senderId: UniqueId.fromUniqueString('uid-alice'),
            receiverId: UniqueId.fromUniqueString(id),
            status: Status(Accepted()),
          ),
        ),
      ),
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// What the user decided, as a bloc would hand it over.
class _Requests implements IChatRequests {
  final _changes = StreamController<ChatRequests>.broadcast();
  ChatRequests _now = const ChatRequests();

  @override
  ChatRequests get requests => _now;

  @override
  Stream<ChatRequests> get requestsChanges => _changes.stream;

  void change(ChatRequests requests) {
    _now = requests;
    _changes.add(requests);
  }
}

void main() {
  test(
    'chats from people who are not friends wait, until accepted or deleted',
    () async {
      final session = signedInAlice();
      addTearDown(session.end);
      final chats = _Chats();
      final reads = _Reads();
      final friends = _Friends();
      final requests = _Requests();
      final bloc = ChatsWatcherBloc(
        chats,
        session,
        reads: reads,
        requests: requests,
        friendRequests: friends,
      );
      addTearDown(bloc.close);
      bloc.add(const ChatsWatcherEvent.watchAllStarted());
      await pumpEventQueue();

      reads.reads.add(
        ChatReads(since: _noon.subtract(const Duration(days: 1))),
      );
      friends.friendsAre(['uid-bob']);
      chats.chats.add(
        right(
          KtList.of(
            // A friend.
            _chatWith('uid-bob', lastFrom: 'uid-bob'),
            // A stranger who wrote first.
            _chatWith('uid-carol', lastFrom: 'uid-carol'),
            // A stranger the user wrote to.
            _chatWith('uid-dan', lastFrom: 'uid-alice'),
          ),
        ),
      );
      await pumpEventQueue();

      var state = bloc.state as ChatsWatcherLoadSuccess;
      expect(state.requestChatIds, {'uid-alice_uid-carol'});
      expect(state.hiddenChatIds, isEmpty);
      expect(state.chatsInList.map((chat) => chat.id.getOrCrash()).asList(), [
        'uid-alice_uid-bob',
        'uid-alice_uid-dan',
      ]);
      expect(state.requests.size, 1);
      // A chat that waits never counts as unread.
      expect(state.unreadChatIds, {'uid-alice_uid-bob'});

      // Accepted: an ordinary chat, and unread like any other.
      requests.change(
        ChatRequests(
          byChatId: {
            'uid-alice_uid-carol': ChatRequestDecision(
              ChatRequestState.accepted,
              _noon,
            ),
          },
        ),
      );
      await pumpEventQueue();
      state = bloc.state as ChatsWatcherLoadSuccess;
      expect(state.requestChatIds, isEmpty);
      expect(state.unreadChatIds, contains('uid-alice_uid-carol'));

      // Deleted: out of sight, and not unread.
      requests.change(
        ChatRequests(
          byChatId: {
            'uid-alice_uid-carol': ChatRequestDecision(
              ChatRequestState.deleted,
              _noon.add(const Duration(minutes: 1)),
            ),
          },
        ),
      );
      await pumpEventQueue();
      state = bloc.state as ChatsWatcherLoadSuccess;
      expect(state.hiddenChatIds, {'uid-alice_uid-carol'});
      expect(state.requestChatIds, isEmpty);
      expect(state.unreadChatIds, isNot(contains('uid-alice_uid-carol')));
      expect(state.chatsInList.map((chat) => chat.id.getOrCrash()).asList(), [
        'uid-alice_uid-bob',
        'uid-alice_uid-dan',
      ]);

      // Taking no messages from strangers hides them all.
      requests.change(const ChatRequests(allowFromAnyone: false));
      await pumpEventQueue();
      state = bloc.state as ChatsWatcherLoadSuccess;
      expect(state.hiddenChatIds, {'uid-alice_uid-carol'});
    },
  );
}
