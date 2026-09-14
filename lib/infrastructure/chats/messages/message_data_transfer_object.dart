// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';
import 'package:routes_chat/infrastructure/encryption/chat_cipher.dart';

part 'message_data_transfer_object.freezed.dart';

part 'message_data_transfer_object.g.dart';

@freezed
abstract class MessageDataTransferObject with _$MessageDataTransferObject {
  const MessageDataTransferObject._();

  const factory MessageDataTransferObject({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required String senderId,
    required List<String> imageUrls,
    required List<String> reactions,

    /// The message text, encrypted with the chat's key. The repositories,
    /// which hold the key, turn it into text; see docs/e2ee.md.
    @EncryptedContentConverter() required EncryptedContent content,
    required String repliedMessageId,
    required bool isEdited,
    @JsonKey(includeToJson: false, includeFromJson: false) DateTime? timeStamp,
    @ServerTimestampConverter() required FieldValue serverTimeStamp,
  }) = _MessageDataTransferObject;

  factory MessageDataTransferObject.fromJson(Map<String, dynamic> json) =>
      _$MessageDataTransferObjectFromJson(json);

  Map<String, dynamic> toJsonWithId() => toJson()..putIfAbsent('id', () => id);

  /// The message, with [content] as its decrypted text.
  Message toDomain({required String content}) => Message(
    id: UniqueId.fromUniqueString(id!),
    senderId: UniqueId.fromUniqueString(senderId),
    imageUrls: imageUrls
        .map((imageUrl) => ImageUrl(imageUrl))
        .toImmutableList(),
    reactions: reactions
        .map((reaction) => UniqueId.fromUniqueString(reaction))
        .toImmutableList(),
    content: Content(content),
    repliedMessageId: UniqueId.fromUniqueString(repliedMessageId),
    lastUpdatedAt: timeStamp!,
    isEdited: isEdited,
  );

  /// [message] as stored, with [content] as its encrypted text.
  factory MessageDataTransferObject.fromDomain(
    Message message, {
    required EncryptedContent content,
  }) {
    return MessageDataTransferObject(
      id: message.id.getOrCrash(),
      senderId: message.senderId.getOrCrash(),
      imageUrls: message.imageUrls
          .map((imageUrl) => imageUrl.getOrCrash())
          .asList(),
      reactions: message.reactions
          .map((reactionId) => reactionId.getOrCrash())
          .asList(),
      content: content,
      repliedMessageId: message.repliedMessageId.getOrCrash(),
      isEdited: message.isEdited,
      serverTimeStamp: FieldValue.serverTimestamp(),
    );
  }

  factory MessageDataTransferObject.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
  ) => MessageDataTransferObject.fromJson(documentSnapshot.data()!).copyWith(
    id: documentSnapshot.id,
    timeStamp: (documentSnapshot.data()!['serverTimeStamp'] as Timestamp)
        .toDate(),
  );
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

/// Reads plaintext content as an error rather than a message.
class EncryptedContentConverter
    implements JsonConverter<EncryptedContent, Object?> {
  const EncryptedContentConverter();

  @override
  EncryptedContent fromJson(Object? json) => EncryptedContent.fromJson(json);

  @override
  Object toJson(EncryptedContent content) => content.toJson();
}
