import 'package:flutter/material.dart';
import 'package:routes_chat/domain/encryption/value_objects.dart';

/// Asks for the recovery key, for a user who forgot the passphrase.
class RecoveryKeyForm extends StatefulWidget {
  final bool isWorking;
  final ValueChanged<RecoveryKeyInput> onSubmitted;
  final VoidCallback onBack;

  /// For a user who has neither the passphrase nor the recovery key.
  final VoidCallback onLostRecoveryKey;

  const RecoveryKeyForm({
    super.key,
    required this.isWorking,
    required this.onSubmitted,
    required this.onBack,
    required this.onLostRecoveryKey,
  });

  @override
  State<RecoveryKeyForm> createState() => _RecoveryKeyFormState();
}

class _RecoveryKeyFormState extends State<RecoveryKeyForm> {
  final _formKey = GlobalKey<FormState>();
  final _recoveryKey = TextEditingController();

  @override
  void dispose() {
    _recoveryKey.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSubmitted(RecoveryKeyInput(_recoveryKey.text));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Use your recovery key',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Enter the recovery key you saved when you set up encryption. '
            'Spaces and dashes do not matter.',
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _recoveryKey,
            enabled: !widget.isWorking,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            maxLines: 2,
            minLines: 1,
            decoration: const InputDecoration(
              labelText: 'Recovery key',
              hintText: 'XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX',
            ),
            validator: (input) => RecoveryKeyInput(input ?? '').value.fold(
              (_) => 'A recovery key has 32 letters and digits (2 to 7)',
              (_) => null,
            ),
          ),
          const SizedBox(height: 24),
          if (widget.isWorking) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Unlocking…', textAlign: TextAlign.center),
          ] else
            FilledButton(
              onPressed: _submit,
              child: const Text('Unlock with recovery key'),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.isWorking ? null : widget.onBack,
            child: const Text('Back to passphrase'),
          ),
          TextButton(
            onPressed: widget.isWorking ? null : widget.onLostRecoveryKey,
            child: const Text('I lost my recovery key too'),
          ),
        ],
      ),
    );
  }
}
