import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/value_objects.dart';

import '../core/failures.dart';

part 'friend_request.freezed.dart';

@freezed
abstract class FriendRequest with _$FriendRequest {
  const FriendRequest._();

  const factory FriendRequest({
    required UniqueId id,
    required UniqueId senderId,
    required UniqueId receiverId,
    required Status status,
  }) = _FriendRequest;

  factory FriendRequest.empty() => FriendRequest(
      id: UniqueId(),
      senderId: UniqueId(),
      receiverId: UniqueId(),
      status: Status(Pending()));

  Option<ValueFailure<dynamic>> get failureOption => this
          .id
          .failureOrUnit
          .andThen(senderId.failureOrUnit)
          .andThen(receiverId.failureOrUnit)
          .andThen(status.failureOrUnit)
          .fold((failure) => some(failure), (_) {
        if (senderId.getOrCrash().toString() ==
            receiverId.getOrCrash().toString()) {
          return some(const UnacceptedCase(
              failedValue:
                  'A friend request can not have the same ids for sender and receiver'));
        } else {
          return none();
        }
      });
}

extension FriendRequestsX on KtList<FriendRequest> {
  Option<ValueFailure<dynamic>> get failureOption => none();
}
