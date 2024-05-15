// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_data_transfer_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatDataTransferObjectImpl _$$ChatDataTransferObjectImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatDataTransferObjectImpl(
      participants: (json['participants'] as List<dynamic>)
          .map((e) => _$recordConvert(
                e,
                ($jsonValue) => (
                  $jsonValue[r'$1'] as String,
                  $jsonValue[r'$2'] as String,
                ),
              ))
          .toList(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) =>
              MessageDataTransferObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      serverTimeStamp: const ServerTimestampConverter()
          .fromJson(json['serverTimeStamp'] as Object),
    );

Map<String, dynamic> _$$ChatDataTransferObjectImplToJson(
        _$ChatDataTransferObjectImpl instance) =>
    <String, dynamic>{
      'participants': instance.participants
          .map((e) => <String, dynamic>{
                r'$1': e.$1,
                r'$2': e.$2,
              })
          .toList(),
      'messages': instance.messages,
      'serverTimeStamp':
          const ServerTimestampConverter().toJson(instance.serverTimeStamp),
    };

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);
