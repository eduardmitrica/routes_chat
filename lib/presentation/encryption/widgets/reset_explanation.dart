import 'package:flutter/material.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';

/// Explains what resetting the encryption keys means, and has the user
/// acknowledge it before going on.
class ResetExplanation extends StatefulWidget {
  final VoidCallback onConfirmed;
  final VoidCallback onBack;

  const ResetExplanation({
    super.key,
    required this.onConfirmed,
    required this.onBack,
  });

  @override
  State<ResetExplanation> createState() => _ResetExplanationState();
}

class _ResetExplanationState extends State<ResetExplanation> {
  var _understood = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Reset your encryption keys?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        const Text(
          'Without your passphrase or recovery key, nobody can unlock your '
          'current keys, including us. You can replace them with new ones and '
          'keep chatting, but:',
        ),
        const SizedBox(height: 12),
        const _Point(
          'Messages from before the reset become unreadable for you, on '
          'every device, for good.',
        ),
        const _Point(
          'The people you chat with keep their messages, and see that you '
          'reset your keys.',
        ),
        const _Point(
          'You will choose a new passphrase, sign in again to confirm it is '
          'you, and get a new recovery key.',
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _understood,
          onChanged: (value) => setState(() => _understood = value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'I understand that my earlier messages cannot be recovered',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          // Earlier messages become unreadable for good.
          style: AppTheme.destructiveButton(Theme.of(context).colorScheme),
          onPressed: _understood ? widget.onConfirmed : null,
          child: const Text('Reset my keys'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onBack,
          child: const Text('Back to recovery key'),
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  final String text;

  const _Point(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
