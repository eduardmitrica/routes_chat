// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/chats/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import 'messages/message_data_transfer_object.dart';

part 'chat_data_transfer_object.freezed.dart';

part 'chat_data_transfer_object.g.dart';

@freezed
abstract class ChatDataTransferObject implements _$ChatDataTransferObject {
  const ChatDataTransferObject._();

  const factory ChatDataTransferObject(
          {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
          required List<(String, String)> participants,
          required List<MessageDataTransferObject> messages,
          @ServerTimestampConverter() required FieldValue serverTimeStamp}) =
      _ChatDataTransferObject;

  factory ChatDataTransferObject.fromJson(Map<String, dynamic> json) =>
      _$ChatDataTransferObjectFromJson(json);

  Chat toDomain() => Chat(
        id: UniqueId.fromUniqueString(id!),
        participantsList: ParticipantsList.fromListOfTuples(participants),
        messages:
            messages.map((message) => message.toDomain()).toImmutableList(),
      );

  factory ChatDataTransferObject.fromDomain(Chat chat) {
    return ChatDataTransferObject(
      id: chat.id.getOrCrash(),
      participants: chat.participantsList
          .getOrCrash()
          .map((participant) => (
                participant.value1.getOrCrash(),
                participant.value2.getOrCrash()
              ))
          .asList(),
      messages: chat.messages
          .map((message) => MessageDataTransferObject.fromDomain(message))
          .asList(),
      serverTimeStamp: FieldValue.serverTimestamp(),
    );
  }

  factory ChatDataTransferObject.fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot) =>
      ChatDataTransferObject.fromJson(documentSnapshot.data()!)
          .copyWith(id: documentSnapshot.id);
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