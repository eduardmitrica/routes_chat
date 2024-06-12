// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data_transfer_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageDataTransferObjectImpl _$$MessageDataTransferObjectImplFromJson(
        Map<String, dynamic> json) =>
    _$MessageDataTransferObjectImpl(
      senderId: json['senderId'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      reactions:
          (json['reactions'] as List<dynamic>).map((e) => e as String).toList(),
      content: json['content'] as String,
      repliedMessageId: json['repliedMessageId'] as String,
      isEdited: json['isEdited'] as bool,
      serverTimeStamp:
          const ServerTimestampConverter().fromJson(json['serverTimeStamp']),
    );

Map<String, dynamic> _$$MessageDataTransferObjectImplToJson(
        _$MessageDataTransferObjectImpl instance) =>
    <String, dynamic>{
      'senderId': instance.senderId,
      'imageUrls': instance.imageUrls,
      'reactions': instance.reactions,
      'content': instance.content,
      'repliedMessageId': instance.repliedMessageId,
      'isEdited': instance.isEdited,
      'serverTimeStamp':
          const ServerTimestampConverter().toJson(instance.serverTimeStamp),
    };
