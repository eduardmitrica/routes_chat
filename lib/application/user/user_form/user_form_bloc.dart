import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/shared/user/user.dart';
import '../../../domain/shared/user/user_failure.dart';
import '../../../domain/shared/user/user_repository_interface.dart';
import '../../../domain/shared/user/user_utils_interface.dart';
import '../../../domain/shared/user/value_objects.dart';

part 'user_form_event.dart';

part 'user_form_state.dart';

part 'user_form_bloc.freezed.dart';

class UserFormBloc extends Bloc<UserFormEvent, UserFormState> {
  final IUserRepository _userRepository;
  final IUserUtils _userUtils;

  /// The profile as last stored, which edits and saves are compared against.
  var _unalteredUser = User.empty();

  /// Whether a stored profile has been loaded into the form yet.
  var _initialized = false;

  UserFormBloc(this._userRepository, this._userUtils)
    : super(UserFormState.initial()) {
    on<UserFormEvent>((event, emit) async {
      switch (event) {
        case UserFormInitialized():
          event.userOption.fold(
            () {
              _unalteredUser = User.empty();
              _initialized = false;
              emit(
                state.copyWith(user: User.empty(), imagePath: ImagePath('')),
              );
            },
            (stored) {
              if (!_initialized) {
                _unalteredUser = stored;
                _initialized = true;
                emit(
                  state.copyWith(
                    user: stored,
                    imagePath: ImagePath.fromUrl(stored.imageUrl.getOrCrash()),
                  ),
                );
                return;
              }

              // A newer stored profile (after a save, or an edit made on
              // another device) must not wipe what is being typed. A field that
              // still matches the previous stored profile takes the new value;
              // a field the user has edited keeps the draft. Replacing the whole
              // form here used to throw away unsaved edits.
              final previous = _unalteredUser;
              final draft = state.user;
              final imagePicked = !state.imagePath.comesFromUrl();
              final imageChangedInStore = stored.imageUrl != previous.imageUrl;
              _unalteredUser = stored;
              emit(
                state.copyWith(
                  user: stored.copyWith(
                    username: draft.username == previous.username
                        ? stored.username
                        : draft.username,
                    description: draft.description == previous.description
                        ? stored.description
                        : draft.description,
                  ),
                  imagePath: imagePicked && !imageChangedInStore
                      ? state.imagePath
                      : ImagePath.fromUrl(stored.imageUrl.getOrCrash()),
                ),
              );
            },
          );
        case ProfilePictureChanged():
          emit(
            state.copyWith(
              imagePath: ImagePath(event.imagePath),
              saveFailureOrSuccessOption: none(),
            ),
          );
        case UserFormUsernameChanged():
          emit(
            state.copyWith(
              user: state.user.copyWith(username: Username(event.username)),
              saveFailureOrSuccessOption: none(),
            ),
          );
        case UserFormDescriptionChanged():
          emit(
            state.copyWith(
              user: state.user.copyWith(
                description: Description(event.description),
              ),
              saveFailureOrSuccessOption: none(),
            ),
          );
        case UserFormSaved():
          {
            Either<UserFailure, Unit>? failureOrSuccess;
            emit(
              state.copyWith(
                isSaving: true,
                saveFailureOrSuccessOption: none(),
              ),
            );

            final user = state.user;
            final isImageValid =
                state.imagePath.isValid() && user.imageUrl.isValid();

            var isUsernameValid = user.username.isValid();
            var usernameCheckedAgainstDb = user.username;
            // Only a changed username needs the uniqueness check. The current
            // one is already claimed by this user, so checking it reported
            // "already exists" and blocked every save that kept the username,
            // such as a description-only edit.
            if (isUsernameValid &&
                (!_unalteredUser.username.isValid() ||
                    _unalteredUser.username.getOrCrash() !=
                        user.username.getOrCrash())) {
              usernameCheckedAgainstDb = await Username.checkAgainstDatabase(
                _userUtils,
                user.username.getOrCrash(),
              );
              isUsernameValid =
                  isUsernameValid &&
                  usernameCheckedAgainstDb.value.fold(
                    (failure) => false,
                    (success) => true,
                  );
            }

            if (user.username.isValid() &&
                _unalteredUser.username.isValid() &&
                _unalteredUser.username.getOrCrash() !=
                    user.username.getOrCrash() &&
                !isUsernameValid) {
              emit(
                state.copyWith(
                  user: user.copyWith(username: usernameCheckedAgainstDb),
                ),
              );
            }

            final isDescriptionValid = user.description.isValid();
            final changesAreValid =
                isImageValid && isUsernameValid && isDescriptionValid;
            final imageChangedButUsernameDidNot =
                isImageValid &&
                !state.imagePath.comesFromUrl() &&
                isDescriptionValid;
            if (changesAreValid || imageChangedButUsernameDidNot) {
              final newUser = user.copyWith(
                imageUrl: ImageUrl(state.imagePath.getOrCrash()),
              );
              failureOrSuccess = await _userRepository.update(newUser);
            }

            emit(
              state.copyWith(
                isSaving: false,
                showErrorMessages: true,
                saveFailureOrSuccessOption: optionOf(failureOrSuccess),
              ),
            );
          }
        case UserFormRolledBackChanges():
          emit(
            state.copyWith(
              user: _unalteredUser,
              imagePath: ImagePath.fromUrl(
                _unalteredUser.imageUrl.getOrCrash(),
              ),
              isSaving: false,
              saveFailureOrSuccessOption: none(),
            ),
          );
      }
    });
  }
}
