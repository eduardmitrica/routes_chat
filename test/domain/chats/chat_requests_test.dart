import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_requests.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

final _noon = DateTime.utc(2026, 9, 16, 12);

Chat _chat({required String lastFrom, DateTime? sentAt}) => Chat(
  id: UniqueId.fromUniqueString('uid-alice_uid-bob'),
  participantsList: ParticipantsList(
    KtList.of(
      Tuple2(UniqueId.fromUniqueString('uid-alice'), UniqueId.empty()),
      Tuple2(UniqueId.fromUniqueString('uid-bob'), UniqueId.empty()),
    ),
  ),
  lastMessage: Message(
    id: UniqueId.fromUniqueString('last'),
    senderId: UniqueId.fromUniqueString(lastFrom),
    imageUrls: const KtList.empty(),
    content: Content('Salut'),
    lastUpdatedAt: sentAt ?? _noon,
    isEdited: false,
  ),
);

ChatPlace _placeOf(
  Chat chat, {
  bool isFriend = false,
  ChatRequests requests = const ChatRequests(),
}) => placeOf(
  chat,
  'uid-alice',
  isFriend: isFriend,
  requests: requests,
  startedByUser: lastMessageIsFrom(chat, 'uid-alice'),
);

void main() {
  group('where a chat belongs', () {
    test('a friend\'s chat is among the chats, whatever was decided', () {
      expect(
        _placeOf(_chat(lastFrom: 'uid-bob'), isFriend: true),
        ChatPlace.chats,
      );
      expect(
        _placeOf(
          _chat(lastFrom: 'uid-bob'),
          isFriend: true,
          requests: ChatRequests(
            byChatId: {
              'uid-alice_uid-bob': ChatRequestDecision(
                ChatRequestState.deleted,
                _noon,
              ),
            },
          ),
        ),
        ChatPlace.chats,
      );
    });

    test('a first message from someone else waits as a request', () {
      expect(_placeOf(_chat(lastFrom: 'uid-bob')), ChatPlace.request);
    });

    test('a chat the user wrote in is theirs', () {
      expect(_placeOf(_chat(lastFrom: 'uid-alice')), ChatPlace.chats);
    });

    test('accepting takes it into the chats', () {
      expect(
        _placeOf(
          _chat(lastFrom: 'uid-bob'),
          requests: ChatRequests(
            byChatId: {
              'uid-alice_uid-bob': ChatRequestDecision(
                ChatRequestState.accepted,
                _noon,
              ),
            },
          ),
        ),
        ChatPlace.chats,
      );
    });

    test('deleting hides it, and a later message brings it back', () {
      final deleted = ChatRequests(
        byChatId: {
          'uid-alice_uid-bob': ChatRequestDecision(
            ChatRequestState.deleted,
            _noon,
          ),
        },
      );
      expect(
        _placeOf(
          _chat(
            lastFrom: 'uid-bob',
            sentAt: _noon.subtract(const Duration(minutes: 1)),
          ),
          requests: deleted,
        ),
        ChatPlace.hidden,
      );
      expect(
        _placeOf(
          _chat(
            lastFrom: 'uid-bob',
            sentAt: _noon.add(const Duration(minutes: 1)),
          ),
          requests: deleted,
        ),
        ChatPlace.request,
      );
    });

    test('taking no messages from strangers hides them all', () {
      expect(
        _placeOf(
          _chat(lastFrom: 'uid-bob'),
          requests: const ChatRequests(allowFromAnyone: false),
        ),
        ChatPlace.hidden,
      );
      // A friend still comes through.
      expect(
        _placeOf(
          _chat(lastFrom: 'uid-bob'),
          isFriend: true,
          requests: const ChatRequests(allowFromAnyone: false),
        ),
        ChatPlace.chats,
      );
    });
  });

  group('stored decisions', () {
    test('read back what was written, and nothing else', () {
      for (final state in ChatRequestState.values) {
        expect(ChatRequestState.fromStored(state.storedName), state);
      }
      expect(ChatRequestState.fromStored('ignored'), isNull);
      expect(ChatRequestState.fromStored(null), isNull);
      expect(ChatRequestState.fromStored(7), isNull);
    });

    test('the names are the ones firestore.rules accept', () {
      expect(ChatRequestState.accepted.storedName, 'accepted');
      expect(ChatRequestState.deleted.storedName, 'deleted');
    });
  });

  test('what is decided never reaches the logs', () {
    final requests = ChatRequests(
      byChatId: {
        'uid-alice_uid-bob': ChatRequestDecision(
          ChatRequestState.accepted,
          _noon,
        ),
      },
    );
    expect(requests.toString(), isNot(contains('uid-bob')));
    expect(requests.toString(), contains('1 decided'));
  });
}
