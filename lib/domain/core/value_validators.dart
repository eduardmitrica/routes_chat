import 'package:dartz/dartz.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../shared/user/user_utils_interface.dart';
import 'failures.dart';

Either<ValueFailure<String>, String> validateEmailAddress(String input) {
  const emailRegex =
      r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
  if (RegExp(emailRegex).hasMatch(input)) {
    return Right(input);
  } else {
    return Left(InvalidEmail(failedValue: input));
  }
}

Either<ValueFailure<String>, String> validatePassword(String input) {
  if (input.length >= 6) {
    return Right(input);
  } else {
    return Left(InvalidPassword(failedValue: input));
  }
}

Either<ValueFailure<String>, String> validateImageUrl(String imageUrl) {
  const imageUrlRegex =
      r"""https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)""";
  if (RegExp(imageUrlRegex).hasMatch(imageUrl)) {
    return Right(imageUrl);
  } else {
    return Left(InvalidImageUrl(failedValue: imageUrl));
  }
}

Either<ValueFailure<String>, String> validateSingleLine(String input) {
  if (!input.contains('\n')) {
    return Right(input);
  } else {
    return Left(MultipleLines(failedValue: input));
  }
}

Either<ValueFailure<String>, String> validateMaximumStringLength(
  String input,
  int maximumLength,
) {
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
    return Left(EmptyString(failedValue: input));
  }
}

/// Usernames double as document ids in the `usernames/{username}` uniqueness
/// index, so they must satisfy Firestore's document id rules.
Either<ValueFailure<String>, String> validateUsernameIsDocumentIdSafe(
  String input,
) {
  final hasReservedShape = RegExp(r'^__.*__$').hasMatch(input);
  if (input.contains('/') ||
      input == '.' ||
      input == '..' ||
      hasReservedShape) {
    return Left(InvalidUsernameCharacters(failedValue: input));
  }
  return Right(input);
}

Future<Either<ValueFailure<String>, String>>
validateUsernameDoesNotAlreadyExist(IUserUtils userUtils, String input) async {
  final usernameAlreadyExists = await userUtils.checkIfUsernameAlreadyExists(
    input,
  );

  if (!usernameAlreadyExists) {
    return Right(input);
  } else {
    return Left(UsernameAlreadyExists(failedValue: input));
  }
}

Either<
  ValueFailure<KtList<Tuple2<UniqueId, UniqueId>>>,
  KtList<Tuple2<UniqueId, UniqueId>>
>
validateParticipantsList(KtList<Tuple2<UniqueId, UniqueId>> ids) {
  final userIds = ids.map((id) => id.value1);
  final duplicateIds = userIds.toMutableList()
    ..removeAll(userIds.toSet().toList());
  if (duplicateIds.isEmpty()) {
    return Right(ids);
  } else {
    return Left(DuplicateIds(failedValue: ids));
  }
}

/// A passphrase must be at least [minimumLength] and at most [maximumLength]
/// characters. Spaces count and nothing is trimmed: a passphrase is exactly what
/// the user typed.
Either<ValueFailure<String>, String> validatePassphrase(
  String input, {
  required int minimumLength,
  required int maximumLength,
}) {
  final length = input.runes.length;
  if (length < minimumLength) {
    return Left(
      PassphraseTooShort(failedValue: input, minimumLength: minimumLength),
    );
  }
  if (length > maximumLength) {
    return Left(
      ExceedingLength(failedValue: input, maximumLength: maximumLength),
    );
  }
  return Right(input);
}

/// A recovery key is 32 base32 characters (A-Z, 2-7). Case, spaces and dashes
/// are ignored; the valid value is the normalized form.
Either<ValueFailure<String>, String> validateRecoveryKeyFormat(String input) {
  final normalized = input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  if (RegExp(r'^[A-Z2-7]{32}$').hasMatch(normalized)) {
    return Right(normalized);
  }
  return Left(InvalidRecoveryKeyFormat(failedValue: input));
}
