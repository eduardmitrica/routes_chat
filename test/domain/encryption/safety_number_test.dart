import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/encryption/safety_number.dart';

/// Two keys that stand in for real X25519 public keys, which are 32 bytes.
final _aliceKey = List<int>.generate(32, (index) => index);
final _bobKey = List<int>.generate(32, (index) => 255 - index);

SafetyNumber _number({
  String userId = 'uid-alice',
  List<int>? publicKey,
  String otherUserId = 'uid-bob',
  List<int>? otherPublicKey,
}) => safetyNumberOf(
  userId: userId,
  publicKey: publicKey ?? _aliceKey,
  otherUserId: otherUserId,
  otherPublicKey: otherPublicKey ?? _bobKey,
);

void main() {
  group('the number', () {
    test('is 60 digits, in 12 groups of 5', () {
      final number = _number();
      expect(number.digits.length, 60);
      expect(RegExp(r'^\d{60}$').hasMatch(number.digits), isTrue);
      expect(number.groups.length, 12);
      expect(number.groups.every((group) => group.length == 5), isTrue);
      expect(number.groups.join(), number.digits);
    });

    test('is the same on both phones, whoever works it out', () {
      expect(
        _number(),
        _number(
          userId: 'uid-bob',
          publicKey: _bobKey,
          otherUserId: 'uid-alice',
          otherPublicKey: _aliceKey,
        ),
      );
    });

    test('changes when a key changes', () {
      final resetKey = List<int>.generate(32, (index) => index + 1);
      expect(_number(), isNot(_number(otherPublicKey: resetKey)));
      expect(_number(), isNot(_number(publicKey: resetKey)));
    });

    test('changes when the same key belongs to someone else', () {
      expect(_number(), isNot(_number(otherUserId: 'uid-carol')));
    });

    test('stays out of the logs', () {
      expect(_number().toString(), isNot(contains(_number().digits)));
      expect(_number().toString(), 'SafetyNumber(60 digits)');
    });
  });

  group('the code', () {
    test('carries the number, and reads back', () {
      final number = _number();
      expect(SafetyNumber.fromQrPayload(number.qrPayload), number);
      // Whitespace from a scanner does not matter.
      expect(SafetyNumber.fromQrPayload(' ${number.qrPayload}\n'), number);
    });

    test('names itself, so another app\'s code is not taken for ours', () {
      expect(_number().qrPayload, startsWith('routes_chat/safety-number/v1/'));
      expect(SafetyNumber.fromQrPayload('https://example.com'), isNull);
      expect(SafetyNumber.fromQrPayload(''), isNull);
    });

    test('is refused when it does not hold 60 digits', () {
      expect(
        SafetyNumber.fromQrPayload('routes_chat/safety-number/v1/123'),
        isNull,
      );
      expect(
        SafetyNumber.fromQrPayload('routes_chat/safety-number/v1/${'1' * 59}x'),
        isNull,
      );
    });
  });
}
