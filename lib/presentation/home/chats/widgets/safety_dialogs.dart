import 'package:flutter/material.dart';

import '../../../../domain/safety/safety_repository_interface.dart';
import '../../../core/theme/app_theme.dart';

/// Asks before blocking [name]: blocking is silent, and ends the friendship.
Future<bool> confirmBlock(BuildContext context, String name) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block $name?'),
        content: Text(
          '$name won\'t be able to reach you, and won\'t be told. You\'ll no '
          'longer be friends. Anything they send while blocked stays hidden, '
          'even if you unblock them later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: AppTheme.destructiveButton(Theme.of(context).colorScheme),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Block'),
          ),
        ],
      ),
    ) ??
    false;

/// What the user chose to report.
final class ReportChoice {
  final ReportReason reason;

  /// Whether the last messages of the chat go with the report.
  final bool shareMessages;
  final bool alsoBlock;

  const ReportChoice({
    required this.reason,
    required this.shareMessages,
    required this.alsoBlock,
  });
}

/// Asks why [name] is reported, whether to share the chat's last messages
/// (only when [canShareMessages]), and whether to block them too (unless
/// [alreadyBlocked]). Null when cancelled.
Future<ReportChoice?> askReport(
  BuildContext context, {
  required String name,
  required bool canShareMessages,
  required bool alreadyBlocked,
}) => showDialog<ReportChoice>(
  context: context,
  builder: (context) => _ReportDialog(
    name: name,
    canShareMessages: canShareMessages,
    alreadyBlocked: alreadyBlocked,
  ),
);

class _ReportDialog extends StatefulWidget {
  final String name;
  final bool canShareMessages;
  final bool alreadyBlocked;

  const _ReportDialog({
    required this.name,
    required this.canShareMessages,
    required this.alreadyBlocked,
  });

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  ReportReason? _reason;
  var _shareMessages = false;
  late var _alsoBlock = !widget.alreadyBlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reason = _reason;
    return AlertDialog(
      title: Text('Report ${widget.name}'),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Why are you reporting them?',
            style: theme.textTheme.bodyMedium,
          ),
          RadioGroup<ReportReason>(
            groupValue: reason,
            onChanged: (value) => setState(() => _reason = value),
            child: Column(
              children: [
                for (final option in ReportReason.values)
                  RadioListTile<ReportReason>(
                    contentPadding: EdgeInsets.zero,
                    value: option,
                    title: Text(option.label),
                  ),
              ],
            ),
          ),
          if (widget.canShareMessages)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _shareMessages,
              onChanged: (value) =>
                  setState(() => _shareMessages = value ?? false),
              title: Text(
                'Include the last ${ReportedMessage.maxPerReport} messages',
              ),
              subtitle: const Text(
                'Chats are end-to-end encrypted, so nobody else can read them. '
                'If you tick this, these messages are shared in readable form '
                'with whoever reviews the report.',
              ),
            ),
          if (!widget.alreadyBlocked)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _alsoBlock,
              onChanged: (value) => setState(() => _alsoBlock = value ?? false),
              title: Text('Also block ${widget.name}'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: reason == null
              ? null
              : () => Navigator.of(context).pop(
                  ReportChoice(
                    reason: reason,
                    shareMessages: widget.canShareMessages && _shareMessages,
                    alsoBlock: !widget.alreadyBlocked && _alsoBlock,
                  ),
                ),
          child: const Text('Report'),
        ),
      ],
    );
  }
}

/// In place of the message box, in a chat with someone the user blocked.
class BlockedChatBar extends StatelessWidget {
  final String name;
  final VoidCallback onUnblock;

  const BlockedChatBar({
    super.key,
    required this.name,
    required this.onUnblock,
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
                'You blocked $name. They can\'t reach you, and they aren\'t '
                'told.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(onPressed: onUnblock, child: const Text('Unblock')),
            ],
          ),
        ),
      ),
    );
  }
}
