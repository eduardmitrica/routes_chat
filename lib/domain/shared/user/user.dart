import 'package:flutter/foundation.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';

part 'user.freezed.dart';

/// A user's public profile: what any signed-in user may see (username search
/// reads other users' profiles). The email address deliberately is not part
/// of it; it lives only in Firebase Auth.
@freezed
abstract class User with _$User {
  const factory User({
    required UniqueId id,
    required ImageUrl imageUrl,
    required Username username,
    required Description description,
  }) = _User;

  factory User.empty() => User(
    id: UniqueId(),
    imageUrl: ImageUrl(''),
    username: Username(''),
    description: Description(''),
  );
}
