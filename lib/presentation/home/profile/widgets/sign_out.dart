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
        state.map(
            initial: (_) {},
            authenticated: (_) {},
            unauthenticated: (_) => Navigator.of(context)
                .pushReplacementNamed(SignInPage.signInPageRoute));
      },
      child: Row(
        children: [
          const Spacer(
            flex: 1,
          ),
          ElevatedButton(
            onPressed: () => BlocProvider.of<AuthenticationBloc>(context).add(
              const AuthenticationEvent.signedOut(),
            ),
            child: const Text('Sign out'),
          ),
          const Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}
