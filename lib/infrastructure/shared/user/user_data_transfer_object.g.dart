// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data_transfer_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDataTransferObjectImpl _$$UserDataTransferObjectImplFromJson(
        Map<String, dynamic> json) =>
    _$UserDataTransferObjectImpl(
      emailAddress: json['emailAddress'] as String,
      username: json['username'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$$UserDataTransferObjectImplToJson(
        _$UserDataTransferObjectImpl instance) =>
    <String, dynamic>{
      'emailAddress': instance.emailAddress,
      'username': instance.username,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
    };
