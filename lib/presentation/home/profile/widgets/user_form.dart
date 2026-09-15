import 'dart:io';
import 'privacy_switches.dart';
import 'blocked_people.dart';

// dartz exports its own State class, which would shadow Flutter's.
import 'package:dartz/dartz.dart' show optionOf;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routes_chat/application/user/user_form/user_form_bloc.dart';
import 'package:routes_chat/presentation/home/profile/widgets/sign_out.dart';

import '../../../../domain/core/failures.dart';
import '../../../../domain/shared/user/user.dart';
import '../../../../domain/shared/user/user_failure.dart';
import 'package:routes_chat/presentation/home/profile/widgets/appearance_picker.dart';

class UserForm extends StatefulWidget {
  final User user;

  const UserForm(this.user, {super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserFormBloc>(
      context,
    ).add(UserFormEvent.initialized(optionOf(widget.user)));
  }

  @override
  void didUpdateWidget(UserForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The profile page rebuilds this widget whenever it rebuilds. Only a
    // different stored profile is news for the bloc, which keeps any field
    // that is being edited. Dispatching on every build used to reset the form.
    if (widget.user != oldWidget.user) {
      BlocProvider.of<UserFormBloc>(
        context,
      ).add(UserFormEvent.initialized(optionOf(widget.user)));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Shows [text] in [controller] only when it differs. Assigning text moves the
  /// cursor to the end, so doing it on every state change fought the typing.
  void _show(TextEditingController controller, String text) {
    if (controller.text != text) {
      controller.text = text;
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxHeight: 150,
    );

    if (pickedImage?.path != null && mounted) {
      BlocProvider.of<UserFormBloc>(
        context,
      ).add(UserFormEvent.profilePictureChanged(pickedImage!.path));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxHeight: 150,
    );

    if (pickedImage?.path != null && mounted) {
      BlocProvider.of<UserFormBloc>(
        context,
      ).add(UserFormEvent.profilePictureChanged(pickedImage!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserFormBloc, UserFormState>(
      listenWhen: (previousState, currentState) =>
          previousState.saveFailureOrSuccessOption !=
          currentState.saveFailureOrSuccessOption,
      listener: (context, state) => state.saveFailureOrSuccessOption.fold(
        () {},
        (either) => either.fold((failure) {
          final failureMessage = switch (failure) {
            Unexpected() => 'Unexpected',
            InsufficientPermission() => 'Insufficient permissions',
            UnableToUpdate() => 'Unable to update',
            _ => '',
          };
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failureMessage)));
        }, (_) {}),
      ),
      builder: (context, state) {
        _show(
          _usernameController,
          state.user.username.value.fold(
            (failure) => failure.failedValue,
            (success) => success,
          ),
        );
        _show(
          _descriptionController,
          state.user.description.value.fold(
            (failure) => failure.failedValue,
            (success) => success,
          ),
        );

        return Form(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_album_outlined),
                  ),
                  if (state.user.imageUrl.isValid())
                    BlocBuilder<UserFormBloc, UserFormState>(
                      buildWhen: (previousState, currentState) =>
                          previousState.imagePath != currentState.imagePath,
                      builder: (context, state) {
                        return CircleAvatar(
                          foregroundImage: state.imagePath.comesFromUrl()
                              ? NetworkImage(state.user.imageUrl.getOrCrash())
                              : FileImage(File(state.imagePath.getOrCrash())),
                          radius: 80,
                        );
                      },
                    ),
                  IconButton(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                autovalidateMode: state.showErrorMessages
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (value) {
                  BlocProvider.of<UserFormBloc>(
                    context,
                  ).add(UserFormEvent.usernameChanged(value));
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
                        InvalidUsernameCharacters() =>
                          'This username is not allowed',
                        _ => null,
                      },
                      (_) => null,
                    ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                autovalidateMode: state.showErrorMessages
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  BlocProvider.of<UserFormBloc>(
                    context,
                  ).add(UserFormEvent.descriptionChanged(value));
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
                      (_) => null,
                    ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => BlocProvider.of<UserFormBloc>(
                  context,
                ).add(const UserFormEvent.saved()),
                child: const Text('Save changes'),
              ),
              const SizedBox(height: 32),
              Text('Appearance', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              const AppearancePicker(),
              const SizedBox(height: 32),
              Text('Privacy', style: Theme.of(context).textTheme.titleSmall),
              const PrivacySwitches(),
              const BlockedPeopleTile(),
              const SizedBox(height: 24),
              const SignOut(),
              const SizedBox(height: 10),
              BlocBuilder<UserFormBloc, UserFormState>(
                buildWhen: (previousState, currentState) =>
                    previousState.isSaving != currentState.isSaving,
                builder: (context, state) => state.isSaving
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
    );
  }
}
