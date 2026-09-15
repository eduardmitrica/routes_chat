import 'package:routes_chat/domain/core/value_objects.dart';

/// The chat on screen, if any, so a notification about it is not shown on top
/// of it, and tapping one does not open it a second time.
abstract final class OpenChat {
  /// Open chats, the one on screen last. A chat opened from a notification
  /// can sit on top of another.
  static final _open = <String>[];

  /// The id of the chat on screen; null when none is.
  static String? get id => _open.isEmpty ? null : _open.last;

  static void opened(UniqueId chatId) => _open.add(chatId.getOrCrash());

  static void closed(UniqueId chatId) => _open.remove(chatId.getOrCrash());
}
