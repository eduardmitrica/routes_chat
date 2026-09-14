import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Firebase and Google client settings come from compile-time environment
/// values (`--dart-define-from-file=.env`, see `.env.example`), read through
/// `Environment`. None of them may be written into the source again.
void main() {
  test('no Firebase or Google client configuration is hardcoded in lib/', () {
    final patterns = {
      'Firebase API key': RegExp(r'AIza[0-9A-Za-z_\-]{35}'),
      'Firebase app id': RegExp(r'\b1:[0-9]+:(android|ios|web):[0-9a-f]+'),
      'Google OAuth client id': RegExp(
        r'[0-9]+-[0-9a-z]+\.apps\.googleusercontent\.com',
      ),
      'Firestore database id literal': RegExp(r'''databaseId:\s*['"]'''),
    };

    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    final offenders = <String>[];
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        for (final pattern in patterns.entries) {
          if (pattern.value.hasMatch(lines[index])) {
            offenders.add(
              '${file.path.replaceAll(r'\', '/')}:${index + 1}: ${pattern.key}',
            );
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Read these from Environment '
          '(lib/infrastructure/core/environment.dart) and add the key to '
          '.env.example instead:\n${offenders.join('\n')}',
    );
  });
}
