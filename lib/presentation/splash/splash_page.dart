import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/presentation/home/home_page.dart';
import 'package:routes_chat/presentation/sign_in/sign_in_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        switch (state) {
          case AuthenticationInitial():
            break;
          case Authenticated():
            Navigator.of(context).pushReplacementNamed(HomePage.homePageRoute);
          case Unauthenticated():
            Navigator.of(
              context,
            ).pushReplacementNamed(SignInPage.signInPageRoute);
        }
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
