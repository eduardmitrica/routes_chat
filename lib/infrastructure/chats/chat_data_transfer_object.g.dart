// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_data_transfer_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatDataTransferObject _$ChatDataTransferObjectFromJson(
  Map<String, dynamic> json,
) => _ChatDataTransferObject(
  participants: (json['participants'] as List<dynamic>)
      .map((e) => Map<String, String>.from(e as Map))
      .toList(),
  participantIds: (json['participantIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastMessage: const MessageDataTransferObjectConverter().fromJson(
    json['lastMessage'] as Map<String, dynamic>,
  ),
  keyGenerations: const KeyGenerationsConverter().fromJson(
    json['keyGenerations'],
  ),
  currentKeyGeneration: (json['currentKeyGeneration'] as num).toInt(),
  serverTimeStamp: const ServerTimestampConverter().fromJson(
    json['serverTimeStamp'],
  ),
);

Map<String, dynamic> _$ChatDataTransferObjectToJson(
  _ChatDataTransferObject instance,
) => <String, dynamic>{
  'participants': instance.participants,
  'participantIds': instance.participantIds,
  'lastMessage': const MessageDataTransferObjectConverter().toJson(
    instance.lastMessage,
  ),
  'keyGenerations': const KeyGenerationsConverter().toJson(
    instance.keyGenerations,
  ),
  'currentKeyGeneration': instance.currentKeyGeneration,
  'serverTimeStamp': const ServerTimestampConverter().toJson(
    instance.serverTimeStamp,
  ),
};
