// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data_transfer_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDataTransferObject _$UserDataTransferObjectFromJson(
  Map<String, dynamic> json,
) => _UserDataTransferObject(
  username: json['username'] as String,
  imageUrl: json['imageUrl'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$UserDataTransferObjectToJson(
  _UserDataTransferObject instance,
) => <String, dynamic>{
  'username': instance.username,
  'imageUrl': instance.imageUrl,
  'description': instance.description,
};
