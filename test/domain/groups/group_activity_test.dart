import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/groups/group_activity.dart';

void main() {
  test('who is typing reads as a line, and nobody as none', () {
    expect(describeGroupTyping([]), isNull);
    expect(describeGroupTyping(['ana']), 'ana is typing…');
    expect(describeGroupTyping(['ana', 'radu']), 'ana and radu are typing…');
    expect(
      describeGroupTyping(['ana', 'radu', 'bogdan']),
      '3 people are typing…',
    );
  });

  group('who has seen a message', () {
    test('names up to three people, then counts', () {
      expect(describeGroupSeen([], othersInGroup: 5), isNull);
      expect(describeGroupSeen(['ana'], othersInGroup: 5), 'Seen by ana');
      expect(
        describeGroupSeen(['ana', 'radu'], othersInGroup: 5),
        'Seen by ana and radu',
      );
      expect(
        describeGroupSeen(['ana', 'radu', 'bogdan'], othersInGroup: 5),
        'Seen by ana, radu and bogdan',
      );
      expect(
        describeGroupSeen(['a', 'b', 'c', 'd'], othersInGroup: 5),
        'Seen by 4',
      );
    });

    test('says everyone once all the others have', () {
      expect(
        describeGroupSeen(['a', 'b', 'c', 'd'], othersInGroup: 4),
        'Seen by everyone',
      );
      // With one other person, their name says more.
      expect(describeGroupSeen(['ana'], othersInGroup: 1), 'Seen by ana');
    });
  });
}
