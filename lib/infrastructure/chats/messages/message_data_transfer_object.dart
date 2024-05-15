// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';

part 'message_data_transfer_object.freezed.dart';

part 'message_data_transfer_object.g.dart';

@freezed
abstract class MessageDataTransferObject
    implements _$MessageDataTransferObject {
  const MessageDataTransferObject._();

  const factory MessageDataTransferObject(
      {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
      required String senderId,
      required List<String> imageUrls,
      required List<String> reactions,
      required String content,
      required String repliedMessageId,
      required bool isEdited,
      @JsonKey(includeToJson: false, includeFromJson: true) DateTime? timeStamp,
      @ServerTimestampConverter()
      required FieldValue serverTimeStamp}) = _MessageDataTransferObject;

  factory MessageDataTransferObject.fromJson(Map<String, dynamic> json) =>
      _$MessageDataTransferObjectFromJson(json);

  Message toDomain() => Message(
      id: UniqueId.fromUniqueString(id!),
      senderId: UniqueId.fromUniqueString(senderId),
      imageUrls:
          imageUrls.map((imageUrl) => ImageUrl(imageUrl)).toImmutableList(),
      reactions: reactions
          .map((reaction) => UniqueId.fromUniqueString(reaction))
          .toImmutableList(),
      content: Content(content),
      repliedMessageId: UniqueId.fromUniqueString(repliedMessageId),
      lastUpdatedAt: timeStamp!,
      isEdited: isEdited);

  factory MessageDataTransferObject.fromDomain(Message message) {
    return MessageDataTransferObject(
      id: message.id.getOrCrash(),
      senderId: message.senderId.getOrCrash(),
      imageUrls:
          message.imageUrls.map((imageUrl) => imageUrl.getOrCrash()).asList(),
      reactions: message.reactions
          .map((reactionId) => reactionId.getOrCrash())
          .asList(),
      content: message.content.getOrCrash(),
      repliedMessageId: message.repliedMessageId.getOrCrash(),
      isEdited: message.isEdited,
      serverTimeStamp: FieldValue.serverTimestamp(),
    );
  }

  factory MessageDataTransferObject.fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot) =>
      MessageDataTransferObject.fromJson(documentSnapshot.data()!).copyWith(
          id: documentSnapshot.id,
          timeStamp: (documentSnapshot.data()!['serverTimeStamp'] as Timestamp)
              .toDate());
}

// from Json, to Json
class ServerTimestampConverter implements JsonConverter<FieldValue, Object> {
  // For annotation it has to be constant
  const ServerTimestampConverter();

  @override
  FieldValue fromJson(Object json) {
    return FieldValue.serverTimestamp();
  }

  @override
  Object toJson(FieldValue fieldValue) => fieldValue;
}
