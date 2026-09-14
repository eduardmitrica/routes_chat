import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The first statement in the `match /<collection>/{<idVariable>}` block that
/// governs direct reads (`allow get` or `allow read`), up to its `;`.
String _directReadRule(String rules, String collection, String idVariable) {
  final block = rules.indexOf('match /$collection/{$idVariable}');
  expect(
    block,
    isNot(-1),
    reason: 'match /$collection/{$idVariable} not found in firestore.rules',
  );
  final statement = RegExp(
    r'allow (get|read)\b[^;]*;',
  ).firstMatch(rules.substring(block));
  expect(
    statement,
    isNotNull,
    reason: 'no allow get/read rule for $collection',
  );
  return statement!.group(0)!;
}

void main() {
  // Regression: starting a chat always failed, silently. ChatRepository.create
  // calls transaction.get(chatRef) on a chat that does not exist yet, and the
  // chats read rule checked `resource.data.participantIds`. `resource` is null
  // for a missing document, so the read, and with it the whole transaction,
  // was denied.
  //
  // FriendRequestRepository.create does the same with the pair document. For
  // both collections the direct-read rule must decide from the document id
  // (both uids, sorted and joined with "_"), never from the stored document.
  final rules = File('firestore.rules').readAsStringSync();

  for (final (collection, idVariable) in [
    ('chats', 'chatId'),
    ('friendRequests', 'requestId'),
  ]) {
    test('$collection: a direct read of a missing document is decidable', () {
      final rule = _directReadRule(rules, collection, idVariable);
      expect(
        rule,
        isNot(contains('resource.')),
        reason:
            'transaction.get on a $collection document that does not exist '
            'yet is denied when the read rule dereferences resource:\n$rule',
      );
      expect(
        rule,
        contains('$idVariable.split('),
        reason: 'the read rule should check the caller against the id:\n$rule',
      );
    });
  }
}
