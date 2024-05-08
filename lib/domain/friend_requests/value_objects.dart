import 'package:dartz/dartz.dart';
import 'package:routes_chat/domain/core/failures.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/friend_requests/value_validators.dart';

sealed class FriendRequestStatus {}

final class Pending extends FriendRequestStatus {}

final class Accepted extends FriendRequestStatus {}

final class Incorrect extends FriendRequestStatus {}

class Status extends ValueObject<FriendRequestStatus> {
  @override
  final Either<ValueFailure<FriendRequestStatus>, FriendRequestStatus> value;

  factory Status(FriendRequestStatus status) {
    return Status._(Right(status));
  }

  factory Status.fromString(String statusString) {
    return Status._(checkIfStatusIsEitherPendingOrAccepted(statusString));
  }

  const Status._(this.value);
}
