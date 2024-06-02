import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/sign_in_form/sign_in_form_bloc.dart';
import 'package:routes_chat/domain/authentication/sign_in_failure.dart';
import 'package:routes_chat/domain/core/failures.dart';
import 'package:routes_chat/presentation/home/home_page.dart';
import 'package:routes_chat/presentation/register/register_page.dart';

import '../../../application/authentication/authentication_bloc.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        state.maybeMap(
            authenticated: (state) {
              Navigator.of(context)
                  .pushReplacementNamed(HomePage.homePageRoute);
            },
            orElse: () {});
      },
      child: BlocConsumer<SignInFormBloc, SignInFormState>(
        listenWhen: (previousState, currentState) =>
            previousState.signInFailureOrSuccessOption !=
            currentState.signInFailureOrSuccessOption,
        listener: (context, state) {
          state.signInFailureOrSuccessOption.fold(
            () {},
            (either) => either.fold((failure) {
              final message = switch (failure) {
                InvalidEmailAndPasswordCombination() =>
                  'Invalid email and password combination',
                ServerError() => 'Server error',
                CancelledByUser() => 'Cancelled by user',
                InvalidUser() => 'Invalid user, please register first',
                SignInFailed() => 'Sign in failed',
                GoogleError() => 'Google error',
              };
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            }, (_) {
              BlocProvider.of<AuthenticationBloc>(context)
                  .add(const AuthenticationEvent.authenticationRequested());
              BlocProvider.of<SignInFormBloc>(context)
                  .add(const SignInFormEvent.clearState());
            }),
          );
        },
        buildWhen: (previousState, currentState) =>
            previousState.showErrorMessages != currentState.showErrorMessages,
        builder: (context, state) {
          return Form(
            child: ListView(
              padding: const EdgeInsets.all(15.0),
              children: [
                TextFormField(
                  initialValue: state.emailAddress.value.fold(
                      (failure) => failure.failedValue, (success) => success),
                  autovalidateMode: state.showErrorMessages
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (value) {
                    BlocProvider.of<SignInFormBloc>(context)
                        .add(SignInFormEvent.emailChanged(value));
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (value) => BlocProvider.of<SignInFormBloc>(context)
                      .state
                      .emailAddress
                      .value
                      .fold(
                          (failure) => switch (failure) {
                                InvalidEmail() => 'Invalid Email',
                                _ => null,
                              },
                          (_) => null),
                ),
                TextFormField(
                  initialValue: state.password.value.fold(
                      (failure) => failure.failedValue, (success) => success),
                  autovalidateMode: state.showErrorMessages
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onChanged: (value) {
                    BlocProvider.of<SignInFormBloc>(context)
                        .add(SignInFormEvent.passwordChanged(value));
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  obscureText: true,
                  validator: (value) => BlocProvider.of<SignInFormBloc>(context)
                      .state
                      .password
                      .value
                      .fold(
                          (failure) => switch (failure) {
                                InvalidPassword() => 'Invalid Password',
                                _ => null,
                              },
                          (_) => null),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => BlocProvider.of<SignInFormBloc>(context)
                          .add(const SignInFormEvent.signInPressed()),
                      child: const Text('Sign in'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                            RegisterPage.registerPageRoute);
                      },
                      child: const Text('Switch to register'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Spacer(
                      flex: 1,
                    ),
                    ElevatedButton(
                      onPressed: () => BlocProvider.of<SignInFormBloc>(context)
                          .add(const SignInFormEvent.signInWithGooglePressed()),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sign in with Google'),
                          Icon(
                            Icons.g_mobiledata_rounded,
                            color: Colors.amber,
                          )
                        ],
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                  ],
                ),
                BlocBuilder<SignInFormBloc, SignInFormState>(
                  buildWhen: (previousState, currentState) =>
                      previousState.isSubmitting != currentState.isSubmitting,
                  builder: (context, state) => state.isSubmitting
                      ? const Column(
                          children: [
                            SizedBox(
                              height: 10.0,
                            ),
                            LinearProgressIndicator(
                              value: null,
                            )
                          ],
                        )
                      : const Column(),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
