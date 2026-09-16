import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/encryption/safety_number/safety_number_bloc.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/encryption/key_verifications.dart';
import 'package:routes_chat/domain/encryption/public_keys.dart';
import 'package:routes_chat/domain/encryption/safety_number.dart';

import '../../helpers/outbox_fakes.dart';

final _aliceKey = PublishedKey(List<int>.generate(32, (index) => index), 1);
final _bobKey = PublishedKey(List<int>.generate(32, (index) => 255 - index), 1);
final _bobAfterReset = PublishedKey(
  List<int>.generate(32, (index) => index * 3 % 256),
  2,
);
final _bob = UniqueId.fromUniqueString('uid-bob');

class _Keys implements IPublicKeys {
  PublishedKey? mine;
  PublishedKey? theirs;

  _Keys({this.mine, this.theirs});

  @override
  Future<PublishedKey?> own() async => mine;

  @override
  Future<PublishedKey?> of(String userId) async => theirs;
}

class _Verifications implements IKeyVerificationsRepository {
  final _changes = StreamController<KeyVerifications>.broadcast();
  var _now = const KeyVerifications();
  final calls = <String>[];

  @override
  Stream<KeyVerifications> watch() async* {
    yield _now;
    yield* _changes.stream;
  }

  void _emit(KeyVerifications verifications) {
    _now = verifications;
    _changes.add(verifications);
  }

  @override
  Future<void> verify(String userId, SafetyNumber number) async {
    calls.add('verify $userId');
    _emit(
      KeyVerifications(
        byUserId: {
          ..._now.byUserId,
          userId: KeyVerification(
            number: number,
            at: DateTime.utc(2026, 9, 16),
          ),
        },
      ),
    );
  }

  @override
  Future<void> forget(String userId) async {
    calls.add('forget $userId');
    _emit(KeyVerifications(byUserId: {..._now.byUserId}..remove(userId)));
  }

  @override
  Future<void> warningSeen(String userId, SafetyNumber number) async {
    calls.add('warningSeen $userId');
    final verification = _now.byUserId[userId];
    if (verification == null) return;
    _emit(
      KeyVerifications(
        byUserId: {
          ..._now.byUserId,
          userId: verification.withWarningSeenFor(number),
        },
      ),
    );
  }
}

void main() {
  late _Keys keys;
  late _Verifications verifications;
  late SafetyNumberBloc bloc;

  Future<SafetyNumberBloc> open({bool start = true}) async {
    final session = signedInAlice();
    addTearDown(session.end);
    bloc = SafetyNumberBloc(keys, verifications, session);
    addTearDown(bloc.close);
    if (start) {
      bloc.add(SafetyNumberEvent.started(_bob));
      await pumpEventQueue();
    }
    return bloc;
  }

  setUp(() {
    keys = _Keys(mine: _aliceKey, theirs: _bobKey);
    verifications = _Verifications();
  });

  test('works out the number both phones show', () async {
    await open();

    expect(bloc.state.loading, isFalse);
    expect(bloc.state.number, isNotNull);
    expect(
      bloc.state.number,
      safetyNumberOf(
        userId: 'uid-alice',
        publicKey: _aliceKey.bytes,
        otherUserId: 'uid-bob',
        otherPublicKey: _bobKey.bytes,
      ),
    );
    expect(bloc.state.state, KeyVerificationState.unverified);
    expect(bloc.state.withoutKeys, isFalse);
  });

  test('says when there is nothing to compare yet', () async {
    keys.theirs = null;
    await open();

    expect(bloc.state.loading, isFalse);
    expect(bloc.state.number, isNull);
    expect(bloc.state.withoutKeys, isTrue);
  });

  test('comparing by hand marks them verified', () async {
    await open();
    bloc.add(const SafetyNumberEvent.verified());
    await pumpEventQueue();

    expect(verifications.calls, ['verify uid-bob']);
    expect(bloc.state.state, KeyVerificationState.verified);
    expect(bloc.state.warns, isFalse);
  });

  test('a scanned code that matches verifies them', () async {
    await open();
    final code = bloc.state.number!.qrPayload;

    bloc.add(SafetyNumberEvent.scanned(code));
    await pumpEventQueue();

    expect(bloc.state.lastScan, ScanOutcome.matched);
    expect(bloc.state.state, KeyVerificationState.verified);
  });

  test('a scanned code that differs verifies nobody', () async {
    await open();

    bloc.add(SafetyNumberEvent.scanned(SafetyNumber('9' * 60).qrPayload));
    await pumpEventQueue();

    expect(bloc.state.lastScan, ScanOutcome.differed);
    expect(bloc.state.state, KeyVerificationState.unverified);
    expect(verifications.calls, isEmpty);

    bloc.add(const SafetyNumberEvent.scanned('https://example.com'));
    await pumpEventQueue();
    expect(bloc.state.lastScan, ScanOutcome.notOurs);
    expect(verifications.calls, isEmpty);
  });

  test('their keys changing drops the check and warns once', () async {
    await open();
    bloc.add(const SafetyNumberEvent.verified());
    await pumpEventQueue();

    // They reset their keys; the chat is still open.
    keys.theirs = _bobAfterReset;
    bloc.add(const SafetyNumberEvent.refreshed());
    await pumpEventQueue();

    expect(bloc.state.state, KeyVerificationState.changed);
    expect(bloc.state.warns, isTrue);

    bloc.add(const SafetyNumberEvent.warningSeen());
    await pumpEventQueue();
    expect(bloc.state.state, KeyVerificationState.changed);
    expect(bloc.state.warns, isFalse);
  });

  test('forgetting a check leaves them unverified', () async {
    await open();
    bloc.add(const SafetyNumberEvent.verified());
    await pumpEventQueue();

    bloc.add(const SafetyNumberEvent.forgotten());
    await pumpEventQueue();

    expect(verifications.calls, ['verify uid-bob', 'forget uid-bob']);
    expect(bloc.state.state, KeyVerificationState.unverified);
  });

  test('what is compared stays out of the logs', () async {
    await open();

    expect(bloc.state.toString(), isNot(contains(bloc.state.number!.digits)));
  });
}
