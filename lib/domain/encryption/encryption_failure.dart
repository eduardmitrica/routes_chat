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

/// Resetting the keys needs a sign-in from the last few minutes, and there was
/// none. The user has to confirm their sign-in again.
final class RecentSignInRequired extends EncryptionFailure {
  const RecentSignInRequired();
}

/// The account password entered to confirm a key reset is wrong.
final class WrongAccountPassword extends EncryptionFailure {
  const WrongAccountPassword();
}

/// The user cancelled signing in again to confirm a key reset.
final class ConfirmationSignInCancelled extends EncryptionFailure {
  const ConfirmationSignInCancelled();
}

/// Signing in again to confirm a key reset failed, for example with another
/// Google account than the signed-in one.
final class ConfirmationSignInFailed extends EncryptionFailure {
  const ConfirmationSignInFailed();
}
