// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request_data_transfer_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendRequestDataTransferObjectImpl
    _$$FriendRequestDataTransferObjectImplFromJson(Map<String, dynamic> json) =>
        _$FriendRequestDataTransferObjectImpl(
          senderId: json['senderId'] as String,
          receiverId: json['receiverId'] as String,
          status: json['status'] as String,
          serverTimeStamp: const ServerTimestampConverter()
              .fromJson(json['serverTimeStamp'] as Object),
        );

Map<String, dynamic> _$$FriendRequestDataTransferObjectImplToJson(
        _$FriendRequestDataTransferObjectImpl instance) =>
    <String, dynamic>{
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'status': instance.status,
      'serverTimeStamp':
          const ServerTimestampConverter().toJson(instance.serverTimeStamp),
    };
