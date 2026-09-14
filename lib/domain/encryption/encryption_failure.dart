/// Why an end-to-end encryption operation did not go through.
sealed class EncryptionFailure {
  const EncryptionFailure();
}

/// The passphrase does not unlock the user's keys.
final class WrongPassphrase extends EncryptionFailure {
  const WrongPassphrase();
}

/// The recovery key does not unlock the user's keys.
final class WrongRecoveryKey extends EncryptionFailure {
  const WrongRecoveryKey();
}

/// Setup was attempted for a user whose keys already exist. Replacing them
/// would make every earlier message unreadable, so it is refused.
final class EncryptionAlreadySetUp extends EncryptionFailure {
  const EncryptionAlreadySetUp();
}

/// An operation that needs the user's keys found none: encryption is not set
/// up, or this device has not been unlocked.
final class EncryptionKeysUnavailable extends EncryptionFailure {
  const EncryptionKeysUnavailable();
}

/// The user typed back the wrong part of the recovery key they were shown, so
/// they have probably not saved it.
final class RecoveryKeyNotConfirmed extends EncryptionFailure {
  const RecoveryKeyNotConfirmed();
}

/// The stored keys could not be read or written, or are in an unexpected
/// state.
final class EncryptionServerError extends EncryptionFailure {
  const EncryptionServerError();
}
