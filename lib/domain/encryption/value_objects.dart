import 'package:dartz/dartz.dart';

import '../core/failures.dart';
import '../core/value_objects.dart';
import '../core/value_validators.dart';

/// The secret a user types to unlock their encryption keys.
///
/// It is not the login password: email and Google users alike choose one. It
/// never leaves the device, and only a key derived from it (with Argon2id) is
/// ever used.
class Passphrase extends ValueObject<String> {
  static const minimumLength = 12;
  static const maximumLength = 512;

  @override
  final Either<ValueFailure<String>, String> value;

  factory Passphrase(String input) => Passphrase._(
    validatePassphrase(
      input,
      minimumLength: minimumLength,
      maximumLength: maximumLength,
    ),
  );

  const Passphrase._(this.value);

  /// Deliberately does not reveal the passphrase.
  @override
  String toString() => 'Passphrase(…)';
}

/// A recovery key as typed by the user, normalized to its 32 characters.
///
/// Whether it is the right key is only known when it unlocks the keys.
class RecoveryKeyInput extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory RecoveryKeyInput(String input) =>
      RecoveryKeyInput._(validateRecoveryKeyFormat(input));

  const RecoveryKeyInput._(this.value);

  /// Deliberately does not reveal the key.
  @override
  String toString() => 'RecoveryKeyInput(…)';
}
