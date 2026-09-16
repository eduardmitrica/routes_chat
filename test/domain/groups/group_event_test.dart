import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/domain/groups/group_event.dart';
import 'package:routes_chat/domain/groups/group_profile.dart';

String _say(GroupEvent event) => describeGroupEvent(
  event,
  nameOf: (id) => {'uid-ana': 'ana', 'uid-radu': 'radu'}[id] ?? '?',
  myId: 'uid-me',
);

void main() {
  group('an event reads as a line', () {
    test('about someone', () {
      expect(
        _say(
          const GroupEvent(
            type: GroupEventType.added,
            byId: 'uid-ana',
            subjectId: 'uid-radu',
          ),
        ),
        'ana added radu',
      );
      expect(
        _say(
          const GroupEvent(
            type: GroupEventType.removed,
            byId: 'uid-me',
            subjectId: 'uid-radu',
          ),
        ),
        'You took radu out of the group',
      );
      expect(
        _say(
          const GroupEvent(
            type: GroupEventType.adminAdded,
            byId: 'uid-ana',
            subjectId: 'uid-me',
          ),
        ),
        'ana made you an admin',
      );
      expect(
        _say(
          const GroupEvent(
            type: GroupEventType.adminRemoved,
            byId: 'uid-ana',
            subjectId: 'uid-ana',
          ),
        ),
        'ana stopped being an admin',
      );
    });

    test('about the group', () {
      expect(
        _say(const GroupEvent(type: GroupEventType.created, byId: 'uid-ana')),
        'ana started the group',
      );
      expect(
        _say(const GroupEvent(type: GroupEventType.joined, byId: 'uid-me')),
        'You joined',
      );
      expect(
        _say(const GroupEvent(type: GroupEventType.renamed, byId: 'uid-radu')),
        'radu changed the group name',
      );
      expect(
        _say(
          const GroupEvent(
            type: GroupEventType.onlyAdminsAdd,
            byId: 'uid-ana',
            on: true,
          ),
        ),
        'ana let only admins add people',
      );
      expect(
        _say(
          const GroupEvent(
            type: GroupEventType.onlyAdminsAdd,
            byId: 'uid-ana',
            on: false,
          ),
        ),
        'ana let everyone add people',
      );
    });

    test('never says what anyone wrote, and stays out of the logs', () {
      const event = GroupEvent(
        type: GroupEventType.added,
        byId: 'uid-ana',
        subjectId: 'uid-radu',
      );
      expect(event.toString(), 'GroupEvent(added)');
    });
  });

  test('every type reads back from how it is stored', () {
    for (final type in GroupEventType.values) {
      expect(GroupEventType.fromStored(type.stored), type);
    }
    expect(GroupEventType.fromStored('madeUp'), isNull);
  });

  test('firestore.rules know the same events, and which have a subject', () {
    final rules = File('firestore.rules').readAsStringSync();
    for (final type in GroupEventType.values) {
      expect(rules, contains("type == '${type.stored}'"), reason: type.stored);
    }
    final withSubject = RegExp(
      r"event\.type in \[([^\]]*)\]",
    ).firstMatch(rules)?.group(1);
    expect(withSubject, isNotNull);
    expect(
      RegExp(
        "'([^']+)'",
      ).allMatches(withSubject!).map((m) => m.group(1)).toSet(),
      {
        for (final type in GroupEventType.values)
          if (type.hasSubject) type.stored,
      },
    );
  });

  group('a group\'s name', () {
    test('is trimmed, and refused when too long', () {
      expect(groupNameOf('  Drumeție  '), 'Drumeție');
      expect(groupNameOf('a' * GroupProfile.maxNameLength), isNotNull);
      expect(groupNameOf('a' * (GroupProfile.maxNameLength + 1)), isNull);
    });

    test('names the group, or else its members do', () {
      final group = Group(
        id: UniqueId.fromUniqueString('group-1'),
        memberIds: const ['uid-me', 'uid-ana'],
        invitedIds: const [],
        invitedBy: const {},
        adminIds: const ['uid-me'],
      );
      expect(group.titleWith(['ana']), 'ana');
      final named = Group(
        id: group.id,
        memberIds: group.memberIds,
        invitedIds: group.invitedIds,
        invitedBy: group.invitedBy,
        adminIds: group.adminIds,
        profile: const GroupProfile(name: 'Drumeție'),
      );
      expect(named.titleWith(['ana']), 'Drumeție');
    });

    test('and its photo stay out of the logs', () {
      const profile = GroupProfile(name: 'Secret', photo: [1, 2, 3]);
      expect(profile.toString(), isNot(contains('Secret')));
    });
  });
}
