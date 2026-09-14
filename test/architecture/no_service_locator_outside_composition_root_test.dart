import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the rule that `getIt` is only allowed in the composition root
/// (`lib/injection.dart`) and at the UI boundary (`lib/presentation/**`).
///
/// A class in `domain/`, `application/` or `infrastructure/` that reaches into
/// the service locator has a hidden dependency, cannot be constructed in a test
/// without a configured container, and couples the layer to `get_it`. Those
/// layers take their dependencies through their constructors instead.
void main() {
  const guardedDirectories = [
    'lib/domain',
    'lib/application',
    'lib/infrastructure',
  ];

  /// Matches `getIt` as a whole identifier, so `getItem` or `widgetItem`
  /// do not trip the guard.
  final serviceLocatorUsage = RegExp(r'\bgetIt\b');
  final lineComment = RegExp(r'//.*');

  List<File> dartFilesIn(String directory) => Directory(directory)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      // Generated files are not hand-written, so they are not the author's
      // choice to fix.
      .where((file) => !file.path.endsWith('.freezed.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .toList();

  test('domain, application and infrastructure never reference getIt', () {
    final offenders = <String>[];

    for (final directory in guardedDirectories) {
      for (final file in dartFilesIn(directory)) {
        final lines = file.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          final code = lines[index].replaceAll(lineComment, '');
          if (serviceLocatorUsage.hasMatch(code)) {
            offenders.add(
              '${file.path.replaceAll(r'\', '/')}:${index + 1}: '
              '${lines[index].trim()}',
            );
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'These files reach into the service locator instead of receiving '
          'their dependencies through a constructor. Inject the dependency and '
          'wire it in lib/injection.dart instead:\n${offenders.join('\n')}',
    );
  });

  test('nothing resolves Firestore through FirebaseFirestore.instance', () {
    // This project's Firestore database is a named one ("routes"); the
    // reserved "(default)" database does not exist. FirebaseFirestore.instance
    // silently targets "(default)", so every call through it fails at runtime
    // while compiling perfectly. injection.dart uses instanceFor(databaseId:).
    final offenders = <String>[];
    final defaultInstance = RegExp(r'FirebaseFirestore\s*\.\s*instance(?!For)');

    for (final directory in [...guardedDirectories, 'lib/presentation']) {
      for (final file in dartFilesIn(directory)) {
        final lines = file.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          final code = lines[index].replaceAll(lineComment, '');
          if (defaultInstance.hasMatch(code)) {
            offenders.add(
              '${file.path.replaceAll(r'\', '/')}:${index + 1}: '
              '${lines[index].trim()}',
            );
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Use FirebaseFirestore.instanceFor(app: ..., databaseId: '
          'firestoreDatabaseId) — .instance points at a database that does not '
          'exist in this project:\n${offenders.join('\n')}',
    );
  });

  test('the domain layer does not import the composition root', () {
    final offenders = <String>[];

    for (final file in dartFilesIn('lib/domain')) {
      if (file.readAsStringSync().contains('injection.dart')) {
        offenders.add(file.path.replaceAll(r'\', '/'));
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'The domain layer must not know how dependencies are wired:\n'
          '${offenders.join('\n')}',
    );
  });

  test('nothing registers or unregisters dependencies at runtime', () {
    final offenders = <String>[];
    final runtimeMutation = RegExp(
      r'\b(?:getIt|GetIt\.instance)\s*\.\s*'
      r'(?:register\w*|unregister|reset|pushNewScope|popScope)\b',
    );

    for (final directory in [...guardedDirectories, 'lib/presentation']) {
      for (final file in dartFilesIn(directory)) {
        final lines = file.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          final code = lines[index].replaceAll(lineComment, '');
          if (runtimeMutation.hasMatch(code)) {
            offenders.add(
              '${file.path.replaceAll(r'\', '/')}:${index + 1}: '
              '${lines[index].trim()}',
            );
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Only lib/injection.dart may populate the container. Mutating it at '
          'runtime turns it into global mutable state and makes lookups throw '
          'outside the window in which the value happens to be registered:\n'
          '${offenders.join('\n')}',
    );
  });
}
