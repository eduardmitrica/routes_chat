import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/presentation/sign_in/sign_in_page.dart';

class SignOut extends StatelessWidget {
  const SignOut({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        switch (state) {
          case AuthenticationInitial():
          case Authenticated():
            break;
          case Unauthenticated():
            Navigator.of(
              context,
            ).pushReplacementNamed(SignInPage.signInPageRoute);
        }
      },
      child: OutlinedButton.icon(
        onPressed: () => BlocProvider.of<AuthenticationBloc>(
          context,
        ).add(const AuthenticationEvent.signedOut()),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Sign out'),
      ),
    );
  }
}
