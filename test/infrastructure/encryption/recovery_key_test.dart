import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/encryption/recovery_key.dart';

void main() {
  group('base32', () {
    // RFC 4648, section 10, without the padding.
    const vectors = {
      '': '',
      'f': 'MY',
      'fo': 'MZXQ',
      'foo': 'MZXW6',
      'foob': 'MZXW6YQ',
      'fooba': 'MZXW6YTB',
      'foobar': 'MZXW6YTBOI',
    };

    test('encodes the RFC 4648 test vectors', () {
      for (final MapEntry(:key, :value) in vectors.entries) {
        expect(base32Encode(utf8.encode(key)), value, reason: key);
      }
    });

    test('decodes the RFC 4648 test vectors', () {
      for (final MapEntry(:key, :value) in vectors.entries) {
        expect(utf8.decode(base32Decode(value)!), key, reason: value);
      }
    });

    test('rejects characters outside the alphabet', () {
      for (final invalid in ['MZXW0', 'MZXW1', 'MZXW8', 'MZXW9', 'MZ=W6']) {
        expect(base32Decode(invalid), isNull, reason: invalid);
      }
    });
  });

  group('RecoveryKey', () {
    test('is shown as eight groups of four base32 characters', () {
      final key = RecoveryKey.generate();

      expect(key.formatted, matches(RegExp(r'^[A-Z2-7]{4}(-[A-Z2-7]{4}){7}$')));
    });

    test('reads back exactly what it shows', () {
      final key = RecoveryKey.generate();

      expect(RecoveryKey.tryParse(key.formatted), key);
    });

    test('forgives case, spaces and missing dashes when typed', () {
      final key = RecoveryKey.generate();
      final typed = key.formatted.toLowerCase().replaceAll('-', ' ');

      expect(RecoveryKey.tryParse(typed), key);
      expect(RecoveryKey.tryParse(key.formatted.replaceAll('-', '')), key);
    });

    test('rejects input that is not a recovery key', () {
      final key = RecoveryKey.generate().formatted;

      expect(RecoveryKey.tryParse(key.substring(0, key.length - 1)), isNull);
      expect(RecoveryKey.tryParse('${key}A'), isNull);
      expect(RecoveryKey.tryParse(key.replaceRange(0, 1, '0')), isNull);
      expect(RecoveryKey.tryParse(''), isNull);
    });

    test('holds 160 random bits, different every time', () {
      final keys = {
        for (var i = 0; i < 100; i++) RecoveryKey.generate().formatted,
      };

      expect(RecoveryKey.generate().bytes, hasLength(20));
      expect(keys, hasLength(100));
    });

    test('is reproducible from a seeded source, for tests only', () {
      expect(RecoveryKey.generate(Random(7)), RecoveryKey.generate(Random(7)));
    });

    test('never prints the key', () {
      final key = RecoveryKey.generate();

      expect(key.toString(), isNot(contains(key.formatted.substring(0, 4))));
    });
  });
}
