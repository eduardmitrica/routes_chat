import 'package:flutter/material.dart';

/// Shows the recovery key once, then asks the user to type one group of it
/// back, to make sure it was saved.
class RecoveryKeyConfirmation extends StatefulWidget {
  final String recoveryKey;

  /// Which group, counting from 1, the user must type back.
  final int groupNumber;

  final ValueChanged<String> onConfirmed;

  const RecoveryKeyConfirmation({
    super.key,
    required this.recoveryKey,
    required this.groupNumber,
    required this.onConfirmed,
  });

  @override
  State<RecoveryKeyConfirmation> createState() =>
      _RecoveryKeyConfirmationState();
}

class _RecoveryKeyConfirmationState extends State<RecoveryKeyConfirmation> {
  final _typedGroup = TextEditingController();

  @override
  void dispose() {
    _typedGroup.dispose();
    super.dispose();
  }

  void _confirm() {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onConfirmed(_typedGroup.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Save your recovery key', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Text(
          'If you forget your passphrase, this key is the only way back into '
          'your messages. Write it down or keep it in a password manager. It '
          'is shown only this once, and nobody, including us, can recover it '
          'for you.',
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            widget.recoveryKey.replaceAll('-', ' '),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'monospace',
              letterSpacing: 2,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'To confirm you saved it, type group ${widget.groupNumber} of 8.',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _typedGroup,
          maxLength: 4,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: 'Group ${widget.groupNumber}'),
          onSubmitted: (_) => _confirm(),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _confirm, child: const Text('I saved it')),
      ],
    );
  }
}
