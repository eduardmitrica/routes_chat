import 'package:equatable/equatable.dart';

import '../../core/value_objects.dart';

/// One person's reaction to a message. Each person has at most one per
/// message; picking another replaces it.
///
/// The emoji travels encrypted with the chat's key, so the server knows that
/// someone reacted, not with what. See docs/e2ee.md.
final class MessageReaction extends Equatable {
  /// The most UTF-8 bytes a reaction's emoji may take. The longest emoji,
  /// such as a couple with two skin tones, take about 35.
  static const maxEmojiBytes = 64;

  final UniqueId messageId;
  final UniqueId userId;
  final String emoji;

  const MessageReaction({
    required this.messageId,
    required this.userId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [messageId, userId, emoji];

  /// The ids only: the emoji is decrypted content, which does not belong in
  /// logs.
  @override
  String toString() =>
      'MessageReaction(${messageId.getOrCrash()}, ${userId.getOrCrash()})';
}
