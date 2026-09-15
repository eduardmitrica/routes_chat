import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/notifications/app_notification.dart';
import 'package:routes_chat/infrastructure/notifications/firebase_notification_events.dart';

void main() {
  final chatId = UniqueId.fromUniqueString('uid-alice_uid-bob');

  test('a message notification opens its chat', () {
    expect(
      appNotificationFrom({
        'type': 'message',
        'chatId': 'uid-alice_uid-bob',
      }, title: 'eduard'),
      MessageNotification(chatId: chatId, senderName: 'eduard'),
    );
  });

  test('a notification from before types existed is a message', () {
    expect(
      appNotificationFrom({'chatId': 'uid-alice_uid-bob'}, title: 'eduard'),
      MessageNotification(chatId: chatId, senderName: 'eduard'),
    );
  });

  test('a friend request notification', () {
    expect(
      appNotificationFrom({'type': 'friendRequest'}, title: 'eduard'),
      const FriendRequestNotification(senderName: 'eduard'),
    );
  });

  test('a notification without a title names someone', () {
    expect(
      appNotificationFrom({'type': 'friendRequest'}),
      const FriendRequestNotification(senderName: 'Someone'),
    );
  });

  test('anything else is not understood', () {
    expect(appNotificationFrom({'type': 'message'}), isNull);
    expect(appNotificationFrom({'type': 'campaign'}), isNull);
    expect(appNotificationFrom({}), isNull);
  });
}
