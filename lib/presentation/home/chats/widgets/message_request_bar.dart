import 'package:flutter/material.dart';

/// In place of the message box, in a chat from someone who is not a friend:
/// take it, clear it, or block them. Until it is accepted, the app tells
/// them nothing: no typing, no "Seen".
class MessageRequestBar extends StatelessWidget {
  final String name;
  final VoidCallback onAccept;
  final VoidCallback onDelete;
  final VoidCallback onBlock;

  const MessageRequestBar({
    super.key,
    required this.name,
    required this.onAccept,
    required this.onDelete,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$name wants to send you messages. They won\'t know whether '
                'you\'ve read them until you accept.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: onBlock, child: const Text('Block')),
                  TextButton(onPressed: onDelete, child: const Text('Delete')),
                  FilledButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
