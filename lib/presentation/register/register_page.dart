import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/register_form/register_form_bloc.dart';
import 'package:routes_chat/application/shared/picture_placeholder_fetcher/placeholder_fetcher_bloc.dart';
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
      body: BlocBuilder<PlaceholderFetcherBloc, PlaceholderFetcherState>(
        builder: (context, state) {
          if (state.imagePath.isValid()) {
            RegisterFormBloc finalRegisterFormBloc;
            final registerFormBloc = BlocProvider.of<RegisterFormBloc>(context);
            if (registerFormBloc.state.imagePath.isValid() == false) {
              finalRegisterFormBloc = registerFormBloc
                ..add(
                  RegisterFormEvent.imageFetchedFromDb(
                    state.imagePath.getOrCrash(),
                  ),
                );
            } else {
              finalRegisterFormBloc = registerFormBloc;
            }
            return BlocProvider.value(
              value: finalRegisterFormBloc,
              child: const RegisterForm(),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
