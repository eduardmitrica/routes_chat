// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_data_transfer_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatDataTransferObjectImpl _$$ChatDataTransferObjectImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatDataTransferObjectImpl(
      participants: (json['participants'] as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      lastMessage: const MessageDataTransferObjectConverter()
          .fromJson(json['lastMessage'] as Map<String, dynamic>),
      serverTimeStamp:
          const ServerTimestampConverter().fromJson(json['serverTimeStamp']),
    );

Map<String, dynamic> _$$ChatDataTransferObjectImplToJson(
        _$ChatDataTransferObjectImpl instance) =>
    <String, dynamic>{
      'participants': instance.participants,
      'lastMessage': const MessageDataTransferObjectConverter()
          .toJson(instance.lastMessage),
      'serverTimeStamp':
          const ServerTimestampConverter().toJson(instance.serverTimeStamp),
    };
