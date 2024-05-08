import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routes_chat/application/user/user_form/user_form_bloc.dart';
import 'package:routes_chat/domain/authentication/user_failure.dart';
import 'package:routes_chat/presentation/profile/widgets/sign_out.dart';

import '../../../domain/authentication/user.dart';
import '../../../domain/core/failures.dart';

class UserForm extends StatelessWidget {
  final User user;

  final usernameController = TextEditingController(text: '');
  final descriptionController = TextEditingController(text: '');

  UserForm(this.user, {super.key});

  _takePicture(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxHeight: 150);

    if (pickedImage?.path != null && context.mounted) {
      BlocProvider.of<UserFormBloc>(context)
          .add(UserFormEvent.profilePictureChanged(pickedImage!.path));
    }
  }

  _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxHeight: 150);

    if (pickedImage?.path != null && context.mounted) {
      BlocProvider.of<UserFormBloc>(context)
          .add(UserFormEvent.profilePictureChanged(pickedImage!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<UserFormBloc>(context)
        ..add(UserFormEvent.initialized(optionOf(user))),
      child: BlocConsumer<UserFormBloc, UserFormState>(
        listenWhen: (previousState, currentState) =>
            previousState.saveFailureOrSuccessOption !=
            currentState.saveFailureOrSuccessOption,
        listener: (context, state) => state.saveFailureOrSuccessOption.fold(
          () {},
          (either) => either.fold(
            (failure) {
              final failureMessage = switch (failure) {
                Unexpected() => 'Unexpected',
                InsufficientPermission() => 'Insufficient permissions',
                UnableToUpdate() => 'Unable to update',
                _ => '',
              };
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failureMessage),
                ),
              );
            },
            (_) {},
          ),
        ),
        builder: (context, state) {
          usernameController.text = state.user.username.value
              .fold((failure) => failure.failedValue, (success) => success);
          descriptionController.text = state.user.description.value
              .fold((failure) => failure.failedValue, (success) => success);

          return Form(
            child: ListView(
              padding: const EdgeInsets.all(15.0),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        onPressed: () => _pickImage(context),
                        icon: const Icon(Icons.photo_album_outlined)),
                    if (state.user.imageUrl.isValid())
                      BlocBuilder<UserFormBloc, UserFormState>(
                        buildWhen: (previousState, currentState) =>
                            previousState.imagePath != currentState.imagePath,
                        builder: (context, state) {
                          return CircleAvatar(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundImage: state.imagePath.comesFromUrl()
                                ? NetworkImage(
                                    state.user.imageUrl.getOrCrash(),
                                  )
                                : FileImage(
                                    File(
                                      state.imagePath.getOrCrash(),
                                    ),
                                  ),
                            radius: 80,
                          );
                        },
                      ),
                    IconButton(
                        onPressed: () => _takePicture(context),
                        icon: const Icon(Icons.camera_alt_outlined)),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: usernameController,
                  autovalidateMode: state.showErrorMessages
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  decoration: const InputDecoration(labelText: 'Username'),
                  onChanged: (value) {
                    BlocProvider.of<UserFormBloc>(context)
                        .add(UserFormEvent.usernameChanged(value));
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  autocorrect: false,
                  validator: (value) => BlocProvider.of<UserFormBloc>(context)
                      .state
                      .user
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
                  controller: descriptionController,
                  autovalidateMode: state.showErrorMessages
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    BlocProvider.of<UserFormBloc>(context)
                        .add(UserFormEvent.descriptionChanged(value));
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  validator: (value) => BlocProvider.of<UserFormBloc>(context)
                      .state
                      .user
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
                    const Spacer(
                      flex: 1,
                    ),
                    ElevatedButton(
                      onPressed: () => BlocProvider.of<UserFormBloc>(context)
                          .add(const UserFormEvent.saved()),
                      child: const Text('Save changes'),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const SignOut(),
                const SizedBox(
                  height: 10,
                ),
                BlocBuilder<UserFormBloc, UserFormState>(
                  buildWhen: (previousState, currentState) =>
                      previousState.isSaving != currentState.isSaving,
                  builder: (context, state) => state.isSaving
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
