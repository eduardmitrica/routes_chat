import 'package:routes_chat/application/chats/chat_activity/chat_activity_bloc.dart';

/// "typing…", "online", or when the other person was last seen, as of [now];
/// null when there is nothing to show.
String? activityLabel(ChatActivityState state, DateTime now) {
  if (state.typing) return 'typing…';
  if (state.online) return 'online';
  final lastSeen = state.lastSeen?.toLocal();
  if (lastSeen == null) return null;

  String twoDigits(int number) => number.toString().padLeft(2, '0');
  final localNow = now.toLocal();
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final day = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);
  // In hours, rounded: a day across a clock change is 23 or 25 hours long.
  final daysAgo = (today.difference(day).inHours / 24).round();
  final time = '${twoDigits(lastSeen.hour)}:${twoDigits(lastSeen.minute)}';
  return switch (daysAgo) {
    <= 0 => 'last seen today at $time',
    1 => 'last seen yesterday at $time',
    _ => 'last seen ${twoDigits(day.day)}.${twoDigits(day.month)}.${day.year}',
  };
}
