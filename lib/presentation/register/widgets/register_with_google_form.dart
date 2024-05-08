import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/authentication/register_form/register_form_bloc.dart';
import '../../../domain/core/failures.dart';

class RegisterWithGoogleForm extends StatelessWidget {
  const RegisterWithGoogleForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterFormBloc, RegisterFormState>(
      buildWhen: (previousState, currentState) =>
          previousState.showErrorMessages != currentState.showErrorMessages ||
          previousState.imagePath.isValid() != currentState.imagePath.isValid(),
      builder: (context, state) {
        return Form(
          child: ListView(
            padding: const EdgeInsets.all(15.0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.photo_album_outlined)),
                  if (state.imagePath.isValid())
                    CircleAvatar(
                      backgroundColor: Colors.purple,
                      foregroundImage:
                          NetworkImage(state.imagePath.getOrCrash()),
                      radius: 80,
                    ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_outlined)),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                initialValue: state.username.value.fold(
                    (failure) => failure.failedValue, (success) => success),
                autovalidateMode: state.showErrorMessages
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (value) {
                  BlocProvider.of<RegisterFormBloc>(context)
                      .add(RegisterFormEvent.usernameChanged(value));
                },
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                autocorrect: false,
                validator: (value) => BlocProvider.of<RegisterFormBloc>(context)
                    .state
                    .username
                    .value
                    .fold(
                        (failure) => switch (failure) {
                              EmptyString() => 'This field is mandatory',
                              ExceedingLength() =>
                                'The username must have at most 12 characters',
                              UsernameAlreadyExists() =>
                                'This username already exists',
                              _ => null,
                            },
                        (_) => null),
              ),
              TextFormField(
                initialValue: state.description.value.fold(
                        (failure) => failure.failedValue, (success) => success),
                autovalidateMode: state.showErrorMessages
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  BlocProvider.of<RegisterFormBloc>(context)
                      .add(RegisterFormEvent.descriptionChanged(value));
                },
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (value) => BlocProvider.of<RegisterFormBloc>(context)
                    .state
                    .description
                    .value
                    .fold(
                        (failure) => switch (failure) {
                      ExceedingLength() =>
                      'The description must have at most 30 characters',
                      _ => null,
                    },
                        (_) => null),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Spacer(flex: 1,),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Continue'),
                  ),
                  const Spacer(flex: 1,),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
