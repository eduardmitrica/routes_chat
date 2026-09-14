import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A Firestore query that filters on an array plus other fields and orders the
/// result needs a composite index. Without it the query fails only at runtime
/// ("The query requires an index"), and the screen shows a load failure,
/// while every unit test and CI still pass. These tests tie the queries in the
/// repositories to the indexes deployed from firestore.indexes.json.

List<Map<String, dynamic>> _indexes() {
  final json = jsonDecode(File('firestore.indexes.json').readAsStringSync());
  return (json['indexes'] as List).cast<Map<String, dynamic>>();
}

bool _hasIndex(String collection, List<Map<String, String>> fields) {
  return _indexes().any((index) {
    if (index['collectionGroup'] != collection) return false;
    final indexFields = (index['fields'] as List).cast<Map<String, dynamic>>();
    if (indexFields.length != fields.length) return false;
    for (var position = 0; position < fields.length; position++) {
      final expected = fields[position];
      final actual = indexFields[position];
      for (final key in expected.keys) {
        if (actual[key] != expected[key]) return false;
      }
    }
    return true;
  });
}

String _source(String path) => File(path).readAsStringSync();

void main() {
  test('chats: participantIds contains + serverTimeStamp desc', () {
    final repository = _source('lib/infrastructure/chats/chat_repository.dart');
    expect(repository, contains(".where('participantIds', arrayContains:"));
    expect(
      repository,
      contains(".orderBy('serverTimeStamp', descending: true)"),
    );

    expect(
      _hasIndex('chats', [
        {'fieldPath': 'participantIds', 'arrayConfig': 'CONTAINS'},
        {'fieldPath': 'serverTimeStamp', 'order': 'DESCENDING'},
      ]),
      isTrue,
      reason: 'firestore.indexes.json lacks the chats index the query needs',
    );
  });

  test(
    'friendRequests: participantIds contains + status + serverTimeStamp desc',
    () {
      final repository = _source(
        'lib/infrastructure/friend_requests/friend_request_repository.dart',
      );
      expect(repository, contains(".where('participantIds', arrayContains:"));
      expect(repository, contains(".where('status', isEqualTo:"));
      expect(
        repository,
        contains(".orderBy('serverTimeStamp', descending: true)"),
      );

      expect(
        _hasIndex('friendRequests', [
          {'fieldPath': 'participantIds', 'arrayConfig': 'CONTAINS'},
          {'fieldPath': 'status', 'order': 'ASCENDING'},
          {'fieldPath': 'serverTimeStamp', 'order': 'DESCENDING'},
        ]),
        isTrue,
        reason:
            'firestore.indexes.json lacks the friendRequests index the '
            'watchers need',
      );
    },
  );
}
