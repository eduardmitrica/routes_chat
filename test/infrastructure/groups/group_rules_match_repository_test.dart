import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/infrastructure/encryption/chat_keyring.dart';
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

  test('nobody writes before the key is sealed to exactly the group', () {
    // Otherwise someone taken out could read what is sent next.
    expect(
      _flat(
        _block(_block(rules, '/groups/{groupId}'), '/messages/{messageId}'),
      ),
      contains('sealedKeys.keys().toSet() == everyoneIn(groupAfter()).toSet()'),
    );
  });

  test('an invitation is always recorded as its writer\'s', () {
    // One recorded as a friend's would make the invited phone join by itself.
    expect(groups, contains('after.invitedBy[newcomer] == me'));
    expect(groups, contains('invitedBy.values().toSet() =='));
  });

  test('shared history is read only by the person it is sealed to', () {
    expect(
      _flat(_block(rules, '/sharedKeys/{userId}')),
      contains('allow get: if signedIn() && request.auth.uid == userId;'),
    );
  });

  test('copied history is read only by its person, once they joined', () {
    final copies = _flat(
      _block(_block(rules, '/history/{userId}'), '/messages/{messageId}'),
    );
    expect(
      copies,
      contains(
        'allow read: if signedIn() && request.auth.uid == userId && '
        'userId in groupNow().memberIds;',
      ),
    );
    // Under the history generation, which no real generation is.
    expect(
      copies,
      contains(
        'isEncryptedContent(request.resource.data.content, '
        '${ChatKeyring.historyGeneration})',
      ),
    );
    expect(copies, contains('original().serverTimeStamp >= grant().since'));
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

  test('an event holds exactly the fields the repository writes', () {
    final listed = RegExp(
      r'function eventFields\(\) \{ return \[([^\]]*)\]',
    ).firstMatch(groups)?.group(1);
    expect(listed, isNotNull);
    final source = File(
      'lib/infrastructure/groups/firestore_group_repository.dart',
    ).readAsStringSync();
    final start = source.indexOf('static void _event(');
    expect(start, isNot(-1));
    final written = source.substring(start, source.indexOf('});', start));
    expect(
      RegExp("'([^']+)'").allMatches(listed!).map((m) => m.group(1)).toSet(),
      RegExp(
        r"'(\w+)': \??",
      ).allMatches(written).map((m) => m.group(1)).toSet(),
    );
    // Content messages are told apart from events by having no kind.
    expect(groups, contains("!('kind' in request.resource.data)"));
  });

  group('changing messages', () {
    final messages = _flat(_block(groups, '/messages/{messageId}'));

    test('the sender edits or deletes as in a chat, never an event', () {
      expect(messages, contains('(isMessageEdit() || isMessageDeletion())'));
      expect(messages, contains("!('kind' in resource.data)"));
      expect(messages, contains('resource.data.senderId == request.auth.uid'));
      expect(messages, contains('allow delete: if false;'));
      expect(
        _flat(_block(rules, '/chats/{chatId}')),
        contains('(isMessageEdit() || isMessageDeletion())'),
      );
    });

    test("the group's copy of its last message follows the change", () {
      expect(groups, contains('followsGroupLastMessage()'));
      expect(
        File(
          'lib/infrastructure/chats/messages/message_repository.dart',
        ).readAsStringSync(),
        contains("'lastMessage.\$key': value"),
      );
    });

    test('reactions live in the group, for members, under its current key', () {
      final reactions = _flat(_block(groups, '/reactions/{reactionId}'));
      expect(reactions, isNotEmpty);
      expect(
        reactions,
        contains(
          'allow read: if signedIn() && request.auth.uid in groupNow().memberIds;',
        ),
      );
      expect(
        reactions,
        contains('content.e == groupNow().currentKeyGeneration'),
      );
      expect(reactions, contains('content.cipherText.size() == 172'));
    });
  });
}
