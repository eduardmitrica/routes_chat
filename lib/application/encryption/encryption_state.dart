part of 'encryption_bloc.dart';

/// Which screen of the encryption flow the user should see.
enum EncryptionPhase {
  /// Loading the user's keys.
  checking,

  /// No keys yet: choose a passphrase.
  needsSetUp,

  /// Keys created or re-protected: show the recovery key once, and have the
  /// user type part of it back.
  showRecoveryKey,

  /// Keys exist but this device is locked: enter the passphrase.
  needsUnlock,

  /// Forgot the passphrase: enter the recovery key.
  needsRecoveryKey,

  /// Unlocked with the recovery key: choose a new passphrase.
  needsNewPassphrase,

  /// Lost the recovery key too: explain what resetting the keys means.
  confirmingReset,

  /// Resetting: choose a passphrase for the new keys.
  needsResetPassphrase,

  /// Resetting: sign in again, to confirm it is the account holder.
  needsResetSignIn,

  /// This device can read and send encrypted chats.
  ready,

  /// The keys could not be loaded (for example, offline). The user can retry.
  unavailable,
}

/// Written by hand rather than with freezed so that [toString] can never print
/// the recovery key.
final class EncryptionState extends Equatable {
  final EncryptionPhase phase;
  final bool isWorking;
  final Option<EncryptionFailure> failureOption;

  /// The recovery key to show once, formatted. Cleared as soon as the user
  /// confirms it.
  final Option<String> recoveryKeyToShow;

  /// Which group of the recovery key (0 to 7) the user must type back.
  final int confirmationGroup;

  /// How the user confirms their sign-in before a reset.
  final SignInMethod resetSignInMethod;

  /// How many times the user typed back a group that did not match. Each
  /// wrong group changes it, so the page can say so every time, not only the
  /// first: the failure itself is the same each time.
  final int rejectedConfirmations;

  const EncryptionState({
    required this.phase,
    required this.isWorking,
    required this.failureOption,
    required this.recoveryKeyToShow,
    required this.confirmationGroup,
    required this.resetSignInMethod,
    this.rejectedConfirmations = 0,
  });

  factory EncryptionState.initial() => EncryptionState(
    phase: EncryptionPhase.checking,
    isWorking: false,
    failureOption: none(),
    recoveryKeyToShow: none(),
    confirmationGroup: 0,
    resetSignInMethod: SignInMethod.emailAndPassword,
  );

  EncryptionState copyWith({
    EncryptionPhase? phase,
    bool? isWorking,
    Option<EncryptionFailure>? failureOption,
    Option<String>? recoveryKeyToShow,
    int? confirmationGroup,
    SignInMethod? resetSignInMethod,
    int? rejectedConfirmations,
  }) => EncryptionState(
    phase: phase ?? this.phase,
    isWorking: isWorking ?? this.isWorking,
    failureOption: failureOption ?? this.failureOption,
    recoveryKeyToShow: recoveryKeyToShow ?? this.recoveryKeyToShow,
    confirmationGroup: confirmationGroup ?? this.confirmationGroup,
    resetSignInMethod: resetSignInMethod ?? this.resetSignInMethod,
    rejectedConfirmations: rejectedConfirmations ?? this.rejectedConfirmations,
  );

  @override
  List<Object?> get props => [
    phase,
    isWorking,
    failureOption,
    recoveryKeyToShow,
    confirmationGroup,
    resetSignInMethod,
    rejectedConfirmations,
  ];

  @override
  String toString() =>
      'EncryptionState(phase: ${phase.name}, isWorking: $isWorking, '
      'failure: $failureOption, recoveryKeyShown: '
      '${recoveryKeyToShow.isSome()}, confirmationGroup: $confirmationGroup, '
      'resetSignInMethod: ${resetSignInMethod.name}, '
      'rejectedConfirmations: $rejectedConfirmations)';
}
