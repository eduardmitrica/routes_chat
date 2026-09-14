import 'package:flutter/material.dart';
import 'package:routes_chat/domain/core/failures.dart';
import 'package:routes_chat/domain/encryption/value_objects.dart';

/// Asks for a passphrase: to set one up, to unlock, or to replace one.
class PassphraseForm extends StatefulWidget {
  final String title;
  final String explanation;
  final String buttonLabel;

  /// Whether to ask for the passphrase twice, for a new one.
  final bool askForConfirmation;

  final bool isWorking;
  final String workingMessage;
  final ValueChanged<Passphrase> onSubmitted;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const PassphraseForm({
    super.key,
    required this.title,
    required this.explanation,
    required this.buttonLabel,
    required this.askForConfirmation,
    required this.isWorking,
    required this.workingMessage,
    required this.onSubmitted,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  State<PassphraseForm> createState() => _PassphraseFormState();
}

class _PassphraseFormState extends State<PassphraseForm> {
  final _formKey = GlobalKey<FormState>();
  final _passphrase = TextEditingController();
  final _confirmation = TextEditingController();
  var _hidden = true;

  @override
  void dispose() {
    _passphrase.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  String? _validatePassphrase(String? input) =>
      Passphrase(input ?? '').value.fold(
        (failure) => switch (failure) {
          PassphraseTooShort(:final minimumLength) =>
            'Use at least $minimumLength characters',
          ExceedingLength() =>
            'Use at most ${Passphrase.maximumLength} characters',
          _ => 'This passphrase cannot be used',
        },
        (_) => null,
      );

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSubmitted(Passphrase(_passphrase.text));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(widget.title, style: textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(widget.explanation),
          const SizedBox(height: 24),
          TextFormField(
            controller: _passphrase,
            enabled: !widget.isWorking,
            obscureText: _hidden,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: widget.askForConfirmation
                ? const [AutofillHints.newPassword]
                : const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Passphrase',
              helperText: widget.askForConfirmation
                  ? 'At least ${Passphrase.minimumLength} characters. A few '
                        'unrelated words work well.'
                  : null,
              suffixIcon: IconButton(
                tooltip: _hidden ? 'Show passphrase' : 'Hide passphrase',
                icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _hidden = !_hidden),
              ),
            ),
            validator: _validatePassphrase,
            onFieldSubmitted: (_) =>
                widget.askForConfirmation ? null : _submit(),
          ),
          if (widget.askForConfirmation) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmation,
              enabled: !widget.isWorking,
              obscureText: _hidden,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(labelText: 'Repeat passphrase'),
              validator: (input) => input == _passphrase.text
                  ? null
                  : 'The passphrases do not match',
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
          const SizedBox(height: 24),
          if (widget.isWorking) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(widget.workingMessage, textAlign: TextAlign.center),
          ] else
            ElevatedButton(onPressed: _submit, child: Text(widget.buttonLabel)),
          if (widget.secondaryActionLabel != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.isWorking ? null : widget.onSecondaryAction,
              child: Text(widget.secondaryActionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
