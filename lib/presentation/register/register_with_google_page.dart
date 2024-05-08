import 'package:flutter/material.dart';

import 'package:routes_chat/domain/authentication/value_objects.dart';
import 'package:routes_chat/presentation/home/home_page.dart';

class RegisterWithGooglePage extends StatelessWidget {
  static const registerWithGooglePageRoute =
      '/auth/register/register-with-google';

  const RegisterWithGooglePage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailAddress =
        ModalRoute.of(context)!.settings.arguments as EmailAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register with Google'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              'You (${emailAddress.getOrCrash()}) have been successfully registered. We\'ve added a place-holder image and and an auto-generated username for you. Don\' stress you can change them later from your user profile page'),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushReplacementNamed(HomePage.homePageRoute);
              },
              child: const Text('Continue to the chats page')),
        ],
      ),
    );
  }
}
