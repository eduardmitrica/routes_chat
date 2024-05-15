import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../friend_requests/value_objects.dart';

sealed class ValueFailure<T> {
  final T failedValue;

  const ValueFailure(this.failedValue);
}

final class InvalidEmail extends ValueFailure<String> {
  InvalidEmail({required failedValue}) : super(failedValue);
}

final class InvalidPassword extends ValueFailure<String> {
  InvalidPassword({required failedValue}) : super(failedValue);
}

final class InvalidImageUrl extends ValueFailure<String> {
  InvalidImageUrl({required failedValue}) : super(failedValue);
}

final class MultipleLines extends ValueFailure<String> {
  MultipleLines({required failedValue}): super(failedValue);
}

final class ExceedingLength extends ValueFailure<String> {
  ExceedingLength({required failedValue, required maximumLength}): super(failedValue);
}

final class EmptyString extends ValueFailure<String> {
  EmptyString({required failedValue}): super(failedValue);
}

final class UsernameAlreadyExists extends ValueFailure<String> {
  UsernameAlreadyExists({required failedValue}): super(failedValue);
}

final class UsernameExistsMoreThanOnce extends ValueFailure<String> {
  UsernameExistsMoreThanOnce({required failedValue}): super(failedValue);
}

final class IncorrectStatus extends ValueFailure<FriendRequestStatus>{
  const IncorrectStatus({required failedValue}) : super(failedValue);
}

final class UnacceptedCase extends ValueFailure<String>{
  const UnacceptedCase({required failedValue}) : super(failedValue);
}

final class DuplicateIds extends ValueFailure<KtList<Tuple2<UniqueId, UniqueId>>> {
  const DuplicateIds({required failedValue}) : super(failedValue);
}