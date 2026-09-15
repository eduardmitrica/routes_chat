import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/sign_in_form/sign_in_form_bloc.dart';
import 'package:routes_chat/domain/authentication/sign_in_failure.dart';
import 'package:routes_chat/domain/core/failures.dart';
import 'package:routes_chat/presentation/encryption/encryption_gate_page.dart';
import 'package:routes_chat/presentation/register/register_page.dart';

import 'sign_in_failure_message.dart';

import '../../../application/authentication/authentication_bloc.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(
            context,
          ).pushReplacementNamed(EncryptionGatePage.encryptionGatePageRoute);
        }
      },
      child: BlocConsumer<SignInFormBloc, SignInFormState>(
        listenWhen: (previousState, currentState) =>
            previousState.signInFailureOrSuccessOption !=
            currentState.signInFailureOrSuccessOption,
        listener: (context, state) {
          state.signInFailureOrSuccessOption.fold(
            () {},
            (either) => either.fold(
              (failure) {
                final message = signInFailureMessage(failure);
                if (message == null) return;
                final notRegistered = failure is InvalidUser;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(message),
                      // Long enough to read and act on.
                      duration: Duration(seconds: notRegistered ? 10 : 6),
                      action: notRegistered
                          ? SnackBarAction(
                              label: 'Register',
                              onPressed: () =>
                                  Navigator.of(context).pushReplacementNamed(
                                    RegisterPage.registerPageRoute,
                                  ),
                            )
                          : null,
                    ),
                  );
              },
              (_) {
                BlocProvider.of<AuthenticationBloc>(
                  context,
                ).add(const AuthenticationEvent.authenticationRequested());
                BlocProvider.of<SignInFormBloc>(
                  context,
                ).add(const SignInFormEvent.clearState());
              },
            ),
          );
        },
        buildWhen: (previousState, currentState) =>
            previousState.showErrorMessages != currentState.showErrorMessages,
        builder: (context, state) {
          return Form(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  initialValue: state.emailAddress.value.fold(
                    (failure) => failure.failedValue,
                    (success) => success,
                  ),
                  autovalidateMode: state.showErrorMessages
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (value) {
                    BlocProvider.of<SignInFormBloc>(
                      context,
                    ).add(SignInFormEvent.emailChanged(value));
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
                        (_) => null,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.password.value.fold(
                    (failure) => failure.failedValue,
                    (success) => success,
                  ),
                  autovalidateMode: state.showErrorMessages
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onChanged: (value) {
                    BlocProvider.of<SignInFormBloc>(
                      context,
                    ).add(SignInFormEvent.passwordChanged(value));
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
                        (_) => null,
                      ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => BlocProvider.of<SignInFormBloc>(
                    context,
                  ).add(const SignInFormEvent.signInPressed()),
                  child: const Text('Sign in'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => BlocProvider.of<SignInFormBloc>(
                    context,
                  ).add(const SignInFormEvent.signInWithGooglePressed()),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: const Text('Sign in with Google'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(RegisterPage.registerPageRoute);
                  },
                  child: const Text('Switch to register'),
                ),
                BlocBuilder<SignInFormBloc, SignInFormState>(
                  buildWhen: (previousState, currentState) =>
                      previousState.isSubmitting != currentState.isSubmitting,
                  builder: (context, state) => state.isSubmitting
                      ? const Column(
                          children: [
                            SizedBox(height: 10.0),
                            LinearProgressIndicator(value: null),
                          ],
                        )
                      : const Column(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
