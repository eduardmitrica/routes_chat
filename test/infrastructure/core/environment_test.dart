import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/core/environment.dart';

List<String> _exampleKeys() => File('.env.example')
    .readAsLinesSync()
    .map((line) => line.trim())
    .where((line) => line.isNotEmpty && !line.startsWith('#'))
    .map((line) => line.split('=').first)
    .toList();

void main() {
  // flutter test runs without --dart-define-from-file, the same as CI, so every
  // value is empty here. Running the tests with the flag would fail the first
  // test, which is expected.

  test('without the .env flag every key is reported missing', () {
    expect(Environment.missingKeys, Environment.values.keys.toList());
  });

  test('a run without configuration stops with the missing keys', () {
    expect(
      Environment.ensureConfigured,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('FIRESTORE_DATABASE_ID'),
            contains('GOOGLE_SERVER_CLIENT_ID'),
            contains('--dart-define-from-file=.env'),
          ),
        ),
      ),
    );
  });

  test('.env.example lists exactly the keys Environment reads, in order', () {
    // A key added to Environment but not to .env.example (or the reverse) would
    // leave every fresh checkout unable to start.
    expect(_exampleKeys(), [
      ...Environment.values.keys,
      ...Environment.optionalValues.keys,
    ]);
  });

  test('an optional key is never required to start', () {
    for (final key in Environment.optionalValues.keys) {
      expect(Environment.missingKeys, isNot(contains(key)));
    }
  });
}
