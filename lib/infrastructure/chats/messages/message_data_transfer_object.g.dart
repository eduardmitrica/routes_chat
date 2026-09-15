// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data_transfer_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageDataTransferObject _$MessageDataTransferObjectFromJson(
  Map<String, dynamic> json,
) => _MessageDataTransferObject(
  senderId: json['senderId'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  reactions:
      (json['reactions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  content: const OptionalEncryptedContentConverter().fromJson(json['content']),
  isEdited: json['isEdited'] as bool? ?? false,
  deleted: json['deleted'] as bool?,
  serverTimeStamp: const ServerTimestampConverter().fromJson(
    json['serverTimeStamp'],
  ),
);

Map<String, dynamic> _$MessageDataTransferObjectToJson(
  _MessageDataTransferObject instance,
) => <String, dynamic>{
  'senderId': instance.senderId,
  'imageUrls': instance.imageUrls,
  'reactions': instance.reactions,
  'content': ?const OptionalEncryptedContentConverter().toJson(
    instance.content,
  ),
  'isEdited': instance.isEdited,
  'deleted': ?instance.deleted,
  'serverTimeStamp': const ServerTimestampConverter().toJson(
    instance.serverTimeStamp,
  ),
};
