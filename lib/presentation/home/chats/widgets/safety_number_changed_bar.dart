import 'package:flutter/material.dart';

/// Above the message box, once the safety number of someone the user had
/// verified is no longer the one they checked.
///
/// Messages still send: the usual reason is that the other person reinstalled
/// or reset their keys. The bar says so and offers to check the new number.
class SafetyNumberChangedBar extends StatelessWidget {
  final String name;
  final VoidCallback onCheck;
  final VoidCallback onDismiss;

  const SafetyNumberChangedBar({
    super.key,
    required this.name,
    required this.onCheck,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$name\'s safety number has changed.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: onCheck,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
              child: const Text('Check'),
            ),
            IconButton(
              tooltip: 'Dismiss',
              onPressed: onDismiss,
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
