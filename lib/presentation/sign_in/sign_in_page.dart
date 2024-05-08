import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/sign_in_form/sign_in_form_bloc.dart';
import 'package:routes_chat/presentation/sign_in/widgets/sign_in_form.dart';

class SignInPage extends StatelessWidget {
  static const signInPageRoute = '/auth/sign-in';

  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: BlocProvider.value(
        value: BlocProvider.of<SignInFormBloc>(context),
        child: const SignInForm(),
      ),
    );
  }
}
