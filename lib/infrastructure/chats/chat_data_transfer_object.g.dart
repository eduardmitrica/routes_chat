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
      serverTimeStamp: const ServerTimestampConverter()
          .fromJson(json['serverTimeStamp'] as Object),
    );

Map<String, dynamic> _$$ChatDataTransferObjectImplToJson(
        _$ChatDataTransferObjectImpl instance) =>
    <String, dynamic>{
      'participants': instance.participants,
      'serverTimeStamp':
          const ServerTimestampConverter().toJson(instance.serverTimeStamp),
    };
