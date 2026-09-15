import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

import '../../helpers/safety_fakes.dart';

void main() {
  final noon = DateTime.utc(2026, 9, 16, 12);
  final bob = UniqueId.fromUniqueString('uid-bob');
  final carol = UniqueId.fromUniqueString('uid-carol');

  test('while someone is blocked, what they send from then on is hidden', () {
    final blocks = blocking('uid-bob', since: noon);

    expect(blocks.isBlocked(bob), isTrue);
    expect(blocks.hides(bob, noon), isTrue);
    expect(blocks.hides(bob, noon.add(const Duration(days: 3))), isTrue);
    expect(
      blocks.hides(bob, noon.subtract(const Duration(seconds: 1))),
      isFalse,
    );
  });

  test('after unblocking, what they sent while blocked stays hidden', () {
    final blocks = blocking(
      'uid-bob',
      earlier: [(from: noon, to: noon.add(const Duration(hours: 1)))],
    );

    expect(blocks.isBlocked(bob), isFalse);
    expect(blocks.blockedUserIds, isEmpty);
    expect(blocks.hides(bob, noon.add(const Duration(minutes: 30))), isTrue);
    expect(blocks.hides(bob, noon.add(const Duration(hours: 1))), isFalse);
    expect(
      blocks.hides(bob, noon.subtract(const Duration(minutes: 1))),
      isFalse,
    );
  });

  test('something not yet dated is hidden only while they are blocked', () {
    expect(blocking('uid-bob', since: noon).hides(bob, null), isTrue);
    expect(
      blocking(
        'uid-bob',
        earlier: [(from: noon, to: noon.add(const Duration(hours: 1)))],
      ).hides(bob, null),
      isFalse,
    );
  });

  test('nobody else is affected', () {
    final blocks = blocking('uid-bob', since: noon);

    expect(blocks.isBlocked(carol), isFalse);
    expect(blocks.hides(carol, noon.add(const Duration(hours: 1))), isFalse);
    expect(blocks.blockedUserIds, [bob]);
  });

  test('who is blocked stays out of logs', () {
    expect(blocking('uid-bob', since: noon).toString(), isNot(contains('bob')));
  });
}
