import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/infrastructure/core/chunked.dart';

List<int> _numbers(int count) => List.generate(count, (index) => index);

void main() {
  test('nothing to split gives no groups', () {
    // watchUsersWithIds must not issue an `in` query with zero values, which
    // Firestore rejects; an empty id list short-circuits before this anyway.
    expect(chunked(<int>[], 30), isEmpty);
  });

  test('exactly the limit fits in one group', () {
    expect(chunked(_numbers(30), 30).map((group) => group.length), [30]);
  });

  test('one past the limit starts a second group', () {
    expect(chunked(_numbers(31), 30).map((group) => group.length), [30, 1]);
  });

  test('keeps every item, in order', () {
    final items = _numbers(65);
    expect(chunked(items, 30).expand((group) => group), items);
  });

  test('rejects a non-positive size', () {
    expect(() => chunked(_numbers(3), 0), throwsArgumentError);
  });
}
