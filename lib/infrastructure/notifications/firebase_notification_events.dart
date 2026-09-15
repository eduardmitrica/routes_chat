import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/core/value_objects.dart';
import '../../domain/notifications/app_notification.dart';

/// The notification [data] and [title] from functions/notify.js as the app
/// understands them; null for anything else.
///
/// Notifications sent before the `type` field existed carry only a chat id,
/// and are messages.
AppNotification? appNotificationFrom(
  Map<String, dynamic> data, {
  String? title,
}) {
  final senderName = title == null || title.trim().isEmpty ? 'Someone' : title;
  switch (data['type']) {
    case 'friendRequest':
      return FriendRequestNotification(senderName: senderName);
    case 'message' || null:
      final chatId = data['chatId'];
      return chatId is String && chatId.isNotEmpty
          ? MessageNotification(
              chatId: UniqueId.fromUniqueString(chatId),
              senderName: senderName,
            )
          : null;
  }
  return null;
}

class FirebaseNotificationEvents implements INotificationEvents {
  final FirebaseMessaging _messaging;

  const FirebaseNotificationEvents(this._messaging);

  static AppNotification? _from(RemoteMessage message) =>
      appNotificationFrom(message.data, title: message.notification?.title);

  @override
  Stream<AppNotification> get received =>
      FirebaseMessaging.onMessage.map(_from).whereType<AppNotification>();

  @override
  Stream<AppNotification> get opened => FirebaseMessaging.onMessageOpenedApp
      .map(_from)
      .whereType<AppNotification>();

  @override
  Future<AppNotification?> openedAppFrom() async {
    try {
      final message = await _messaging.getInitialMessage();
      return message == null ? null : _from(message);
    } on Exception catch (exception) {
      debugPrint('Opening notification not read: ${exception.runtimeType}');
      return null;
    }
  }
}
