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
  var _unalteredUser = User.empty();

  UserFormBloc(this._userRepository, this._userUtils)
    : super(UserFormState.initial()) {
    on<UserFormEvent>((event, emit) async {
      switch (event) {
        case UserFormInitialized():
          emit(
            state.copyWith(
              user: event.userOption.fold(() => User.empty(), (user) {
                _unalteredUser = user;
                return user;
              }),
              imagePath: event.userOption.fold(
                () => ImagePath(''),
                (user) => ImagePath.fromUrl(user.imageUrl.getOrCrash()),
              ),
            ),
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
