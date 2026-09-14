import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/application/authentication/register_form/register_form_bloc.dart';
import 'package:routes_chat/application/shared/picture_placeholder_fetcher/placeholder_fetcher_bloc.dart';
import 'package:routes_chat/domain/authentication/registration_failure.dart';
import 'package:routes_chat/domain/core/failures.dart';
import 'package:routes_chat/presentation/encryption/encryption_gate_page.dart';
import 'package:routes_chat/presentation/register/register_with_google_page.dart';
import 'package:routes_chat/presentation/sign_in/sign_in_page.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  Future<void> _takePicture(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxHeight: 150,
    );

    if (pickedImage?.path != null && context.mounted) {
      BlocProvider.of<RegisterFormBloc>(
        context,
      ).add(RegisterFormEvent.imageChanged(pickedImage!.path));
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxHeight: 150,
    );

    if (pickedImage?.path != null && context.mounted) {
      BlocProvider.of<RegisterFormBloc>(
        context,
      ).add(RegisterFormEvent.imageChanged(pickedImage!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          BlocProvider.of<RegisterFormBloc>(
            context,
          ).state.registrationFailureOrSuccessOption.fold(
            () {},
            (either) => either.fold((failure) {}, (successEither) {
              successEither.fold(
                (emailAddress) {
                  Navigator.of(context).pushReplacementNamed(
                    RegisterWithGooglePage.registerWithGooglePageRoute,
                    arguments: emailAddress,
                  );
                },
                (_) {
                  Navigator.of(context).pushReplacementNamed(
                    EncryptionGatePage.encryptionGatePageRoute,
                  );
                },
              );
            }),
          );
          BlocProvider.of<RegisterFormBloc>(context).add(
            RegisterFormEvent.clearState(
              BlocProvider.of<PlaceholderFetcherBloc>(
                context,
              ).state.imagePath.getOrCrash(),
            ),
          );
        }
      },
      child: BlocConsumer<RegisterFormBloc, RegisterFormState>(
        listenWhen: (previousState, currentState) =>
            previousState.registrationFailureOrSuccessOption !=
            currentState.registrationFailureOrSuccessOption,
        listener: (context, state) {
          state.registrationFailureOrSuccessOption.fold(
            () {},
            (either) => either.fold(
              (failure) {
                final message = switch (failure) {
                  EmailAlreadyInUse() => 'Email already in use',
                  UsernameTaken() =>
                    'That username was just taken, please choose another',
                  ServerError() => 'Server Error',
                  CancelledByUser() => 'Cancelled',
                  UserAlreadyRegistered() =>
                    'This google account is already registered, please sign in',
                  SignInWithGoogleFailed() =>
                    'Authenticating into google failed',
                  GoogleError() => 'Google error',
                };
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              },
              (successEither) {
                BlocProvider.of<AuthenticationBloc>(
                  context,
                ).add(const AuthenticationEvent.authenticationRequested());
              },
            ),
          );
        },
        buildWhen: (previousState, currentState) =>
            previousState.showErrorMessages != currentState.showErrorMessages ||
            previousState.imagePath.isValid() !=
                currentState.imagePath.isValid(),
        builder: (context, state) {
          return Form(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => _pickImage(context),
                      icon: const Icon(Icons.photo_album_outlined),
                    ),
                    if (state.imagePath.isValid())
                      BlocBuilder<RegisterFormBloc, RegisterFormState>(
                        buildWhen: (previousState, currentState) =>
                            previousState.imagePath != currentState.imagePath,
                        builder: (context, state) {
                          return CircleAvatar(
                            foregroundImage: state.imagePath.comesFromUrl()
                                ? NetworkImage(state.imagePath.getOrCrash())
                                : FileImage(File(state.imagePath.getOrCrash())),
                            radius: 80,
                          );
                        },
                      ),
                    IconButton(
                      onPressed: () => _takePicture(context),
                      icon: const Icon(Icons.camera_alt_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                    BlocProvider.of<RegisterFormBloc>(
                      context,
                    ).add(RegisterFormEvent.emailChanged(value));
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (value) =>
                      BlocProvider.of<RegisterFormBloc>(
                        context,
                      ).state.emailAddress.value.fold(
                        (failure) => switch (failure) {
                          InvalidEmail() => 'Invalid Email',
                          _ => null,
                        },
                        (_) => null,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.username.value.fold(
                    (failure) => failure.failedValue,
                    (success) => success,
                  ),
                  autovalidateMode: state.showErrorMessages
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  decoration: const InputDecoration(labelText: 'Username'),
                  onChanged: (value) {
                    BlocProvider.of<RegisterFormBloc>(
                      context,
                    ).add(RegisterFormEvent.usernameChanged(value));
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  autocorrect: false,
                  validator: (value) =>
                      BlocProvider.of<RegisterFormBloc>(
                        context,
                      ).state.username.value.fold(
                        (failure) => switch (failure) {
                          EmptyString() => 'This field is mandatory',
                          ExceedingLength() =>
                            'The username must have at most 12 characters',
                          UsernameAlreadyExists() =>
                            'This username already exists',
                          InvalidUsernameCharacters() =>
                            'This username is not allowed',
                          _ => null,
                        },
                        (_) => null,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: state.description.value.fold(
                    (failure) => failure.failedValue,
                    (success) => success,
                  ),
                  autovalidateMode: state.showErrorMessages
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    BlocProvider.of<RegisterFormBloc>(
                      context,
                    ).add(RegisterFormEvent.descriptionChanged(value));
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  validator: (value) =>
                      BlocProvider.of<RegisterFormBloc>(
                        context,
                      ).state.description.value.fold(
                        (failure) => switch (failure) {
                          ExceedingLength() =>
                            'The description must have at most 30 characters',
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
                    BlocProvider.of<RegisterFormBloc>(
                      context,
                    ).add(RegisterFormEvent.passwordChanged(value));
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  obscureText: true,
                  validator: (value) =>
                      BlocProvider.of<RegisterFormBloc>(
                        context,
                      ).state.password.value.fold(
                        (failure) => switch (failure) {
                          InvalidPassword() => 'Invalid Password',
                          _ => null,
                        },
                        (_) => null,
                      ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => BlocProvider.of<RegisterFormBloc>(
                    context,
                  ).add(const RegisterFormEvent.registerPressed()),
                  child: const Text('Register'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    BlocProvider.of<RegisterFormBloc>(context).add(
                      RegisterFormEvent.registerWithGooglePressed(
                        BlocProvider.of<PlaceholderFetcherBloc>(
                          context,
                        ).state.imagePath.getOrCrash(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: const Text('Register with Google'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(SignInPage.signInPageRoute);
                  },
                  child: const Text('Switch to sign in'),
                ),
                BlocBuilder<RegisterFormBloc, RegisterFormState>(
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
