import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _flag = '--dart-define-from-file=.env';

void main() {
  // The app reads its Firebase and Google client settings from .env at compile
  // time. A shared run configuration that forgets the flag builds an app that
  // stops at startup with "Missing configuration", so every committed one must
  // pass it.

  test('every VS Code launch configuration passes the .env flag', () {
    final launch =
        jsonDecode(File('.vscode/launch.json').readAsStringSync())
            as Map<String, dynamic>;
    final configurations = (launch['configurations'] as List)
        .cast<Map<String, dynamic>>();

    expect(configurations, isNotEmpty);
    for (final configuration in configurations) {
      expect(
        (configuration['toolArgs'] as List?) ?? const [],
        contains(_flag),
        reason: '"${configuration['name']}" in .vscode/launch.json',
      );
    }
  });

  test('every Android Studio run configuration passes the .env flag', () {
    final files = Directory('.idea/runConfigurations')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.xml'))
        .toList();

    expect(files, isNotEmpty);
    for (final file in files) {
      expect(
        file.readAsStringSync(),
        contains('name="additionalArgs" value="$_flag"'),
        reason: file.path.replaceAll(r'\', '/'),
      );
    }
  });
}
