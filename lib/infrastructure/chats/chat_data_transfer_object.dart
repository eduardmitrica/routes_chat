// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/key_reset.dart';
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

    /// Every generation of the chat's key, by number, each sealed to the
    /// participants. A chat starts with generation 1; a participant who
    /// resets their keys adds the next. Generations are never changed or
    /// removed. See docs/e2ee.md.
    @KeyGenerationsConverter() required Map<int, KeyGeneration> keyGenerations,

    /// The generation new messages are encrypted under: the highest.
    required int currentKeyGeneration,
    @ServerTimestampConverter() required FieldValue serverTimeStamp,
  }) = _ChatDataTransferObject;

  factory ChatDataTransferObject.fromJson(Map<String, dynamic> json) =>
      _$ChatDataTransferObjectFromJson(json);

  /// The chat, with [lastMessageContent] as its last message's decrypted text,
  /// or as a placeholder when it could not be decrypted
  /// ([lastMessageReadable] false).
  Chat toDomain({
    required String lastMessageContent,
    required bool lastMessageReadable,
  }) => Chat(
    id: UniqueId.fromUniqueString(id!),
    participantsList: ParticipantsList.fromListOfMaps(participants),
    lastMessage: Message(
      id: UniqueId.fromUniqueString(lastMessage.id!),
      senderId: UniqueId.fromUniqueString(lastMessage.senderId),
      content: Content(lastMessageContent),
      imageUrls: lastMessage.imageUrls
          .map((imageUrlString) => ImageUrl(imageUrlString))
          .toImmutableList(),
      isEdited: lastMessage.isEdited,

      lastUpdatedAt: lastMessage.timeStamp,
      isReadable: lastMessageReadable,
      isDeleted: lastMessage.isDeleted,
      keyGeneration: lastMessage.content?.keyGeneration ?? 1,
    ),
    // Every generation after the first was added by a participant who reset
    // their keys.
    keyResets:
        (keyGenerations.entries.where((entry) => entry.key > 1).toList()
              ..sort((a, b) => a.key.compareTo(b.key)))
            .map(
              (entry) => KeyReset(
                userId: UniqueId.fromUniqueString(entry.value.createdBy),
                keyGeneration: entry.key,
              ),
            )
            .toImmutableList(),
  );

  /// A new [chat] as stored: its last message's text encrypted as
  /// [lastMessageContent], under [firstKeyGeneration] of its key.
  factory ChatDataTransferObject.fromDomain(
    Chat chat, {
    required EncryptedContent lastMessageContent,
    required KeyGeneration firstKeyGeneration,
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
      keyGenerations: {1: firstKeyGeneration},
      currentKeyGeneration: 1,
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

class KeyGenerationsConverter
    implements JsonConverter<Map<int, KeyGeneration>, Object?> {
  const KeyGenerationsConverter();

  @override
  Map<int, KeyGeneration> fromJson(Object? json) =>
      KeyGeneration.mapFromJson(json);

  @override
  Object toJson(Map<int, KeyGeneration> generations) =>
      KeyGeneration.mapToJson(generations);
}
