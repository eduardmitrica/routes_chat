import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/encryption/encryption_failure.dart';
import '../../domain/encryption/encryption_repository_interface.dart';
import '../../domain/encryption/encryption_status.dart';
import '../../domain/encryption/value_objects.dart';

part 'encryption_event.dart';

part 'encryption_state.dart';

/// Guides the signed-in user through setting up or unlocking end-to-end
/// encryption on this device, before they reach their chats.
class EncryptionBloc extends Bloc<EncryptionEvent, EncryptionState> {
  static const _recoveryKeyGroups = 8;

  final IEncryptionRepository _encryption;
  final Random _random;

  /// [random] picks which group of the recovery key the user types back; tests
  /// pass a seeded one.
  EncryptionBloc(this._encryption, {Random? random})
    : _random = random ?? Random.secure(),
      super(EncryptionState.initial()) {
    on<EncryptionEvent>((event, emit) async {
      // A second tap while keys are being derived would repeat seconds of
      // Argon2id work. The first handler marks the state as working before it
      // awaits anything, so later events see it.
      if (state.isWorking && event is! EncryptionStatusRequested) return;

      switch (event) {
        case EncryptionStatusRequested():
          emit(EncryptionState.initial().copyWith(isWorking: true));
          final result = await _encryption.status();
          emit(
            result.fold(
              (failure) => EncryptionState.initial().copyWith(
                phase: EncryptionPhase.unavailable,
                failureOption: some(failure),
              ),
              (status) => EncryptionState.initial().copyWith(
                phase: switch (status) {
                  EncryptionNotSetUp() => EncryptionPhase.needsSetUp,
                  EncryptionLocked() => EncryptionPhase.needsUnlock,
                  EncryptionUnlocked() => EncryptionPhase.ready,
                },
              ),
            ),
          );

        case EncryptionSetUpRequested(:final passphrase):
          emit(_working());
          final result = await _encryption.setUp(passphrase);
          emit(
            result.fold(
              (failure) => state.copyWith(
                // Keys created on another device meanwhile: unlock instead.
                phase: failure is EncryptionAlreadySetUp
                    ? EncryptionPhase.needsUnlock
                    : state.phase,
                isWorking: false,
                failureOption: some(failure),
              ),
              _showRecoveryKey,
            ),
          );

        case EncryptionRecoveryKeyConfirmed(:final typedGroup):
          final shown = state.recoveryKeyToShow.toNullable();
          if (shown == null) return;
          final expected = shown.split('-')[state.confirmationGroup];
          final typed = typedGroup.trim().toUpperCase();
          emit(
            typed == expected
                ? state.copyWith(
                    phase: EncryptionPhase.ready,
                    recoveryKeyToShow: none(),
                    failureOption: none(),
                  )
                : state.copyWith(
                    failureOption: some(const RecoveryKeyNotConfirmed()),
                  ),
          );

        case EncryptionUnlockRequested(:final passphrase):
          emit(_working());
          final result = await _encryption.unlockWithPassphrase(passphrase);
          emit(
            result.fold(
              (failure) => state.copyWith(
                isWorking: false,
                failureOption: some(failure),
              ),
              (_) => state.copyWith(
                phase: EncryptionPhase.ready,
                isWorking: false,
              ),
            ),
          );

        case EncryptionForgotPassphraseChosen():
          emit(
            state.copyWith(
              phase: EncryptionPhase.needsRecoveryKey,
              failureOption: none(),
            ),
          );

        case EncryptionPassphraseRemembered():
          emit(
            state.copyWith(
              phase: EncryptionPhase.needsUnlock,
              failureOption: none(),
            ),
          );

        case EncryptionRecoveryKeyEntered(:final recoveryKey):
          emit(_working());
          final result = await _encryption.unlockWithRecoveryKey(recoveryKey);
          emit(
            result.fold(
              (failure) => state.copyWith(
                isWorking: false,
                failureOption: some(failure),
              ),
              // The used recovery key must be replaced, which needs a new
              // passphrase.
              (_) => state.copyWith(
                phase: EncryptionPhase.needsNewPassphrase,
                isWorking: false,
              ),
            ),
          );

        case EncryptionNewPassphraseChosen(:final passphrase):
          emit(_working());
          final result = await _encryption.changePassphrase(passphrase);
          emit(
            result.fold(
              (failure) => state.copyWith(
                isWorking: false,
                failureOption: some(failure),
              ),
              _showRecoveryKey,
            ),
          );
      }
    });
  }

  EncryptionState _working() =>
      state.copyWith(isWorking: true, failureOption: none());

  EncryptionState _showRecoveryKey(String formatted) => state.copyWith(
    phase: EncryptionPhase.showRecoveryKey,
    isWorking: false,
    failureOption: none(),
    recoveryKeyToShow: some(formatted),
    confirmationGroup: _random.nextInt(_recoveryKeyGroups),
  );
}
