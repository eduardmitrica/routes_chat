import 'package:equatable/equatable.dart';

import '../core/value_objects.dart';

/// A push notification the app understands. It never carries message text,
/// which is end-to-end encrypted; see functions/notify.js.
sealed class AppNotification extends Equatable {
  /// Who it is from, as the notification names them.
  final String senderName;

  const AppNotification(this.senderName);
}

/// A new message in [chatId].
final class MessageNotification extends AppNotification {
  final UniqueId chatId;

  const MessageNotification({required this.chatId, required String senderName})
    : super(senderName);

  @override
  List<Object?> get props => [chatId, senderName];
}

/// A first message in [chatId] from someone who is not a friend, waiting to
/// be accepted or deleted.
final class MessageRequestNotification extends AppNotification {
  final UniqueId chatId;

  const MessageRequestNotification({
    required this.chatId,
    required String senderName,
  }) : super(senderName);

  @override
  List<Object?> get props => [chatId, senderName];
}

/// A new friend request.
final class FriendRequestNotification extends AppNotification {
  const FriendRequestNotification({required String senderName})
    : super(senderName);

  @override
  List<Object?> get props => [senderName];
}

/// Notifications as they reach the app.
abstract interface class INotificationEvents {
  /// Notifications that arrived while the app was on screen, which the phone
  /// does not show by itself.
  Stream<AppNotification> get received;

  /// Notifications tapped while the app was running in the background.
  Stream<AppNotification> get opened;

  /// The notification tapped to start the app, if it was; null otherwise.
  /// Only the first call can return it.
  Future<AppNotification?> openedAppFrom();
}
