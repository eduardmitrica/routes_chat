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
  _managingGroups();

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

Group _managed({
  List<String> members = const ['uid-alice', 'uid-bob', 'uid-carol'],
  List<String> invited = const ['uid-dan'],
  List<String> admins = const ['uid-alice'],
  bool onlyAdminsAdd = false,
}) => Group(
  id: UniqueId.fromUniqueString('group-2'),
  memberIds: members,
  invitedIds: invited,
  invitedBy: {for (final id in invited) id: 'uid-alice'},
  adminIds: admins,
  onlyAdminsAdd: onlyAdminsAdd,
);

void _managingGroups() {
  group('adding people', () {
    test('any member adds, unless only admins may', () {
      expect(_managed().canAdd('uid-bob'), isTrue);
      expect(_managed().canAdd('uid-dan'), isFalse, reason: 'only invited');
      final strict = _managed(onlyAdminsAdd: true);
      expect(strict.canAdd('uid-bob'), isFalse);
      expect(strict.canAdd('uid-alice'), isTrue);
    });

    test('there is room up to 32, the invited counted', () {
      expect(_managed().room, Group.maxMembers - 4);
    });
  });

  group('taking people out', () {
    test('admins take out anyone else, other admins included', () {
      final group = _managed(admins: ['uid-alice', 'uid-bob']);
      expect(group.canRemove('uid-bob', 'uid-alice'), isTrue);
      expect(group.canRemove('uid-alice', 'uid-dan'), isTrue);
      expect(group.canRemove('uid-carol', 'uid-bob'), isFalse);
      expect(group.canRemove('uid-alice', 'uid-alice'), isFalse);
      expect(group.canRemove('uid-alice', 'uid-zed'), isFalse);
    });
  });

  group('admins', () {
    test('are made from members, and one always remains', () {
      final group = _managed();
      expect(group.canSetAdmin('uid-alice', 'uid-bob', admin: true), isTrue);
      expect(group.canSetAdmin('uid-alice', 'uid-dan', admin: true), isFalse);
      expect(group.canSetAdmin('uid-bob', 'uid-carol', admin: true), isFalse);
      expect(
        group.canSetAdmin('uid-alice', 'uid-alice', admin: false),
        isFalse,
      );
      expect(
        _managed(
          admins: ['uid-alice', 'uid-bob'],
        ).canSetAdmin('uid-alice', 'uid-alice', admin: false),
        isTrue,
      );
    });

    test('the longest member takes over from the only admin who leaves', () {
      expect(_managed().adminsAfterLeaving('uid-alice'), ['uid-bob']);
      expect(
        _managed(
          admins: ['uid-alice', 'uid-carol'],
        ).adminsAfterLeaving('uid-alice'),
        ['uid-carol'],
      );
      expect(_managed().adminsAfterLeaving('uid-bob'), ['uid-alice']);
      expect(
        _managed(
          members: ['uid-alice'],
          invited: [],
        ).adminsAfterLeaving('uid-alice'),
        isEmpty,
      );
    });
  });

  group('history for someone added', () {
    test('copies a day or a week, and nothing for the other choices', () {
      expect(HistoryShare.day.window, const Duration(hours: 24));
      expect(HistoryShare.week.window, const Duration(days: 7));
      expect(HistoryShare.none.window, isNull);
      expect(HistoryShare.all.window, isNull);
    });
  });

  group('the group key', () {
    test('is replaced once people join or leave', () {
      const everyone = ['uid-alice', 'uid-bob'];
      expect(groupKeyOutOfDate(['uid-bob', 'uid-alice'], everyone), isFalse);
      expect(groupKeyOutOfDate(['uid-alice'], everyone), isTrue);
      expect(
        groupKeyOutOfDate(['uid-alice', 'uid-bob', 'uid-carol'], everyone),
        isTrue,
      );
      expect(groupKeyOutOfDate(['uid-alice', 'uid-carol'], everyone), isTrue);
    });
  });
}
