import 'package:dartz/dartz.dart';

import 'encryption_failure.dart';
import 'encryption_status.dart';
import 'value_objects.dart';

/// The signed-in user's end-to-end encryption keys. See docs/e2ee.md.
///
/// Implementations act for the user in the current session.
abstract interface class IEncryptionRepository {
  /// Whether encryption is set up, and whether this device holds the keys.
  Future<Either<EncryptionFailure, EncryptionStatus>> status();

  /// Creates the user's keys, stores them, and unlocks this device.
  ///
  /// Returns the recovery key, formatted for display. It is not stored
  /// anywhere, so it must be shown to the user now, once. Fails with
  /// [EncryptionAlreadySetUp] rather than replace existing keys.
  Future<Either<EncryptionFailure, String>> setUp(Passphrase passphrase);

  /// Unlocks this device. Fails with [WrongPassphrase] if it does not match.
  Future<Either<EncryptionFailure, Unit>> unlockWithPassphrase(
    Passphrase passphrase,
  );

  /// Unlocks this device with the recovery key, for a forgotten passphrase.
  ///
  /// The caller should then ask for a new passphrase with [changePassphrase],
  /// which also replaces the used recovery key. Fails with [WrongRecoveryKey]
  /// if it does not match.
  Future<Either<EncryptionFailure, Unit>> unlockWithRecoveryKey(
    RecoveryKeyInput recoveryKey,
  );

  /// Protects the keys with [newPassphrase] and a new recovery key, which is
  /// returned formatted for display, to show once.
  ///
  /// The old passphrase and recovery key stop working; every chat stays
  /// readable. Needs this device to be unlocked
  /// ([EncryptionKeysUnavailable] otherwise).
  Future<Either<EncryptionFailure, String>> changePassphrase(
    Passphrase newPassphrase,
  );

  /// Replaces lost keys with new ones protected by [newPassphrase], for a user
  /// who has neither the passphrase nor the recovery key. Returns the new
  /// recovery key, formatted for display, to show once.
  ///
  /// Messages from before the reset stay unreadable for the user; each chat
  /// gets a new key generation for later ones (see docs/e2ee.md). The user
  /// must have confirmed their sign-in in the last few minutes
  /// ([RecentSignInRequired] otherwise).
  Future<Either<EncryptionFailure, String>> resetKeys(Passphrase newPassphrase);

  /// Forgets the keys on this device, for sign-out. Never throws.
  Future<void> lock();
}
