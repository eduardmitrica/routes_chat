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
