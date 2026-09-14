import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../friend_requests/value_objects.dart';

sealed class ValueFailure<T> {
  final T failedValue;

  const ValueFailure(this.failedValue);
}

final class InvalidEmail extends ValueFailure<String> {
  InvalidEmail({required String failedValue}) : super(failedValue);
}

final class InvalidPassword extends ValueFailure<String> {
  InvalidPassword({required String failedValue}) : super(failedValue);
}

final class InvalidImageUrl extends ValueFailure<String> {
  InvalidImageUrl({required String failedValue}) : super(failedValue);
}

final class MultipleLines extends ValueFailure<String> {
  MultipleLines({required String failedValue}) : super(failedValue);
}

final class ExceedingLength extends ValueFailure<String> {
  ExceedingLength({required String failedValue, required int maximumLength})
    : super(failedValue);
}

final class EmptyString extends ValueFailure<String> {
  EmptyString({required String failedValue}) : super(failedValue);
}

final class UsernameAlreadyExists extends ValueFailure<String> {
  UsernameAlreadyExists({required String failedValue}) : super(failedValue);
}

/// The username cannot be a Firestore document id, which the
/// `usernames/{username}` uniqueness index requires: it contains `/`, is `.`
/// or `..`, or has the reserved `__name__` shape.
final class InvalidUsernameCharacters extends ValueFailure<String> {
  InvalidUsernameCharacters({required String failedValue}) : super(failedValue);
}

final class IncorrectStatus extends ValueFailure<FriendRequestStatus> {
  const IncorrectStatus({required FriendRequestStatus failedValue})
    : super(failedValue);
}

final class UnacceptedCase extends ValueFailure<String> {
  const UnacceptedCase({required String failedValue}) : super(failedValue);
}

final class DuplicateIds
    extends ValueFailure<KtList<Tuple2<UniqueId, UniqueId>>> {
  const DuplicateIds({required KtList<Tuple2<UniqueId, UniqueId>> failedValue})
    : super(failedValue);
}

/// A passphrase shorter than [minimumLength] characters. It protects the
/// user's encryption keys against offline guessing, so length matters.
final class PassphraseTooShort extends ValueFailure<String> {
  final int minimumLength;

  PassphraseTooShort({required String failedValue, required this.minimumLength})
    : super(failedValue);
}

/// Text that cannot be a recovery key: not 32 base32 characters once case,
/// spaces and dashes are ignored.
final class InvalidRecoveryKeyFormat extends ValueFailure<String> {
  InvalidRecoveryKeyFormat({required String failedValue}) : super(failedValue);
}
