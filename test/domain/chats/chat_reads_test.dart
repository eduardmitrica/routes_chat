import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/chat_reads.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

final _noon = DateTime.utc(2026, 9, 16, 12);

Chat _chat({required String lastFrom, required DateTime? sentAt}) => Chat(
  id: UniqueId.fromUniqueString('uid-alice_uid-bob'),
  participantsList: ParticipantsList(
    KtList.of(
      Tuple2(UniqueId.fromUniqueString('uid-alice'), UniqueId.empty()),
      Tuple2(UniqueId.fromUniqueString('uid-bob'), UniqueId.empty()),
    ),
  ),
  lastMessage: Message(
    id: UniqueId.fromUniqueString('message-1'),
    senderId: UniqueId.fromUniqueString(lastFrom),
    imageUrls: const KtList.empty(),
    content: Content('Salut'),
    lastUpdatedAt: sentAt,
    isEdited: false,
  ),
);

void main() {
  final reads = ChatReads(
    since: _noon.subtract(const Duration(days: 1)),
    readUpTo: {'uid-alice_uid-bob': _noon},
  );

  test('a chat is unread when someone else wrote after what was read', () {
    expect(
      reads.isUnread(
        _chat(
          lastFrom: 'uid-bob',
          sentAt: _noon.add(const Duration(minutes: 1)),
        ),
        'uid-alice',
      ),
      isTrue,
    );
  });

  test('a message read, or older, leaves the chat read', () {
    expect(
      reads.isUnread(_chat(lastFrom: 'uid-bob', sentAt: _noon), 'uid-alice'),
      isFalse,
    );
  });

  test("the user's own last message never makes a chat unread", () {
    expect(
      reads.isUnread(
        _chat(
          lastFrom: 'uid-alice',
          sentAt: _noon.add(const Duration(hours: 1)),
        ),
        'uid-alice',
      ),
      isFalse,
    );
  });

  test('a chat never opened is unread only for what came after the phone '
      'started keeping track', () {
    final fresh = ChatReads(since: _noon);

    expect(
      fresh.isUnread(
        _chat(
          lastFrom: 'uid-bob',
          sentAt: _noon.subtract(const Duration(days: 3)),
        ),
        'uid-alice',
      ),
      isFalse,
    );
    expect(
      fresh.isUnread(
        _chat(
          lastFrom: 'uid-bob',
          sentAt: _noon.add(const Duration(seconds: 1)),
        ),
        'uid-alice',
      ),
      isTrue,
    );
  });

  test('a message still on its way does not count', () {
    expect(
      reads.isUnread(_chat(lastFrom: 'uid-bob', sentAt: null), 'uid-alice'),
      isFalse,
    );
  });
}
