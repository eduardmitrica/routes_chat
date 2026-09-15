import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/encryption/encryption_bloc.dart';
import 'package:routes_chat/domain/authentication/authentication_facade_interface.dart';
import 'package:routes_chat/domain/authentication/sign_in_failure.dart';
import 'package:routes_chat/domain/authentication/sign_in_method.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';
import 'package:routes_chat/domain/encryption/encryption_failure.dart';
import 'package:routes_chat/domain/encryption/encryption_repository_interface.dart';
import 'package:routes_chat/domain/encryption/encryption_status.dart';
import 'package:routes_chat/domain/encryption/value_objects.dart';

const _recoveryKey = 'ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ23-4567';
const _newRecoveryKey = 'QQQQ-RRRR-SSSS-TTTT-UUUU-VVVV-WWWW-XXXX';
const _passphrase = 'correct horse battery staple';

/// Answers like the real repository, with scripted results, and counts calls.
class _FakeEncryption implements IEncryptionRepository {
  Either<EncryptionFailure, EncryptionStatus> statusResult = const Right(
    EncryptionNotSetUp(),
  );
  Either<EncryptionFailure, String> setUpResult = const Right(_recoveryKey);
  Either<EncryptionFailure, String> changeResult = const Right(_newRecoveryKey);
  String correctPassphrase = _passphrase;
  String correctRecoveryKey = _recoveryKey.replaceAll('-', '');

  /// When set, setUp waits for it, to observe the bloc mid-operation.
  Completer<void>? setUpGate;
  var setUpCalls = 0;

  @override
  Future<Either<EncryptionFailure, EncryptionStatus>> status() async =>
      statusResult;

  @override
  Future<Either<EncryptionFailure, String>> setUp(Passphrase passphrase) async {
    setUpCalls++;
    await setUpGate?.future;
    return setUpResult;
  }

  @override
  Future<Either<EncryptionFailure, Unit>> unlockWithPassphrase(
    Passphrase passphrase,
  ) async => passphrase.getOrCrash() == correctPassphrase
      ? const Right(unit)
      : const Left(WrongPassphrase());

  @override
  Future<Either<EncryptionFailure, Unit>> unlockWithRecoveryKey(
    RecoveryKeyInput recoveryKey,
  ) async => recoveryKey.getOrCrash() == correctRecoveryKey
      ? const Right(unit)
      : const Left(WrongRecoveryKey());

  @override
  Future<Either<EncryptionFailure, String>> changePassphrase(
    Passphrase newPassphrase,
  ) async => changeResult;

  Either<EncryptionFailure, String> resetResult = const Right(_newRecoveryKey);

  /// The passphrase keys were last reset with, or null if they never were.
  Passphrase? resetWith;

  @override
  Future<Either<EncryptionFailure, String>> resetKeys(
    Passphrase newPassphrase,
  ) async {
    resetWith = newPassphrase;
    return resetResult;
  }

  @override
  Future<void> lock() async {}
}

/// Confirms a sign-in with scripted results.
class _FakeAuth implements IAuthFacade {
  SignInMethod? method = SignInMethod.emailAndPassword;
  String correctPassword = 'account password';
  SignInFailure? googleFailure;

  @override
  SignInMethod? currentSignInMethod() => method;

  @override
  Future<Either<SignInFailure, Unit>> confirmSignInWithPassword(
    Password password,
  ) async => password.getOrCrash() == correctPassword
      ? const Right(unit)
      : Left(InvalidEmailAndPasswordCombination());

  @override
  Future<Either<SignInFailure, Unit>> confirmSignInWithGoogle() async {
    final failure = googleFailure;
    return failure == null ? const Right(unit) : Left(failure);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeEncryption encryption;
  late _FakeAuth auth;
  late EncryptionBloc bloc;

  setUp(() {
    encryption = _FakeEncryption();
    auth = _FakeAuth();
    bloc = EncryptionBloc(encryption, auth, random: Random(1));
  });

  tearDown(() => bloc.close());

  Future<void> send(EncryptionEvent event) async {
    bloc.add(event);
    await pumpEventQueue();
  }

  String groupAskedFor() => bloc.state.recoveryKeyToShow.toNullable()!.split(
    '-',
  )[bloc.state.confirmationGroup];

  group('on start', () {
    test('a user without keys is asked to set up', () async {
      await send(const EncryptionEvent.statusRequested());

      expect(bloc.state.phase, EncryptionPhase.needsSetUp);
    });

    test('a user whose keys exist elsewhere is asked to unlock', () async {
      encryption.statusResult = const Right(EncryptionLocked());

      await send(const EncryptionEvent.statusRequested());

      expect(bloc.state.phase, EncryptionPhase.needsUnlock);
    });

    test('an unlocked device goes straight to the chats', () async {
      encryption.statusResult = const Right(EncryptionUnlocked());

      await send(const EncryptionEvent.statusRequested());

      expect(bloc.state.phase, EncryptionPhase.ready);
    });

    test('keys that cannot be loaded leave the user able to retry', () async {
      encryption.statusResult = const Left(EncryptionServerError());

      await send(const EncryptionEvent.statusRequested());

      expect(bloc.state.phase, EncryptionPhase.unavailable);
      expect(bloc.state.failureOption, some(const EncryptionServerError()));
    });
  });

  group('setting up', () {
    setUp(() => send(const EncryptionEvent.statusRequested()));

    test('shows the recovery key once and asks for one group of it', () async {
      await send(EncryptionEvent.setUpRequested(Passphrase(_passphrase)));

      expect(bloc.state.phase, EncryptionPhase.showRecoveryKey);
      expect(bloc.state.recoveryKeyToShow, some(_recoveryKey));
      expect(bloc.state.confirmationGroup, inInclusiveRange(0, 7));
    });

    test('refuses the wrong group, keeping the key on screen', () async {
      await send(EncryptionEvent.setUpRequested(Passphrase(_passphrase)));

      await send(const EncryptionEvent.recoveryKeyConfirmed('ZZZZ'));

      expect(bloc.state.phase, EncryptionPhase.showRecoveryKey);
      expect(bloc.state.failureOption, some(const RecoveryKeyNotConfirmed()));
      expect(bloc.state.recoveryKeyToShow, some(_recoveryKey));
    });

    // Regression: the failure is the same each time, so a second wrong group
    // left the state unchanged, and the page said nothing.
    test('every wrong group changes the state, so each is reported', () async {
      await send(EncryptionEvent.setUpRequested(Passphrase(_passphrase)));

      await send(const EncryptionEvent.recoveryKeyConfirmed('ZZZZ'));
      final afterFirst = bloc.state;
      await send(const EncryptionEvent.recoveryKeyConfirmed('ZZZZ'));

      expect(bloc.state.rejectedConfirmations, 2);
      expect(bloc.state, isNot(afterFirst));
    });

    test('finishes on the right group and forgets the key', () async {
      await send(EncryptionEvent.setUpRequested(Passphrase(_passphrase)));

      await send(
        EncryptionEvent.recoveryKeyConfirmed(
          ' ${groupAskedFor().toLowerCase()} ',
        ),
      );

      expect(bloc.state.phase, EncryptionPhase.ready);
      expect(bloc.state.recoveryKeyToShow, none());
      expect(bloc.state.failureOption, none());
    });

    test('sends a user whose keys appeared meanwhile to unlock', () async {
      encryption.setUpResult = const Left(EncryptionAlreadySetUp());

      await send(EncryptionEvent.setUpRequested(Passphrase(_passphrase)));

      expect(bloc.state.phase, EncryptionPhase.needsUnlock);
      expect(bloc.state.failureOption, some(const EncryptionAlreadySetUp()));
    });

    test('ignores a second tap while the keys are being created', () async {
      encryption.setUpGate = Completer<void>();

      bloc
        ..add(EncryptionEvent.setUpRequested(Passphrase(_passphrase)))
        ..add(EncryptionEvent.setUpRequested(Passphrase(_passphrase)));
      await pumpEventQueue();

      expect(bloc.state.isWorking, isTrue);
      encryption.setUpGate!.complete();
      await pumpEventQueue();

      expect(encryption.setUpCalls, 1);
      expect(bloc.state.phase, EncryptionPhase.showRecoveryKey);
    });

    test('never prints the recovery key', () async {
      await send(EncryptionEvent.setUpRequested(Passphrase(_passphrase)));

      expect(bloc.state.toString(), isNot(contains('ABCD')));
    });
  });

  group('unlocking', () {
    setUp(() async {
      encryption.statusResult = const Right(EncryptionLocked());
      await send(const EncryptionEvent.statusRequested());
    });

    test('a wrong passphrase keeps the user on the unlock screen', () async {
      await send(
        EncryptionEvent.unlockRequested(Passphrase('not the passphrase')),
      );

      expect(bloc.state.phase, EncryptionPhase.needsUnlock);
      expect(bloc.state.failureOption, some(const WrongPassphrase()));
      expect(bloc.state.isWorking, isFalse);
    });

    test('the right passphrase opens the chats', () async {
      await send(EncryptionEvent.unlockRequested(Passphrase(_passphrase)));

      expect(bloc.state.phase, EncryptionPhase.ready);
    });
  });

  group('recovering a forgotten passphrase', () {
    setUp(() async {
      encryption.statusResult = const Right(EncryptionLocked());
      await send(const EncryptionEvent.statusRequested());
      await send(const EncryptionEvent.forgotPassphraseChosen());
    });

    test('asks for the recovery key, and can go back', () async {
      expect(bloc.state.phase, EncryptionPhase.needsRecoveryKey);

      await send(const EncryptionEvent.passphraseRemembered());

      expect(bloc.state.phase, EncryptionPhase.needsUnlock);
    });

    test('a wrong recovery key is refused', () async {
      await send(
        EncryptionEvent.recoveryKeyEntered(RecoveryKeyInput(_newRecoveryKey)),
      );

      expect(bloc.state.phase, EncryptionPhase.needsRecoveryKey);
      expect(bloc.state.failureOption, some(const WrongRecoveryKey()));
    });

    test(
      'the right key leads to a new passphrase and a new recovery key',
      () async {
        await send(
          EncryptionEvent.recoveryKeyEntered(RecoveryKeyInput(_recoveryKey)),
        );
        expect(bloc.state.phase, EncryptionPhase.needsNewPassphrase);

        await send(
          EncryptionEvent.newPassphraseChosen(
            Passphrase('a new passphrase here'),
          ),
        );
        expect(bloc.state.phase, EncryptionPhase.showRecoveryKey);
        expect(bloc.state.recoveryKeyToShow, some(_newRecoveryKey));

        await send(EncryptionEvent.recoveryKeyConfirmed(groupAskedFor()));
        expect(bloc.state.phase, EncryptionPhase.ready);
        expect(bloc.state.recoveryKeyToShow, none());
      },
    );
  });

  group('resetting lost keys', () {
    setUp(() async {
      encryption.statusResult = const Right(EncryptionLocked());
      await send(const EncryptionEvent.statusRequested());
      await send(const EncryptionEvent.forgotPassphraseChosen());
      await send(const EncryptionEvent.resetChosen());
    });

    Future<void> chooseNewPassphrase() async {
      await send(const EncryptionEvent.resetConfirmed());
      await send(
        EncryptionEvent.resetPassphraseChosen(
          Passphrase('a brand new passphrase'),
        ),
      );
    }

    test('explains the reset first, and can go back', () async {
      expect(bloc.state.phase, EncryptionPhase.confirmingReset);

      await send(const EncryptionEvent.resetCancelled());

      expect(bloc.state.phase, EncryptionPhase.needsRecoveryKey);
    });

    test(
      'asks for a new passphrase, then a sign-in the way the user signs in',
      () async {
        auth.method = SignInMethod.google;

        await send(const EncryptionEvent.resetConfirmed());
        expect(bloc.state.phase, EncryptionPhase.needsResetPassphrase);

        await send(
          EncryptionEvent.resetPassphraseChosen(
            Passphrase('a brand new passphrase'),
          ),
        );
        expect(bloc.state.phase, EncryptionPhase.needsResetSignIn);
        expect(bloc.state.resetSignInMethod, SignInMethod.google);
        expect(
          encryption.resetWith,
          isNull,
          reason: 'nothing is reset before the sign-in is confirmed',
        );
      },
    );

    test('a wrong account password resets nothing', () async {
      await chooseNewPassphrase();

      await send(
        EncryptionEvent.resetSignInWithPassword(Password('not my password')),
      );

      expect(bloc.state.phase, EncryptionPhase.needsResetSignIn);
      expect(bloc.state.failureOption, some(const WrongAccountPassword()));
      expect(bloc.state.isWorking, isFalse);
      expect(encryption.resetWith, isNull);
    });

    test('a cancelled Google sign-in resets nothing', () async {
      auth
        ..method = SignInMethod.google
        ..googleFailure = CancelledByUser();
      await chooseNewPassphrase();

      await send(const EncryptionEvent.resetSignInWithGoogle());

      expect(
        bloc.state.failureOption,
        some(const ConfirmationSignInCancelled()),
      );
      expect(encryption.resetWith, isNull);
    });

    test(
      'once signed in, the keys are replaced and the new recovery key shown',
      () async {
        await chooseNewPassphrase();

        await send(
          EncryptionEvent.resetSignInWithPassword(Password('account password')),
        );

        expect(encryption.resetWith?.getOrCrash(), 'a brand new passphrase');
        expect(bloc.state.phase, EncryptionPhase.showRecoveryKey);
        expect(bloc.state.recoveryKeyToShow, some(_newRecoveryKey));

        await send(EncryptionEvent.recoveryKeyConfirmed(groupAskedFor()));
        expect(bloc.state.phase, EncryptionPhase.ready);
      },
    );

    test(
      'a reset refused for want of a recent sign-in can be retried',
      () async {
        encryption.resetResult = const Left(RecentSignInRequired());
        await chooseNewPassphrase();

        await send(
          EncryptionEvent.resetSignInWithPassword(Password('account password')),
        );

        expect(bloc.state.phase, EncryptionPhase.needsResetSignIn);
        expect(bloc.state.failureOption, some(const RecentSignInRequired()));
        expect(bloc.state.isWorking, isFalse);
      },
    );

    test('never prints the account password', () {
      expect(
        EncryptionEvent.resetSignInWithPassword(
          Password('account password'),
        ).toString(),
        isNot(contains('account password')),
      );
    });
  });
}
