import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the app theme (`lib/presentation/core/theme`).
///
/// A screen that names a color looks right in one theme and wrong in the
/// other, so screens take colors from the theme instead. And buttons are the
/// kinds the theme styles: filled for the main action, outlined for an
/// alternative, text for a way around.
void main() {
  const themeDirectory = 'lib/presentation/core/theme/';

  /// `Colors.transparent` is the absence of a color, the same in any theme.
  final namedColor = RegExp(r'\bColors\.(?!transparent\b)\w+|\bColor\(0x');
  final unstyledButton = RegExp(r'\bElevatedButton\b');
  final lineComment = RegExp(r'//.*');

  final screens = Directory('lib/presentation')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.freezed.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .where((file) => !_path(file).startsWith(themeDirectory))
      .toList();

  List<String> linesMatching(RegExp pattern) => [
    for (final file in screens)
      for (final (index, line) in file.readAsLinesSync().indexed)
        if (pattern.hasMatch(line.replaceAll(lineComment, '')))
          '${_path(file)}:${index + 1}: ${line.trim()}',
  ];

  test('screens take their colors from the theme', () {
    expect(
      linesMatching(namedColor),
      isEmpty,
      reason:
          'Use Theme.of(context).colorScheme or AppColors.of(context), or '
          'add the color to the theme.',
    );
  });

  test('buttons are filled, outlined or text buttons', () {
    expect(
      linesMatching(unstyledButton),
      isEmpty,
      reason:
          'Use FilledButton for the main action, OutlinedButton for an '
          'alternative, TextButton for a way around.',
    );
  });
}

String _path(File file) => file.path.replaceAll(r'\', '/');
