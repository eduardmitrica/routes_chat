import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/application/chats/chat_activity/chat_activity_bloc.dart';
import 'package:routes_chat/presentation/home/chats/widgets/activity_label.dart';

void main() {
  final now = DateTime(2026, 9, 15, 18, 30);

  test('typing comes first, then online', () {
    expect(
      activityLabel(const ChatActivityState(typing: true, online: true), now),
      'typing…',
    );
    expect(activityLabel(const ChatActivityState(online: true), now), 'online');
  });

  test('last seen today, yesterday, or on a date', () {
    String? seen(DateTime at) =>
        activityLabel(ChatActivityState(lastSeen: at), now);

    expect(seen(DateTime(2026, 9, 15, 9, 5)), 'last seen today at 09:05');
    expect(seen(DateTime(2026, 9, 14, 23, 59)), 'last seen yesterday at 23:59');
    expect(seen(DateTime(2026, 9, 2, 8)), 'last seen 02.09.2026');
  });

  test('nothing to show says nothing', () {
    expect(activityLabel(const ChatActivityState(), now), isNull);
  });
}
