// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../../domain/shared/user/user.dart';
import '../../../domain/shared/user/value_objects.dart';



part 'user_data_transfer_object.freezed.dart';

part 'user_data_transfer_object.g.dart';

@freezed
abstract class UserDataTransferObject implements _$UserDataTransferObject {
  const UserDataTransferObject._();

  const factory UserDataTransferObject({
    @JsonKey(includeToJson: false, includeFromJson: false) String? id,
    required String emailAddress,
    required String username,
    required String imageUrl,
    required String description,
  }) = _UserDataTransferObject;

  factory UserDataTransferObject.fromJson(Map<String, dynamic> json) =>
      _$UserDataTransferObjectFromJson(json);

  User toDomain() => User(
        id: UniqueId.fromUniqueString(id!),
        emailAddress: EmailAddress(emailAddress),
        imageUrl: ImageUrl(imageUrl),
        username: Username(username),
        description: Description(description),
      );

  factory UserDataTransferObject.fromDomain(User user) =>
      UserDataTransferObject(
          id: user.id.getOrCrash(),
          emailAddress: user.emailAddress.getOrCrash(),
          username: user.username.getOrCrash(),
          imageUrl: user.imageUrl.getOrCrash(),
          description: user.description.getOrCrash());

  factory UserDataTransferObject.fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot) =>
      UserDataTransferObject.fromJson(documentSnapshot.data()!)
          .copyWith(id: documentSnapshot.id);
}
