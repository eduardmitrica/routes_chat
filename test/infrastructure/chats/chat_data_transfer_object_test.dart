import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/chats/chat_data_transfer_object.dart';

Chat _chatBetween(List<String> participantIds) => Chat(
  id: UniqueId.fromUniqueString('chat-1'),
  participantsList: ParticipantsList(
    participantIds
        .map(
          (id) => Tuple2(
            UniqueId.fromUniqueString(id),
            UniqueId.fromUniqueString('last-seen-$id'),
          ),
        )
        .toImmutableList(),
  ),
  lastMessage: Message(
    id: UniqueId.fromUniqueString('message-1'),
    senderId: UniqueId.fromUniqueString(participantIds.first),
    imageUrls: const KtList.empty(),
    reactions: const KtList.empty(),
    content: Content('hello'),
    repliedMessageId: UniqueId.empty(),
    lastUpdatedAt: null,
    isEdited: false,
  ),
);

void main() {
  // firestore.rules enforces chat writes with
  // `request.auth.uid in request.resource.data.participantIds`. If this field
  // ever drifts from `participants`, every chat write is denied in production
  // while everything still compiles.
  test('participantIds mirrors the ids in participants', () {
    final dto = ChatDataTransferObject.fromDomain(
      _chatBetween(['user-a', 'user-b']),
    );

    expect(dto.participantIds, ['user-a', 'user-b']);
    expect(
      dto.participantIds,
      dto.participants.map((participant) => participant.keys.single).toList(),
      reason: 'participantIds must contain exactly the keys of participants',
    );
  });

  test('participantIds is carried into the Firestore payload', () {
    final json = ChatDataTransferObject.fromDomain(
      _chatBetween(['user-a', 'user-b']),
    ).toJson();

    expect(json['participantIds'], ['user-a', 'user-b']);
  });

  test('participantIds covers group chats, not just pairs', () {
    final dto = ChatDataTransferObject.fromDomain(
      _chatBetween(['user-a', 'user-b', 'user-c']),
    );

    expect(dto.participantIds, ['user-a', 'user-b', 'user-c']);
  });
}
