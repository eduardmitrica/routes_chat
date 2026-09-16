import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every Firestore listener in the infrastructure layer must stop when the
/// session ends.
///
/// Firebase sign-out revokes the auth token, and a listener still open at that
/// moment is rejected by the security rules (PERMISSION_DENIED). Repositories
/// therefore follow each `.snapshots()` with `.takeUntil(_session.ended)`, and
/// AuthenticationBloc ends the session before signing out.
void main() {
  test('each .snapshots() listener is bounded by the session', () {
    final files = Directory('lib/infrastructure')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.endsWith('.freezed.dart'))
        .where((file) => !file.path.endsWith('.g.dart'));

    var listeners = 0;
    final offenders = <String>[];
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        if (!lines[index].contains('.snapshots()')) continue;
        listeners++;
        // Usually on the next line; on the same one when the call is short
        // enough for the formatter to keep it there.
        final next = index + 1 < lines.length ? lines[index + 1].trim() : '';
        const bound = '.takeUntil(_session.ended)';
        if (next != bound && !lines[index].contains(bound)) {
          offenders.add(
            '${file.path.replaceAll(r'\', '/')}:${index + 1}: '
            '${lines[index].trim()}',
          );
        }
      }
    }

    expect(
      listeners,
      greaterThan(0),
      reason: 'no listeners found; the scan itself is probably broken',
    );
    expect(
      offenders,
      isEmpty,
      reason:
          'These Firestore listeners are not bounded by the session and will '
          'be rejected with PERMISSION_DENIED on sign-out. Follow .snapshots() '
          'with .takeUntil(_session.ended):\n${offenders.join('\n')}',
    );
  });
}
