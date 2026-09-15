import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_list_time.dart';

void main() {
  // Local times, as the list shows them.
  final now = DateTime(2026, 9, 16, 18, 30); // a Wednesday

  test('today shows the time', () {
    expect(chatListTime(DateTime(2026, 9, 16, 9, 5), now), '09:05');
  });

  test('yesterday says so', () {
    expect(chatListTime(DateTime(2026, 9, 15, 23, 59), now), 'Yesterday');
  });

  test('within the week shows the weekday', () {
    expect(chatListTime(DateTime(2026, 9, 12, 10), now), 'Sat');
    expect(chatListTime(DateTime(2026, 9, 10, 10), now), 'Thu');
  });

  test('before that shows the date, with the year only when it differs', () {
    expect(chatListTime(DateTime(2026, 9, 9, 10), now), '09.09');
    expect(chatListTime(DateTime(2025, 12, 31, 10), now), '31.12.2025');
  });
}
