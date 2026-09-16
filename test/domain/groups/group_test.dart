import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/groups/group.dart';

Group _group() => Group(
  id: UniqueId.fromUniqueString('group-1'),
  memberIds: const ['uid-alice', 'uid-bob'],
  invitedIds: const ['uid-carol'],
  invitedBy: const {'uid-carol': 'uid-alice'},
  adminIds: const ['uid-alice'],
);

void main() {
  group('a group', () {
    test('is sealed to its members and the people invited', () {
      expect(_group().everyone, ['uid-alice', 'uid-bob', 'uid-carol']);
      expect(_group().isMember('uid-carol'), isFalse);
      expect(_group().isInvited('uid-carol'), isTrue);
      expect(_group().isAdmin('uid-bob'), isFalse);
    });

    test('keeps who is in it out of the logs', () {
      expect(_group().toString(), isNot(contains('uid-')));
      expect(_group().toString(), 'Group(2 members, 1 invited)');
    });
  });

  group('a group id', () {
    test('never looks like a one-to-one chat id', () {
      expect(isGroupId(newGroupId()), isTrue);
      expect(isGroupIdString('uid-alice_uid-bob'), isFalse);
      expect(newGroupId().getOrCrash(), isNot(contains('_')));
    });

    test('is random each time', () {
      expect(newGroupId(), isNot(newGroupId()));
    });

    test('is the shape firestore.rules accepts for a new group', () {
      final rules = File('firestore.rules').readAsStringSync();
      final pattern = RegExp(
        r"groupId\.matches\(\s*'([^']+)'\)",
      ).firstMatch(rules)?.group(1);
      expect(pattern, isNotNull, reason: 'the create rule checks the id');
      for (var i = 0; i < 20; i++) {
        expect(
          RegExp('^$pattern\$').hasMatch(newGroupId().getOrCrash()),
          isTrue,
        );
      }
    });
  });

  group('a group without a name', () {
    test('is called after the other people in it', () {
      expect(groupTitleOf([]), 'Just you');
      expect(groupTitleOf(['ana']), 'ana');
      expect(groupTitleOf(['ana', 'radu']), 'ana and radu');
      expect(groupTitleOf(['ana', 'radu', 'ioana']), 'ana, radu and ioana');
      expect(
        groupTitleOf(['ana', 'radu', 'ioana', 'mihai', 'dan']),
        'ana, radu and 3 others',
      );
    });
  });
}
