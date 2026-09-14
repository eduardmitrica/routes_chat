import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/encryption/encryption_bloc.dart';
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

  @override
  Future<void> lock() async {}
}

void main() {
  late _FakeEncryption encryption;
  late EncryptionBloc bloc;

  setUp(() {
    encryption = _FakeEncryption();
    bloc = EncryptionBloc(encryption, random: Random(1));
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
}
