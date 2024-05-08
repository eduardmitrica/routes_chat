import 'package:dartz/dartz.dart';

import '../core/failures.dart';
import 'value_objects.dart';

Map<String, FriendRequestStatus> statusMap = {
  'Pending': Pending(),
  'Accepted': Accepted(),
};

Either<ValueFailure<FriendRequestStatus>,
    FriendRequestStatus> checkIfStatusIsEitherPendingOrAccepted(String statusString)
{
  if (statusMap.keys.contains(statusString)) {
    return Right(statusMap[statusString]!);
  } else {
    return Left(IncorrectStatus(failedValue: Incorrect));
  }
}