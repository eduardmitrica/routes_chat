import 'package:dartz/dartz.dart';
import 'package:routes_chat/domain/core/value_validators.dart';

import '../../core/failures.dart';
import '../../core/value_objects.dart';

class Content extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory Content(String input) {
    return Content._(validateMaximumStringLength(input, 1000));
  }

  const Content._(this.value);
}