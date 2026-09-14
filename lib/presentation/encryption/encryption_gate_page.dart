import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/application/encryption/encryption_bloc.dart';
import 'package:routes_chat/domain/encryption/encryption_failure.dart';
import 'package:routes_chat/presentation/home/home_page.dart';
import 'package:routes_chat/presentation/sign_in/sign_in_page.dart';

import '../../injection.dart';
import 'widgets/passphrase_form.dart';
import 'widgets/recovery_key_confirmation.dart';
import 'widgets/recovery_key_form.dart';
import 'widgets/reset_explanation.dart';
import 'widgets/reset_sign_in.dart';

/// The step between signing in and the chats: sets up or unlocks end-to-end
/// encryption on this device. See docs/e2ee.md.
class EncryptionGatePage extends StatelessWidget {
  static const encryptionGatePageRoute = '/encryption';

  const EncryptionGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<EncryptionBloc>()..add(const EncryptionEvent.statusRequested()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.of(
                  context,
                ).pushReplacementNamed(SignInPage.signInPageRoute);
              }
            },
          ),
          BlocListener<EncryptionBloc, EncryptionState>(
            listenWhen: (previous, current) =>
                previous.phase != current.phase ||
                previous.failureOption != current.failureOption,
            listener: (context, state) {
              if (state.phase == EncryptionPhase.ready) {
                Navigator.of(
                  context,
                ).pushReplacementNamed(HomePage.homePageRoute);
                return;
              }
              state.failureOption.fold(() {}, (failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(_failureMessage(failure))),
                  );
              });
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Encryption'),
            actions: [
              // Someone who cannot unlock must still be able to leave.
              TextButton(
                onPressed: () => BlocProvider.of<AuthenticationBloc>(
                  context,
                ).add(const AuthenticationEvent.signedOut()),
                child: const Text('Sign out'),
              ),
            ],
          ),
          body: BlocBuilder<EncryptionBloc, EncryptionState>(
            builder: (context, state) {
              final bloc = BlocProvider.of<EncryptionBloc>(context);
              return switch (state.phase) {
                EncryptionPhase.checking || EncryptionPhase.ready =>
                  const Center(child: CircularProgressIndicator()),
                EncryptionPhase.needsSetUp => PassphraseForm(
                  key: const ValueKey('set-up'),
                  title: 'Protect your messages',
                  explanation:
                      'Your messages are encrypted on this phone before they '
                      'are sent. Choose a passphrase to protect your keys. It '
                      'is not your login password, and it never leaves this '
                      'device. You will need it on any new phone.',
                  buttonLabel: 'Create my keys',
                  askForConfirmation: true,
                  isWorking: state.isWorking,
                  workingMessage:
                      'Creating your keys. This takes a few seconds.',
                  onSubmitted: (passphrase) =>
                      bloc.add(EncryptionEvent.setUpRequested(passphrase)),
                ),
                EncryptionPhase.showRecoveryKey => RecoveryKeyConfirmation(
                  key: ValueKey(state.recoveryKeyToShow),
                  recoveryKey: state.recoveryKeyToShow.getOrElse(() => ''),
                  groupNumber: state.confirmationGroup + 1,
                  onConfirmed: (typedGroup) => bloc.add(
                    EncryptionEvent.recoveryKeyConfirmed(typedGroup),
                  ),
                ),
                EncryptionPhase.needsUnlock => PassphraseForm(
                  key: const ValueKey('unlock'),
                  title: 'Unlock your messages',
                  explanation:
                      'Enter your encryption passphrase to read and send '
                      'messages on this device.',
                  buttonLabel: 'Unlock',
                  askForConfirmation: false,
                  isWorking: state.isWorking,
                  workingMessage: 'Unlocking. This takes a few seconds.',
                  onSubmitted: (passphrase) =>
                      bloc.add(EncryptionEvent.unlockRequested(passphrase)),
                  secondaryActionLabel: 'Forgot your passphrase?',
                  onSecondaryAction: () =>
                      bloc.add(const EncryptionEvent.forgotPassphraseChosen()),
                ),
                EncryptionPhase.needsRecoveryKey => RecoveryKeyForm(
                  isWorking: state.isWorking,
                  onSubmitted: (recoveryKey) =>
                      bloc.add(EncryptionEvent.recoveryKeyEntered(recoveryKey)),
                  onBack: () =>
                      bloc.add(const EncryptionEvent.passphraseRemembered()),
                  onLostRecoveryKey: () =>
                      bloc.add(const EncryptionEvent.resetChosen()),
                ),
                EncryptionPhase.needsNewPassphrase => PassphraseForm(
                  key: const ValueKey('new-passphrase'),
                  title: 'Choose a new passphrase',
                  explanation:
                      'Your recovery key worked. Choose a new passphrase. You '
                      'will then get a new recovery key, and the old one will '
                      'stop working.',
                  buttonLabel: 'Save new passphrase',
                  askForConfirmation: true,
                  isWorking: state.isWorking,
                  workingMessage:
                      'Protecting your keys. This takes a few seconds.',
                  onSubmitted: (passphrase) =>
                      bloc.add(EncryptionEvent.newPassphraseChosen(passphrase)),
                ),
                EncryptionPhase.confirmingReset => ResetExplanation(
                  onConfirmed: () =>
                      bloc.add(const EncryptionEvent.resetConfirmed()),
                  onBack: () =>
                      bloc.add(const EncryptionEvent.resetCancelled()),
                ),
                EncryptionPhase.needsResetPassphrase => PassphraseForm(
                  key: const ValueKey('reset-passphrase'),
                  title: 'Choose a passphrase for your new keys',
                  explanation:
                      'It protects the keys that replace your lost ones. '
                      'Choose one you will remember: the new recovery key is '
                      'the only other way back.',
                  buttonLabel: 'Continue',
                  askForConfirmation: true,
                  isWorking: state.isWorking,
                  workingMessage: '',
                  onSubmitted: (passphrase) => bloc.add(
                    EncryptionEvent.resetPassphraseChosen(passphrase),
                  ),
                  secondaryActionLabel: 'Cancel reset',
                  onSecondaryAction: () =>
                      bloc.add(const EncryptionEvent.resetCancelled()),
                ),
                EncryptionPhase.needsResetSignIn => ResetSignIn(
                  method: state.resetSignInMethod,
                  isWorking: state.isWorking,
                  onPassword: (password) => bloc.add(
                    EncryptionEvent.resetSignInWithPassword(password),
                  ),
                  onGoogle: () =>
                      bloc.add(const EncryptionEvent.resetSignInWithGoogle()),
                  onCancel: () =>
                      bloc.add(const EncryptionEvent.resetCancelled()),
                ),
                EncryptionPhase.unavailable => _Unavailable(
                  onRetry: () =>
                      bloc.add(const EncryptionEvent.statusRequested()),
                ),
              };
            },
          ),
        ),
      ),
    );
  }

  static String _failureMessage(EncryptionFailure failure) => switch (failure) {
    WrongPassphrase() => 'That passphrase is not right.',
    WrongRecoveryKey() => 'That recovery key is not right.',
    EncryptionAlreadySetUp() =>
      'Encryption is already set up for this account. Unlock it with your '
          'passphrase.',
    EncryptionKeysUnavailable() =>
      'Your keys are not available on this device. Unlock again.',
    RecoveryKeyNotConfirmed() =>
      'That does not match. Check the recovery key you saved.',
    EncryptionServerError() =>
      'Could not reach your keys. Check your connection and try again.',
    RecentSignInRequired() =>
      'Your sign-in could not be confirmed in time. Confirm it again.',
    WrongAccountPassword() => 'That is not your account password.',
    ConfirmationSignInCancelled() =>
      'Sign-in was cancelled, so your keys were not reset.',
    ConfirmationSignInFailed() =>
      'Could not confirm your sign-in. Use the account you are signed in '
          'with.',
  };
}

class _Unavailable extends StatelessWidget {
  final VoidCallback onRetry;

  const _Unavailable({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your encryption keys could not be loaded.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
