import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/encryption/key_verifications.dart';
import 'package:routes_chat/domain/encryption/safety_number.dart';
import 'package:routes_chat/infrastructure/core/local_vault.dart';
import 'package:routes_chat/infrastructure/encryption/key_verifications_store.dart';
import 'package:routes_chat/domain/shared/user/current_user_information_persistent.dart';
import 'package:routes_chat/infrastructure/shared/user/current_user_session.dart';

import '../../helpers/outbox_fakes.dart';

class _MemorySecrets implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  late Directory base;
  late _MemorySecrets secrets;
  late CurrentUserSession session;
  var now = DateTime.utc(2026, 9, 16, 12);
  final number = SafetyNumber('1' * 60);
  final changed = SafetyNumber('2' * 60);

  KeyVerificationsStore storeFor(CurrentUserSession session) =>
      KeyVerificationsStore(
        LocalVault(secrets, session, baseDirectory: () async => base),
        session,
        now: () => now,
      );

  setUp(() {
    base = Directory.systemTemp.createTempSync('key_verifications_store_test');
    secrets = _MemorySecrets();
    session = signedInAlice();
    now = DateTime.utc(2026, 9, 16, 12);
  });

  tearDown(() {
    if (base.existsSync()) base.deleteSync(recursive: true);
  });

  test('nobody is checked to begin with', () async {
    expect(await storeFor(session).watch().first, const KeyVerifications());
  });

  test('keeps a check on the phone, encrypted, for the next launch', () async {
    await storeFor(session).verify('uid-bob', number);

    final kept = await storeFor(session).watch().first;
    expect(kept.stateOf('uid-bob', number), KeyVerificationState.verified);
    expect(kept.forUser('uid-bob')?.at, now);

    // The file gives nothing away without the phone's key.
    final files = base
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => file.readAsBytesSync())
        .toList();
    expect(files, isNotEmpty);
    for (final bytes in files) {
      expect(String.fromCharCodes(bytes), isNot(contains(number.digits)));
      expect(String.fromCharCodes(bytes), isNot(contains('uid-bob')));
    }
  });

  test('a changed number is no longer the one that was checked', () async {
    final store = storeFor(session);
    await store.verify('uid-bob', number);

    final verifications = await store.watch().first;
    expect(
      verifications.stateOf('uid-bob', changed),
      KeyVerificationState.changed,
    );
    expect(verifications.warnsAbout('uid-bob', changed), isTrue);
  });

  test('a warning waved away is not shown again for that number', () async {
    final store = storeFor(session);
    await store.verify('uid-bob', number);
    await store.warningSeen('uid-bob', changed);

    final verifications = await store.watch().first;
    expect(verifications.warnsAbout('uid-bob', changed), isFalse);
    expect(verifications.warnsAbout('uid-bob', SafetyNumber('3' * 60)), isTrue);
  });

  test('forgetting a check stops the warnings too', () async {
    final store = storeFor(session);
    await store.verify('uid-bob', number);
    await store.forget('uid-bob');

    final verifications = await store.watch().first;
    expect(
      verifications.stateOf('uid-bob', number),
      KeyVerificationState.unverified,
    );
    expect(verifications.warnsAbout('uid-bob', changed), isFalse);
  });

  test('the next user on this phone starts with nobody checked', () async {
    final store = storeFor(session);
    await store.verify('uid-bob', number);
    session.end();

    final next = CurrentUserSession()
      ..start(const CurrentUserInformationPersistent('uid-carol', 'carol'));
    addTearDown(next.end);
    expect(await storeFor(next).watch().first, const KeyVerifications());
  });
}
