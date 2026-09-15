import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/safety/firestore_safety_repository.dart';

void main() {
  final noon = DateTime.utc(2026, 9, 16, 12);

  test('a stored block reads as it was stored', () {
    final record = FirestoreSafetyRepository.recordFrom('uid-bob', {
      'blockedSince': Timestamp.fromDate(noon),
      'earlier': [
        {
          'from': Timestamp.fromDate(noon.subtract(const Duration(days: 2))),
          'to': Timestamp.fromDate(noon.subtract(const Duration(days: 1))),
        },
      ],
    });

    expect(record.userId.getOrCrash(), 'uid-bob');
    expect(record.blockedSince, noon.toLocal());
    expect(
      record.earlier.single.from,
      noon.subtract(const Duration(days: 2)).toLocal(),
    );
  });

  test('a block just made on this phone counts from now', () {
    final before = DateTime.now();

    final record = FirestoreSafetyRepository.recordFrom('uid-bob', {
      'blockedSince': null,
    });

    expect(record.isBlocked, isTrue);
    expect(record.blockedSince!.isBefore(before), isFalse);
  });

  test(
    'an unblocked person is not blocked, and odd entries are passed over',
    () {
      final record = FirestoreSafetyRepository.recordFrom('uid-bob', {
        'earlier': [
          'yesterday',
          {'from': Timestamp.fromDate(noon)},
        ],
      });

      expect(record.isBlocked, isFalse);
      expect(record.earlier, isEmpty);
    },
  );
}
