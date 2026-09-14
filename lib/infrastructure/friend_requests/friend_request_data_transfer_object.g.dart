// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request_data_transfer_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FriendRequestDataTransferObject _$FriendRequestDataTransferObjectFromJson(
  Map<String, dynamic> json,
) => _FriendRequestDataTransferObject(
  senderId: json['senderId'] as String,
  receiverId: json['receiverId'] as String,
  participantIds: (json['participantIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  serverTimeStamp: const ServerTimestampConverter().fromJson(
    json['serverTimeStamp'],
  ),
);

Map<String, dynamic> _$FriendRequestDataTransferObjectToJson(
  _FriendRequestDataTransferObject instance,
) => <String, dynamic>{
  'senderId': instance.senderId,
  'receiverId': instance.receiverId,
  'participantIds': instance.participantIds,
  'status': instance.status,
  'serverTimeStamp': const ServerTimestampConverter().toJson(
    instance.serverTimeStamp,
  ),
};
