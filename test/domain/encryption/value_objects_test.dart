import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/core/failures.dart';
import 'package:routes_chat/domain/encryption/value_objects.dart';

ValueFailure<String>? _failure(Either value) =>
    value.fold((failure) => failure as ValueFailure<String>, (_) => null);

void main() {
  group('Passphrase', () {
    test('accepts 12 characters, spaces included', () {
      expect(Passphrase('a b c d e fg').isValid(), isTrue);
    });

    test('refuses 11 characters, reporting the minimum', () {
      final failure = _failure(Passphrase('a b c d e f').value);

      expect(failure, isA<PassphraseTooShort>());
      expect((failure! as PassphraseTooShort).minimumLength, 12);
    });

    test('counts characters, not bytes', () {
      // Twelve characters, most of them multi-byte in UTF-8.
      expect(Passphrase('ăîșțâăîșțâăî').isValid(), isTrue);
    });

    test('keeps the passphrase exactly as typed', () {
      const typed = '  padded passphrase  ';

      expect(Passphrase(typed).getOrCrash(), typed);
    });

    test('refuses more than 512 characters', () {
      expect(_failure(Passphrase('x' * 513).value), isA<ExceedingLength>());
      expect(Passphrase('x' * 512).isValid(), isTrue);
    });

    test('never prints the passphrase', () {
      expect(
        Passphrase('correct horse battery staple').toString(),
        isNot(contains('horse')),
      );
    });
  });

  group('RecoveryKeyInput', () {
    const formatted = 'ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZ23-4567';

    test('accepts the key as shown, normalized to 32 characters', () {
      expect(
        RecoveryKeyInput(formatted).getOrCrash(),
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567',
      );
    });

    test('forgives case, spaces and missing dashes', () {
      expect(
        RecoveryKeyInput(
          'abcd efgh ijkl mnop qrst uvwx yz23 4567',
        ).getOrCrash(),
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567',
      );
    });

    test('refuses a key with a missing character', () {
      expect(
        _failure(RecoveryKeyInput(formatted.substring(1)).value),
        isA<InvalidRecoveryKeyFormat>(),
      );
    });

    test('refuses characters base32 does not use', () {
      // 0, 1, 8 and 9 never appear in a recovery key.
      expect(
        _failure(RecoveryKeyInput(formatted.replaceFirst('A', '0')).value),
        isA<InvalidRecoveryKeyFormat>(),
      );
    });

    test('never prints the key', () {
      expect(RecoveryKeyInput(formatted).toString(), isNot(contains('ABCD')));
    });
  });
}
