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

  test('a message request notification opens the requests', () {
    expect(
      appNotificationFrom({
        'type': 'messageRequest',
        'chatId': 'uid-alice_uid-bob',
      }, title: 'eduard'),
      MessageRequestNotification(chatId: chatId, senderName: 'eduard'),
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
    expect(appNotificationFrom({'type': 'messageRequest'}), isNull);
    expect(appNotificationFrom({'type': 'campaign'}), isNull);
    expect(appNotificationFrom({}), isNull);
  });

  group('groups', () {
    const groupId = 'group-00000000-0000-4000-8000-000000000000';

    test('a group message opens the group', () {
      expect(
        appNotificationFrom({
          'type': 'groupMessage',
          'groupId': groupId,
        }, title: 'ana'),
        GroupMessageNotification(
          groupId: UniqueId.fromUniqueString(groupId),
          senderName: 'ana',
        ),
      );
    });

    test('being added names who added the user', () {
      expect(
        appNotificationFrom({
          'type': 'groupInvitation',
          'groupId': groupId,
        }, title: 'ana'),
        GroupInvitationNotification(
          groupId: UniqueId.fromUniqueString(groupId),
          senderName: 'ana',
        ),
      );
    });

    test('a group notification without a group id is ignored', () {
      expect(appNotificationFrom({'type': 'groupMessage'}), isNull);
      expect(
        appNotificationFrom({
          'type': 'groupMessage',
          'groupId': 'uid-alice_uid-bob',
        }),
        isNull,
      );
    });
  });
}
