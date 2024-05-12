import 'package:dartz/dartz.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/core/value_validators.dart';

import '../../core/failures.dart';

class EmailAddress extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory EmailAddress(String input) {
    return EmailAddress._(validateEmailAddress(input));
  }

  const EmailAddress._(this.value);
}

class Password extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory Password(String input) {
    return Password._(
      validatePassword(input),
    );
  }

  const Password._(this.value);
}

class ImagePath extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  bool comesFromUrl() => super.isValid()  && validateImageUrl(super.getOrCrash()).isRight();

  factory ImagePath(String input) {
    return ImagePath._(
      validateStringNotEmpty(input),
    );
  }

  factory ImagePath.fromUrl(String input) {
    return ImagePath._(
      validateImageUrl(input),
    );
  }

  const ImagePath._(this.value);

  factory ImagePath.fromJson(Map<String, dynamic> json) {
    return ImagePath._(validateImageUrl(json['imagePath']));
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': value.fold((_) => '', (value) => value),
    };
  }
}

class ImageUrl extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory ImageUrl(String input) {
    return ImageUrl._(
      validateImageUrl(input),
    );
  }

  const ImageUrl._(this.value);
}

class Description extends ValueObject<String> {
  static const _maximumLength = 30;

  @override
  final Either<ValueFailure<String>, String> value;

  factory Description(String input) {
    return Description._(validateMaximumStringLength(input, _maximumLength));
  }

  const Description._(this.value);
}

class Username extends ValueObject<String> {
  static const _maximumLength = 12;

  @override
  final Either<ValueFailure<String>, String> value;

  factory Username(String input) {
    return Username._(
      validateMaximumStringLength(input, _maximumLength)
          .flatMap(validateStringNotEmpty),
    );
  }

  static Future<Username> checkAgainstDatabase(String input) async {
    final validationResult = await validateUsernameDoesNotAlreadyExist(input);
    return Username._(validationResult);
  }

  static Future<Username> checkAgainstDatabaseWhenFetching(String input) async {
    final validationResult = await validateUsernameExistsOnlyOnce(input);
    return Username._(validationResult);
  }

  const Username._(this.value);
}
