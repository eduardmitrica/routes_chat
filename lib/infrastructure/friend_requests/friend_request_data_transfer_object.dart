// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/friend_request.dart';

import '../../domain/friend_requests/value_objects.dart';

part 'friend_request_data_transfer_object.freezed.dart';

part 'friend_request_data_transfer_object.g.dart';

@freezed
abstract class FriendRequestDataTransferObject
    implements _$FriendRequestDataTransferObject {
  const FriendRequestDataTransferObject._();

  const factory FriendRequestDataTransferObject(
          {@JsonKey(includeToJson: false, includeFromJson: false) String? id,
          required String senderId,
          required String receiverId,
          required String status,
          @ServerTimestampConverter() required FieldValue serverTimeStamp}) =
      _FriendRequestDataTransferObject;

  factory FriendRequestDataTransferObject.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestDataTransferObjectFromJson(json);

  FriendRequest toDomain() => FriendRequest(
        id: UniqueId.fromUniqueString(id!),
        senderId: UniqueId.fromUniqueString(senderId),
        receiverId: UniqueId.fromUniqueString(receiverId),
        status: Status.fromString(status),
      );

  factory FriendRequestDataTransferObject.fromDomain(
      FriendRequest friendRequest) {
    final fullStatusString = friendRequest.status.getOrCrash().toString();
    return FriendRequestDataTransferObject(
      id: friendRequest.id.getOrCrash(),
      senderId: friendRequest.senderId.getOrCrash(),
      receiverId: friendRequest.receiverId.getOrCrash(),
      status: fullStatusString.substring(
          fullStatusString.indexOf('\'') + 1, fullStatusString.length - 1),
      serverTimeStamp: FieldValue.serverTimestamp(),
    );
  }

  factory FriendRequestDataTransferObject.fromFirestore(
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot) =>
      FriendRequestDataTransferObject.fromJson(documentSnapshot.data()!)
          .copyWith(id: documentSnapshot.id);
}

// from Json, to Json
class ServerTimestampConverter implements JsonConverter<FieldValue, Object?> {
  // For annotation it has to be constant
  const ServerTimestampConverter();

  @override
  FieldValue fromJson(Object? json) {
    return FieldValue.serverTimestamp();
  }

  @override
  Object toJson(FieldValue fieldValue) => fieldValue;
}
