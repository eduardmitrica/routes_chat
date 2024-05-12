import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import 'package:routes_chat/domain/friend_requests/friend_request.dart';

import 'failures.dart';

abstract class IFriendRequestsRepository {
  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
      watchPendingFromCurrentUser();

  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
      watchReceivedForCurrentUser();

  Stream<Either<FriendRequestFailure, KtList<FriendRequest>>>
      watchFriendsForCurrentUser();

  Future<Either<FriendRequestFailure, Unit>> create(
      FriendRequest friendRequest);

  Future<Either<FriendRequestFailure, Unit>> update(
      FriendRequest friendRequest);

  Future<Either<FriendRequestFailure, Unit>> delete(
      FriendRequest friendRequest);

  Future<Either<FriendRequestFailure, FriendRequest>>
      findBySenderAndReceiverIds(UniqueId senderId, UniqueId receiverId);
}
