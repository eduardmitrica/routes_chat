import 'package:flutter/foundation.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:routes_chat/domain/authentication/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required UniqueId id,
    required EmailAddress emailAddress,
    required ImageUrl imageUrl,
    required Username username,
    required Description description,
  }) = _User;

  factory User.empty() => User(
        id: UniqueId(),
        emailAddress: EmailAddress(''),
        imageUrl: ImageUrl(''),
        username: Username(''),
        description: Description(''),
      );
}
