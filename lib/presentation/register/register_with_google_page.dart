import 'package:flutter/material.dart';

import 'package:routes_chat/presentation/encryption/encryption_gate_page.dart';

import '../../domain/shared/user/value_objects.dart';

class RegisterWithGooglePage extends StatelessWidget {
  static const registerWithGooglePageRoute =
      '/auth/register/register-with-google';

  const RegisterWithGooglePage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailAddress =
        ModalRoute.of(context)!.settings.arguments as EmailAddress;

    return Scaffold(
      appBar: AppBar(title: const Text('Register with Google')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You\'re registered as ${emailAddress.getOrCrash()}. We\'ve '
              'given you a placeholder photo and a username. You can change '
              'both on your profile.',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  EncryptionGatePage.encryptionGatePageRoute,
                );
              },
              child: const Text('Continue to the chats page'),
            ),
          ],
        ),
      ),
    );
  }
}
