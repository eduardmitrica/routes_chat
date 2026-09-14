part of 'encryption_bloc.dart';

sealed class EncryptionEvent extends Equatable {
  const EncryptionEvent();

  const factory EncryptionEvent.statusRequested() = EncryptionStatusRequested;
  const factory EncryptionEvent.setUpRequested(Passphrase passphrase) =
      EncryptionSetUpRequested;
  const factory EncryptionEvent.recoveryKeyConfirmed(String typedGroup) =
      EncryptionRecoveryKeyConfirmed;
  const factory EncryptionEvent.unlockRequested(Passphrase passphrase) =
      EncryptionUnlockRequested;
  const factory EncryptionEvent.forgotPassphraseChosen() =
      EncryptionForgotPassphraseChosen;
  const factory EncryptionEvent.passphraseRemembered() =
      EncryptionPassphraseRemembered;
  const factory EncryptionEvent.recoveryKeyEntered(
    RecoveryKeyInput recoveryKey,
  ) = EncryptionRecoveryKeyEntered;
  const factory EncryptionEvent.newPassphraseChosen(Passphrase passphrase) =
      EncryptionNewPassphraseChosen;
  const factory EncryptionEvent.resetChosen() = EncryptionResetChosen;
  const factory EncryptionEvent.resetCancelled() = EncryptionResetCancelled;
  const factory EncryptionEvent.resetConfirmed() = EncryptionResetConfirmed;
  const factory EncryptionEvent.resetPassphraseChosen(Passphrase passphrase) =
      EncryptionResetPassphraseChosen;
  const factory EncryptionEvent.resetSignInWithPassword(Password password) =
      EncryptionResetSignInWithPassword;
  const factory EncryptionEvent.resetSignInWithGoogle() =
      EncryptionResetSignInWithGoogle;

  @override
  List<Object?> get props => const [];
}

/// Check whether encryption is set up and unlocked on this device.
final class EncryptionStatusRequested extends EncryptionEvent {
  const EncryptionStatusRequested();
}

/// Create the user's keys, protected by [passphrase].
final class EncryptionSetUpRequested extends EncryptionEvent {
  final Passphrase passphrase;
  const EncryptionSetUpRequested(this.passphrase);
  @override
  List<Object?> get props => [passphrase];
}

/// The user typed back the requested group of the recovery key they were shown.
final class EncryptionRecoveryKeyConfirmed extends EncryptionEvent {
  final String typedGroup;
  const EncryptionRecoveryKeyConfirmed(this.typedGroup);
  @override
  List<Object?> get props => [typedGroup];
}

/// Unlock this device with the passphrase.
final class EncryptionUnlockRequested extends EncryptionEvent {
  final Passphrase passphrase;
  const EncryptionUnlockRequested(this.passphrase);
  @override
  List<Object?> get props => [passphrase];
}

/// The user forgot the passphrase and will use the recovery key.
final class EncryptionForgotPassphraseChosen extends EncryptionEvent {
  const EncryptionForgotPassphraseChosen();
}

/// Back from the recovery key screen to the passphrase.
final class EncryptionPassphraseRemembered extends EncryptionEvent {
  const EncryptionPassphraseRemembered();
}

/// Unlock this device with the recovery key.
final class EncryptionRecoveryKeyEntered extends EncryptionEvent {
  final RecoveryKeyInput recoveryKey;
  const EncryptionRecoveryKeyEntered(this.recoveryKey);
  @override
  List<Object?> get props => [recoveryKey];
}

/// After recovering, protect the keys with a new passphrase.
final class EncryptionNewPassphraseChosen extends EncryptionEvent {
  final Passphrase passphrase;
  const EncryptionNewPassphraseChosen(this.passphrase);
  @override
  List<Object?> get props => [passphrase];
}

/// The user lost the recovery key as well, and wants to know about resetting.
final class EncryptionResetChosen extends EncryptionEvent {
  const EncryptionResetChosen();
}

/// Back out of resetting, to the recovery key.
final class EncryptionResetCancelled extends EncryptionEvent {
  const EncryptionResetCancelled();
}

/// The user understood that a reset makes earlier messages unreadable.
final class EncryptionResetConfirmed extends EncryptionEvent {
  const EncryptionResetConfirmed();
}

/// The passphrase that will protect the new keys.
final class EncryptionResetPassphraseChosen extends EncryptionEvent {
  final Passphrase passphrase;
  const EncryptionResetPassphraseChosen(this.passphrase);
  @override
  List<Object?> get props => [passphrase];
}

/// Confirm the sign-in with the account [password], then reset the keys.
final class EncryptionResetSignInWithPassword extends EncryptionEvent {
  final Password password;
  const EncryptionResetSignInWithPassword(this.password);
  @override
  List<Object?> get props => [password];

  @override
  String toString() => 'EncryptionResetSignInWithPassword(password hidden)';
}

/// Confirm the sign-in with Google, then reset the keys.
final class EncryptionResetSignInWithGoogle extends EncryptionEvent {
  const EncryptionResetSignInWithGoogle();
}
