import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/encryption/key_verifications.dart';
import 'package:routes_chat/domain/encryption/safety_number.dart';

final _checked = SafetyNumber('1' * 60);
final _changed = SafetyNumber('2' * 60);
final _noon = DateTime.utc(2026, 9, 16, 12);

KeyVerifications _verifications({SafetyNumber? seen}) => KeyVerifications(
  byUserId: {
    'uid-bob': KeyVerification(
      number: _checked,
      at: _noon,
      warningSeenFor: seen,
    ),
  },
);

void main() {
  test('nobody is verified to begin with', () {
    expect(
      const KeyVerifications().stateOf('uid-bob', _checked),
      KeyVerificationState.unverified,
    );
    expect(const KeyVerifications().warnsAbout('uid-bob', _checked), isFalse);
  });

  test('the number that was checked counts as verified', () {
    expect(
      _verifications().stateOf('uid-bob', _checked),
      KeyVerificationState.verified,
    );
    expect(_verifications().warnsAbout('uid-bob', _checked), isFalse);
  });

  test('another number means their keys changed, and warns once', () {
    final verifications = _verifications();
    expect(
      verifications.stateOf('uid-bob', _changed),
      KeyVerificationState.changed,
    );
    expect(verifications.warnsAbout('uid-bob', _changed), isTrue);

    // Waved away: no more warnings for that number.
    final seen = _verifications(seen: _changed);
    expect(seen.stateOf('uid-bob', _changed), KeyVerificationState.changed);
    expect(seen.warnsAbout('uid-bob', _changed), isFalse);

    // A further change warns again.
    expect(seen.warnsAbout('uid-bob', SafetyNumber('3' * 60)), isTrue);
  });

  test('without a number there is nothing to say', () {
    expect(
      _verifications().stateOf('uid-bob', null),
      KeyVerificationState.unverified,
    );
    expect(_verifications().warnsAbout('uid-bob', null), isFalse);
  });

  test('who was checked stays out of the logs', () {
    expect(_verifications().toString(), isNot(contains('uid-bob')));
    expect(_verifications().toString(), contains('1 checked'));
  });
}
