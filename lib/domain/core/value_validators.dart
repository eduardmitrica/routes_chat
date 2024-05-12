import 'package:dartz/dartz.dart';

import '../../injection.dart';
import '../shared/user/user_utils_interface.dart';
import 'failures.dart';

Either<ValueFailure<String>, String> validateEmailAddress(String input) {
  const emailRegex =
      r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
  if (RegExp(emailRegex).hasMatch(input)) {
    return Right(input);
  } else {
    return Left(
      InvalidEmail(failedValue: input),
    );
  }
}

Either<ValueFailure<String>, String> validatePassword(String input) {
  if (input.length >= 6) {
    return Right(input);
  } else {
    return Left(
      InvalidPassword(failedValue: input),
    );
  }
}

Either<ValueFailure<String>, String> validateImageUrl(String imageUrl) {
  const imageUrlRegex =
      r"""https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)""";
  if (RegExp(imageUrlRegex).hasMatch(imageUrl)) {
    return Right(imageUrl);
  } else {
    return Left(
      InvalidImageUrl(failedValue: imageUrl),
    );
  }
}

Either<ValueFailure<String>, String> validateSingleLine(String input) {
  if (!input.contains('\n')) {
    return Right(input);
  } else {
    return Left(
      MultipleLines(failedValue: input),
    );
  }
}

Either<ValueFailure<String>, String> validateMaximumStringLength(
    String input, int maximumLength) {
  if (input.length <= maximumLength) {
    return Right(input);
  } else {
    return Left(
      ExceedingLength(failedValue: input, maximumLength: maximumLength),
    );
  }
}

Either<ValueFailure<String>, String> validateStringNotEmpty(String input) {
  if (input.isNotEmpty) {
    return Right(input);
  } else {
    return Left(
      EmptyString(failedValue: input),
    );
  }
}

Future<Either<ValueFailure<String>, String>> validateUsernameDoesNotAlreadyExist(String input) async{
  final usernameAlreadyExists = await getIt<IUserUtils>().checkIfUsernameAlreadyExists(input);

  if (!usernameAlreadyExists) {
    return Right(input);
  }
  else {
    return Left(UsernameAlreadyExists(failedValue: input));
  }
}

Future<Either<ValueFailure<String>, String>> validateUsernameExistsOnlyOnce(String input) async {
  final usernameExistsMoreThanOnce = await getIt<IUserUtils>().checkIfUsernameExistsMoreThanOnce(input);

  if (!usernameExistsMoreThanOnce) {
  return Right(input);
  }
  else {
  return Left(UsernameExistsMoreThanOnce(failedValue: input));
  }
}
