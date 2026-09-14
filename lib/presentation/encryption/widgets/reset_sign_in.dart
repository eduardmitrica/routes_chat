import 'package:flutter/material.dart';
import 'package:routes_chat/domain/authentication/sign_in_method.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';

/// Asks the user to sign in again right before their keys are reset, so a
/// device someone left signed in cannot reset them.
class ResetSignIn extends StatefulWidget {
  final SignInMethod method;
  final bool isWorking;
  final ValueChanged<Password> onPassword;
  final VoidCallback onGoogle;
  final VoidCallback onCancel;

  const ResetSignIn({
    super.key,
    required this.method,
    required this.isWorking,
    required this.onPassword,
    required this.onGoogle,
    required this.onCancel,
  });

  @override
  State<ResetSignIn> createState() => _ResetSignInState();
}

class _ResetSignInState extends State<ResetSignIn> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  var _hidden = true;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onPassword(Password(_password.text));
  }

  @override
  Widget build(BuildContext context) {
    final withPassword = widget.method == SignInMethod.emailAndPassword;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Confirm it is you',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            withPassword
                ? 'Enter the password you sign in with. Your keys are reset '
                      'right after.'
                : 'Sign in with Google again, with the account you use here. '
                      'Your keys are reset right after.',
          ),
          const SizedBox(height: 24),
          if (withPassword) ...[
            TextFormField(
              controller: _password,
              enabled: !widget.isWorking,
              obscureText: _hidden,
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Account password',
                suffixIcon: IconButton(
                  tooltip: _hidden ? 'Show password' : 'Hide password',
                  icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _hidden = !_hidden),
                ),
              ),
              validator: (input) =>
                  (input ?? '').isEmpty ? 'Enter your password' : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
          ],
          if (widget.isWorking) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text(
              'Resetting your keys. This takes a few seconds.',
              textAlign: TextAlign.center,
            ),
          ] else if (withPassword)
            FilledButton(
              onPressed: _submit,
              child: const Text('Confirm and reset'),
            )
          else
            FilledButton(
              onPressed: widget.onGoogle,
              child: const Text('Sign in with Google and reset'),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.isWorking ? null : widget.onCancel,
            child: const Text('Cancel reset'),
          ),
        ],
      ),
    );
  }
}
