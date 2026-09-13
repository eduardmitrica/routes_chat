import 'package:dartz/dartz.dart';

import '../core/failures.dart';
import 'value_objects.dart';

Map<String, FriendRequestStatus> statusMap = {
  'Pending': Pending(),
  'Accepted': Accepted(),
};

/// The stored name of [status]: the inverse of [statusMap].
///
/// Spelled out as literals on purpose. The name used to be parsed out of
/// `status.toString()` ("Instance of 'Pending'"), i.e. the class name, which
/// `flutter build --obfuscate` minifies: Firestore would then receive a
/// meaningless name, firestore.rules (which checks for 'Pending' and
/// 'Accepted') would reject every friend request write, and reading one back
/// would fail [checkIfStatusIsEitherPendingOrAccepted]. The switch is
/// exhaustive, so a new status cannot be added without choosing its name.
String statusName(FriendRequestStatus status) => switch (status) {
  Pending() => 'Pending',
  Accepted() => 'Accepted',
  Incorrect() => throw ArgumentError.value(
    status,
    'status',
    'An incorrect status has no stored name',
  ),
};

Either<ValueFailure<FriendRequestStatus>, FriendRequestStatus>
checkIfStatusIsEitherPendingOrAccepted(String statusString) {
  if (statusMap.keys.contains(statusString)) {
    return Right(statusMap[statusString]!);
  } else {
    return Left(IncorrectStatus(failedValue: Incorrect()));
  }
}
