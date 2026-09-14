// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

import 'messages/message_data_transfer_object.dart';

part 'chat_data_transfer_object.freezed.dart';

part 'chat_data_transfer_object.g.dart';

@freezed
abstract class ChatDataTransferObject with _$ChatDataTransferObject {
  const ChatDataTransferObject._();

  const factory ChatDataTransferObject({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required List<Map<String, String>> participants,

    /// Flat mirror of the participant ids in [participants].
    ///
    /// [participants] is a list of maps (participant id -> last seen message
    /// id) and Firestore security rules cannot iterate that shape, so
    /// "the writer must be a participant" is not expressible over it. This
    /// duplicated field exists purely so the rules can enforce it, and is
    /// always derived in [fromDomain] rather than set by callers.
    ///
    /// Stored sorted, so the rules can require the chat id to equal
    /// `participantIds.join('_')`, the format compositeId produces.
    required List<String> participantIds,
    @MessageDataTransferObjectConverter()
    required MessageDataTransferObject lastMessage,

    /// The chat's key, sealed to each participant, by participant id. Written
    /// when the chat is created and never changed; see docs/e2ee.md.
    @SealedChatKeysConverter() required Map<String, SealedChatKey> chatKeys,
    @ServerTimestampConverter() required FieldValue serverTimeStamp,
  }) = _ChatDataTransferObject;

  factory ChatDataTransferObject.fromJson(Map<String, dynamic> json) =>
      _$ChatDataTransferObjectFromJson(json);

  /// The chat, with [lastMessageContent] as its last message's decrypted text.
  Chat toDomain({required String lastMessageContent}) => Chat(
    id: UniqueId.fromUniqueString(id!),
    participantsList: ParticipantsList.fromListOfMaps(participants),
    lastMessage: Message(
      id: UniqueId.fromUniqueString(lastMessage.id!),
      senderId: UniqueId.fromUniqueString(lastMessage.senderId),
      content: Content(lastMessageContent),
      reactions: lastMessage.reactions
          .map(
            (reactionIdString) => UniqueId.fromUniqueString(reactionIdString),
          )
          .toImmutableList(),
      imageUrls: lastMessage.imageUrls
          .map((imageUrlString) => ImageUrl(imageUrlString))
          .toImmutableList(),
      isEdited: lastMessage.isEdited,
      repliedMessageId: UniqueId.fromUniqueString(lastMessage.repliedMessageId),
      lastUpdatedAt: lastMessage.timeStamp,
    ),
  );

  /// [chat] as stored, with its last message's text encrypted as
  /// [lastMessageContent] and the chat key sealed as [chatKeys].
  factory ChatDataTransferObject.fromDomain(
    Chat chat, {
    required EncryptedContent lastMessageContent,
    required Map<String, SealedChatKey> chatKeys,
  }) {
    return ChatDataTransferObject(
      id: chat.id.getOrCrash(),
      participants: chat.participantsList
          .getOrCrash()
          .map(
            (participant) => {
              participant.value1.getOrCrash(): participant.value2.getOrCrash(),
            },
          )
          .asList(),
      participantIds:
          chat.participantsList
              .getOrCrash()
              .map((participant) => participant.value1.getOrCrash())
              .asList()
              .toList()
            ..sort(),
      lastMessage: MessageDataTransferObject.fromDomain(
        chat.lastMessage,
        content: lastMessageContent,
      ),
      chatKeys: chatKeys,
      serverTimeStamp: FieldValue.serverTimestamp(),
    );
  }

  factory ChatDataTransferObject.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
  ) => ChatDataTransferObject.fromJson(
    documentSnapshot.data()!,
  ).copyWith(id: documentSnapshot.id);
}

// from Json, to Json
class ServerTimestampConverter implements JsonConverter<FieldValue, Object?> {
  // For annotation it has to be constant
  const ServerTimestampConverter();

  @override
  FieldValue fromJson(Object? json) {
    return FieldValue.serverTimestamp();
  }

  @override
  Object toJson(FieldValue fieldValue) => fieldValue;
}

class MessageDataTransferObjectConverter
    implements JsonConverter<MessageDataTransferObject, Map<String, dynamic>> {
  const MessageDataTransferObjectConverter();

  @override
  MessageDataTransferObject fromJson(Map<String, dynamic> json) {
    return MessageDataTransferObject.fromJson(json).copyWith(
      id: json['id'],
      timeStamp: (json['serverTimeStamp'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toJson(MessageDataTransferObject messageDto) {
    return messageDto.toJsonWithId();
  }
}

class SealedChatKeysConverter
    implements JsonConverter<Map<String, SealedChatKey>, Object?> {
  const SealedChatKeysConverter();

  @override
  Map<String, SealedChatKey> fromJson(Object? json) =>
      SealedChatKey.mapFromJson(json);

  @override
  Object toJson(Map<String, SealedChatKey> sealedKeys) =>
      SealedChatKey.mapToJson(sealedKeys);
}
