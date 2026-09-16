import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/infrastructure/groups/firestore_group_repository.dart';

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
  // starting and joining groups fails in production with a permission error.
  final rules = File('firestore.rules').readAsStringSync();
  final groups = _flat(_block(rules, '/groups/{groupId}'));

  test('groups live in their own collection', () {
    expect(groups, isNotEmpty);
    expect(FirestoreGroupRepository.collection, 'groups');
    // A one-to-one chat stays where versions from before groups look.
    expect(isGroupIdString('uid-alice_uid-bob'), isFalse);
  });

  test('a group holds exactly the fields the repository stores', () {
    final listed = RegExp(
      r'function groupFields\(\) \{ return \[([^\]]*)\]',
    ).firstMatch(groups)?.group(1);
    expect(listed, isNotNull);
    expect(
      RegExp("'([^']+)'").allMatches(listed!).map((m) => m.group(1)).toSet(),
      FirestoreGroupRepository.fields,
    );
  });

  test('only members read messages, and the invited read the group', () {
    final messages = _flat(_block(rules, '/messages/{messageId}'));
    expect(
      _flat(
        _block(_block(rules, '/groups/{groupId}'), '/messages/{messageId}'),
      ),
      contains(
        'allow read: if signedIn() && request.auth.uid in groupNow().memberIds;',
      ),
    );
    expect(messages, isNotEmpty);
    expect(
      groups,
      contains(
        'request.auth.uid in resource.data.memberIds || '
        'request.auth.uid in resource.data.invitedIds',
      ),
    );
  });

  test('the group size matches the app\'s', () {
    // The creator is the one member; everyone else is invited.
    expect(groups, contains('invitedIds.size() <= ${Group.maxMembers - 1}'));
  });

  test('a conversation is found where its kind is kept', () {
    expect(
      File('lib/infrastructure/core/firestore_helpers.dart').readAsStringSync(),
      contains("isGroupIdString(id) ? 'groups' : 'chats'"),
    );
    // Messages and keys go through that one place.
    expect(
      File(
        'lib/infrastructure/chats/messages/message_repository.dart',
      ).readAsStringSync(),
      isNot(contains("collection('chats')")),
    );
    expect(
      File(
        'lib/infrastructure/encryption/chat_keyring.dart',
      ).readAsStringSync(),
      isNot(contains("collection('chats')")),
    );
  });
}
