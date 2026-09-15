import 'package:flutter/material.dart';

/// The emojis the user reacts with most, one tap each, and a button for any
/// other. The user's reaction stands out, and tapping it takes it back.
///
/// Until the user reacts or sends an emoji there are no favourites, and only
/// the button shows: no emojis are chosen for them.
class ReactionBar extends StatelessWidget {
  /// The emojis the user uses most, most used first.
  final List<String> favourites;

  /// The user's reaction to the message, if they reacted.
  final String? current;

  final ValueChanged<String> onPicked;

  /// Opens every emoji to choose from.
  final VoidCallback onMore;

  const ReactionBar({
    super.key,
    required this.favourites,
    required this.current,
    required this.onPicked,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final current = this.current;
    final emojis = [
      if (current != null && !favourites.contains(current)) current,
      ...favourites,
    ];
    if (emojis.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onMore,
            icon: const Icon(Icons.add_reaction_outlined),
            label: const Text('React'),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final emoji in emojis)
            _EmojiButton(
              emoji: emoji,
              selected: emoji == current,
              onTap: () => onPicked(emoji),
            ),
          IconButton(
            tooltip: 'More reactions',
            onPressed: onMore,
            icon: const Icon(Icons.add_reaction_outlined),
          ),
        ],
      ),
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _EmojiButton({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? 'Remove your reaction $emoji' : 'React with $emoji',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: selected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: 48,
              child: Center(
                child: Text(emoji, style: theme.textTheme.headlineSmall),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
