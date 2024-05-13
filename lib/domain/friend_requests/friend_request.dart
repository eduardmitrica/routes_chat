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
  Option<ValueFailure<dynamic>> get failureOption {
    if (isEmpty()) {
      return none();
    }

    final duplicateFriendRequestByIds = find((friendRequest) {
      final duplicateFriendRequest = find(((correspondingFriendRequest) =>
          (friendRequest.senderId.getOrCrash() ==
                  correspondingFriendRequest.receiverId.getOrCrash() &&
              friendRequest.receiverId.getOrCrash() ==
                  correspondingFriendRequest.senderId.getOrCrash()) &&
          (friendRequest.senderId.getOrCrash() !=
                  correspondingFriendRequest.senderId.getOrCrash() &&
              friendRequest.receiverId.getOrCrash() !=
                  correspondingFriendRequest.receiverId.getOrCrash())));
      if (duplicateFriendRequest != null) {
        return true;
      } else {
        return false;
      }
    });

    if (duplicateFriendRequestByIds != null) {
      return some(
          const UnacceptedCase(failedValue: 'Duplicated friend request'));
    }

    final duplicateFriendRequestByStatus = find((friendRequest) {
      final duplicateFriendRequest = find((correspondingFriendRequest) =>
          (friendRequest.senderId.getOrCrash() ==
                  correspondingFriendRequest.senderId.getOrCrash() &&
              friendRequest.receiverId.getOrCrash() ==
                  correspondingFriendRequest.receiverId.getOrCrash()) &&
          ((friendRequest.status.getOrCrash().runtimeType ==
                      Pending().runtimeType &&
                  correspondingFriendRequest.status.getOrCrash().runtimeType ==
                      Accepted().runtimeType) ||
              (friendRequest.status.getOrCrash().runtimeType ==
                      Accepted().runtimeType &&
                  correspondingFriendRequest.status.getOrCrash().runtimeType ==
                      Pending().runtimeType)));
      if (duplicateFriendRequest != null) {
        return true;
      } else {
        return false;
      }
    });

    if (duplicateFriendRequestByStatus != null) {
      return some(
          const UnacceptedCase(failedValue: 'Duplicated friend request'));
    }

    return none();
  }
}
