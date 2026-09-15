/// When a chat's last message was sent, as the chat list shows it, as of
/// [now]: the time today, "Yesterday", the weekday within the last week, and
/// the date before that.
String chatListTime(DateTime sentAt, DateTime now) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final sent = sentAt.toLocal();
  final localNow = now.toLocal();
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final day = DateTime(sent.year, sent.month, sent.day);
  // In hours, rounded: a day across a clock change is 23 or 25 hours long.
  final daysAgo = (today.difference(day).inHours / 24).round();
  return switch (daysAgo) {
    <= 0 => '${twoDigits(sent.hour)}:${twoDigits(sent.minute)}',
    1 => 'Yesterday',
    < 7 => weekdays[sent.weekday - 1],
    _ when sent.year == localNow.year =>
      '${twoDigits(sent.day)}.${twoDigits(sent.month)}',
    _ => '${twoDigits(sent.day)}.${twoDigits(sent.month)}.${sent.year}',
  };
}
