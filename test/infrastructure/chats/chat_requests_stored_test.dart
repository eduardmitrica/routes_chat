import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/chat_requests.dart';
import 'package:routes_chat/infrastructure/chats/firestore_chat_requests_repository.dart';

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
  group('a stored decision', () {
    test('is read back with the time the server gave it', () {
      final at = DateTime.utc(2026, 9, 16, 12);
      final decision = FirestoreChatRequestsRepository.decisionFrom({
        'state': 'accepted',
        'at': Timestamp.fromDate(at),
      });
      expect(decision?.state, ChatRequestState.accepted);
      expect(decision?.at.toUtc(), at);
    });

    test('made on this phone counts from now, before the server answers', () {
      final decision = FirestoreChatRequestsRepository.decisionFrom({
        'state': 'deleted',
        'at': null,
      });
      expect(decision?.state, ChatRequestState.deleted);
      expect(
        decision!.at.difference(DateTime.now()).abs(),
        lessThan(const Duration(seconds: 5)),
      );
    });

    test('in an unknown shape counts as no decision', () {
      expect(FirestoreChatRequestsRepository.decisionFrom(null), isNull);
      expect(FirestoreChatRequestsRepository.decisionFrom({}), isNull);
      expect(
        FirestoreChatRequestsRepository.decisionFrom({'state': 'ignored'}),
        isNull,
      );
    });
  });

  // What the repository writes and what firestore.rules accept must agree, or
  // accepting a request fails in production with a permission error.
  group('firestore.rules', () {
    final rules = File('firestore.rules').readAsStringSync();
    final repository = File(
      'lib/infrastructure/chats/firestore_chat_requests_repository.dart',
    ).readAsStringSync();

    test('keep the decisions under the user, private to them', () {
      expect(
        _block(rules, '/users/{userId}'),
        contains('match /chatRequests/{chatId}'),
      );
      final requests = _flat(_block(rules, '/chatRequests/{chatId}'));
      expect(
        requests,
        contains(
          'allow read, delete: if signedIn() && request.auth.uid == userId;',
        ),
      );
      // Only about a chat the user is in, and only what the repository writes.
      expect(requests, contains("request.auth.uid in chatId.split('_')"));
      expect(requests, contains("hasOnly(['state', 'at'])"));
      expect(
        requests,
        contains(
          "state in "
          "['${ChatRequestState.accepted.storedName}', "
          "'${ChatRequestState.deleted.storedName}']",
        ),
      );
      // The time is the server's, so a deleted request cannot be dated ahead
      // to keep later messages out of sight.
      expect(requests, contains('at == request.time'));
      expect(repository, contains("'at': FieldValue.serverTimestamp()"));
      expect(repository, contains("'state': state.storedName"));
    });

    test('keep the messaging setting private, and a bool', () {
      final settings = _flat(_block(rules, '/settings/{document}'));
      expect(
        settings,
        contains('allow read: if signedIn() && request.auth.uid == userId;'),
      );
      expect(
        settings,
        contains(
          "document == '${FirestoreChatRequestsRepository.messagingSettings}'",
        ),
      );
      expect(settings, contains("hasOnly(['allowFromAnyone'])"));
      expect(settings, contains('allowFromAnyone is bool'));
      expect(settings, contains('allow delete: if false;'));
      expect(repository, contains("{'allowFromAnyone': allow}"));
    });
  });
}
