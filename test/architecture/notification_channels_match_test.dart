import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // The Cloud Functions name a channel for each notification, and the app
  // creates the channels. A channel the phone doesn't have sends the
  // notification to "Miscellaneous", out of reach of the user's settings.
  final notify = File('functions/notify.js').readAsStringSync();
  final activity = File(
    'android/app/src/main/kotlin/com/example/routes_chat/MainActivity.kt',
  ).readAsStringSync();
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync();

  final sent = {
    for (final match in RegExp(
      r'CHANNELS = \{([^}]*)\}',
    ).firstMatch(notify)!.group(1)!.split(','))
      RegExp(r'"([^"]+)"').firstMatch(match)!.group(1)!,
  };
  final created = {
    for (final match in RegExp(
      r'NotificationChannel\(\s*"([^"]+)"',
    ).allMatches(activity))
      match.group(1)!,
  };

  test('every channel the functions send to exists on the phone', () {
    expect(sent, isNotEmpty);
    expect(created, containsAll(sent));
  });

  test('notifications without a channel go to one the app creates', () {
    final fallback = RegExp(
      r'default_notification_channel_id"\s+android:value="([^"]+)"',
    ).firstMatch(manifest);

    expect(fallback, isNotNull);
    expect(created, contains(fallback!.group(1)));
  });
}
