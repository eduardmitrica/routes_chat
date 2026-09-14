import 'package:kt_dart/collection.dart';

import 'message.dart';

/// Some of a chat's messages, oldest first.
final class MessagePage {
  final KtList<Message> messages;

  /// Whether nothing older exists: the chat's first message is in [messages],
  /// or the chat has no messages before them.
  final bool reachesStart;

  const MessagePage(this.messages, {required this.reachesStart});
}
