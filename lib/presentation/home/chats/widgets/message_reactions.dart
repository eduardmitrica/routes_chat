import 'package:flutter/material.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message_reaction.dart';

/// The reactions to a message, under its bubble: each emoji once, the most
/// common first, and how many people reacted when more than one did.
class MessageReactions extends StatelessWidget {
  /// The most different emojis shown; the count covers the rest.
  static const maxShown = 3;

  final KtList<MessageReaction> reactions;

  /// Shows who reacted with what.
  final VoidCallback onTap;

  const MessageReactions({
    super.key,
    required this.reactions,
    required this.onTap,
  });

  /// Each emoji once, the most common first, and of those equally common
  /// the one reacted with first.
  static List<String> emojisByCount(KtList<MessageReaction> reactions) {
    final counts = <String, int>{};
    for (final reaction in reactions.iter) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
    }
    // A map keeps the order its keys were added in.
    final firstSeen = {
      for (final (index, emoji) in counts.keys.indexed) emoji: index,
    };
    return counts.keys.toList()..sort((a, b) {
      final byCount = counts[b]!.compareTo(counts[a]!);
      return byCount != 0 ? byCount : firstSeen[a]! - firstSeen[b]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final emojis = emojisByCount(reactions);
    final total = reactions.size;
    return Semantics(
      button: true,
      label:
          '${total == 1 ? '1 reaction' : '$total reactions'}: '
          '${emojis.join(' ')}',
      hint: 'Shows who reacted',
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainerHigh,
        shape: StadiumBorder(side: BorderSide(color: scheme.surface, width: 2)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emojis.take(maxShown).join(),
                  style: theme.textTheme.bodyMedium,
                ),
                if (total > 1) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$total',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
