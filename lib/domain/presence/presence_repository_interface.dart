import '../core/value_objects.dart';
import 'presence.dart';

/// Who is typing in a chat, and who is in the app.
///
/// Both are metadata about people, not content: they say when someone types
/// or uses the app, never what. Writes never throw; they are best effort.
abstract interface class IPresenceRepository {
  /// Says the signed-in user is typing in [chatId] right now.
  Future<void> startTyping(UniqueId chatId);

  /// Says the signed-in user stopped typing in [chatId].
  Future<void> stopTyping(UniqueId chatId);

  /// When [userId] last said they were typing in [chatId], by the server's
  /// clock; null when they are not typing. Emits nothing it may not read.
  Stream<DateTime?> watchTyping(UniqueId chatId, UniqueId userId);

  /// Says the signed-in user's app is on screen.
  Future<void> reportOnline();

  /// Says the signed-in user's app left the screen.
  Future<void> reportOffline();

  /// Deletes what others can see of [userId]'s presence.
  Future<void> clearPresence(String userId);

  /// [userId]'s presence, or null when there is none or it may not be read,
  /// such as when they are not friends.
  Stream<Presence?> watchPresence(UniqueId userId);
}
