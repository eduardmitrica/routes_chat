import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/safety/safety_repository_interface.dart';
import 'package:routes_chat/infrastructure/safety/firestore_safety_repository.dart';

/// The block of `match <path> {` in [rules], up to its matching brace.
String _block(String rules, String path) {
  final header = 'match $path {';
  final start = rules.indexOf(header);
  if (start == -1) return '';
  var depth = 0;
  for (var index = start + header.length - 1; index < rules.length; index++) {
    if (rules[index] == '{') depth++;
    if (rules[index] == '}' && --depth == 0) {
      return rules.substring(start, index + 1);
    }
  }
  return '';
}

String _flat(String text) => text.replaceAll(RegExp(r'\s+'), ' ');

void main() {
  // What the repository writes and what firestore.rules accept must agree, or
  // blocking and reporting fail in production with a permission error.
  final rules = File('firestore.rules').readAsStringSync();
  final repository = File(
    'lib/infrastructure/safety/firestore_safety_repository.dart',
  ).readAsStringSync();

  group('blocks', () {
    String blocks() => _flat(_block(rules, '/blocks/{blockedId}'));

    test('live under the user, private to them', () {
      expect(
        _block(rules, '/users/{userId}'),
        contains('match /blocks/{blockedId}'),
      );
      expect(
        blocks(),
        contains(
          'allow read, delete: if signedIn() && request.auth.uid == userId;',
        ),
      );
    });

    test('hold only what the repository writes, as long as it keeps it', () {
      expect(blocks(), contains("hasOnly(['blockedSince', 'earlier'])"));
      expect(blocks(), contains('blockedSince == request.time'));
      expect(
        blocks(),
        contains(".size() <= ${FirestoreSafetyRepository.maxEarlierBlocks}"),
      );
      expect(
        repository,
        contains("'blockedSince': FieldValue.serverTimestamp()"),
      );
      expect(repository, contains("'earlier':"));
    });
  });

  group('reports', () {
    String reports() => _flat(_block(rules, '/reports/{reportId}'));

    test('are filed, never read back, changed or deleted from the app', () {
      expect(reports(), contains('allow read, update, delete: if false;'));
    });

    test('hold only what the repository writes', () {
      expect(
        reports(),
        contains(
          "hasOnly(['reporterId', 'reportedId', 'chatId', 'reason', "
          "'messages', 'createdAt'])",
        ),
      );
      for (final field in [
        'reporterId',
        'reportedId',
        'chatId',
        'reason',
        'messages',
        'createdAt',
      ]) {
        expect(repository, contains("'$field':"));
      }
      expect(reports(), contains('createdAt == request.time'));
    });

    test('accept the reasons the app stores, and as many messages', () {
      final reasons = [
        for (final reason in ReportReason.values) "'${reason.storedName}'",
      ].join(', ');
      expect(reports(), contains('reason in [$reasons]'));
      expect(
        reports(),
        contains('messages.size() <= ${ReportedMessage.maxPerReport}'),
      );
    });
  });
}
