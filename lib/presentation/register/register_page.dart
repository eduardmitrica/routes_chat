import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/register_form/register_form_bloc.dart';
import 'package:routes_chat/presentation/register/widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  static const registerPageRoute = '/auth/register';

  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: BlocProvider.value(
        value:  BlocProvider.of<RegisterFormBloc>(context),
        child: const RegisterForm(),
      ),
    );
  }
}
