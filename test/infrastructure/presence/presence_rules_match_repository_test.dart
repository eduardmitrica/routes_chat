import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The block of `match <path> {` in [rules], up to its matching brace; empty
/// when there is none.
String _block(String rules, String path) {
  final header = 'match $path {';
  final start = rules.indexOf(header);
  if (start == -1) return '';
  var depth = 0;
  // From the brace that opens the block, not the ones in the path.
  for (var index = start + header.length - 1; index < rules.length; index++) {
    if (rules[index] == '{') depth++;
    if (rules[index] == '}' && --depth == 0) {
      return rules.substring(start, index + 1);
    }
  }
  return '';
}

void main() {
  // The repository and firestore.rules must agree on the fields, or typing and
  // presence fail in production with a permission error while every other test
  // passes.
  final rules = File('firestore.rules').readAsStringSync();
  final repository = File(
    'lib/infrastructure/presence/firestore_presence_repository.dart',
  ).readAsStringSync();

  group('typing', () {
    String typing() => _block(rules, '/typing/{userId}');

    test('holds only the server time the repository writes', () {
      expect(typing(), contains("hasOnly(['typingAt'])"));
      expect(
        typing(),
        contains('request.resource.data.typingAt == request.time'),
      );
      expect(repository, contains("'typingAt': FieldValue.serverTimestamp()"));
    });

    test('is read by the chat\'s participants, decided from the ids', () {
      expect(
        typing(),
        contains(
          "allow read: if signedIn() && request.auth.uid in chatId.split('_');",
        ),
      );
    });

    test('is written only by its own participant', () {
      expect(typing(), contains('request.auth.uid == userId'));
      expect(typing(), contains("userId in chatId.split('_')"));
    });

    test('lives inside the chat it is about', () {
      expect(
        _block(rules, '/chats/{chatId}'),
        contains('match /typing/{userId}'),
      );
    });
  });

  group('presence', () {
    String presence() => _block(rules, '/presence/{userId}');

    test('holds only what the repository writes', () {
      expect(presence(), contains("hasOnly(['state', 'lastSeenAt'])"));
      expect(presence(), contains("state in ['online', 'offline']"));
      expect(
        presence(),
        contains('request.resource.data.lastSeenAt == request.time'),
      );
      expect(repository, contains("'state': 'online'"));
      expect(repository, contains("'state': 'offline'"));
      expect(
        repository,
        contains("'lastSeenAt': FieldValue.serverTimestamp()"),
      );
    });

    test('is read only by its owner and their friends, never listed', () {
      expect(
        presence(),
        contains('(request.auth.uid == userId || friendsWithCaller())'),
      );
      expect(
        presence(),
        contains("get(requestPath).data.status == 'Accepted'"),
      );
      expect(presence(), contains('allow list: if false;'));
    });

    test('is written and deleted only by its owner', () {
      expect(
        RegExp(
          r'allow (create, update|delete): if signedIn\(\) &&\s+request\.auth\.uid == userId',
        ).allMatches(presence()),
        hasLength(2),
      );
    });
  });
}
