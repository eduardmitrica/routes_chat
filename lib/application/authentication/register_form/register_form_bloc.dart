import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:routes_chat/domain/authentication/registration_failure.dart';

import '../../../domain/authentication/authentication_facade_interface.dart';
import '../../../domain/shared/user/user_utils_interface.dart';
import '../../../domain/shared/user/value_objects.dart';

part 'register_form_event.dart';

part 'register_form_state.dart';

part 'register_form_bloc.freezed.dart';

class RegisterFormBloc extends Bloc<RegisterFormEvent, RegisterFormState> {
  final IAuthFacade _authFacade;
  final IUserUtils _userUtils;

  RegisterFormBloc(this._authFacade, this._userUtils)
    : super(RegisterFormState.initial()) {
    on<RegisterFormEvent>((event, emit) async {
      switch (event) {
        case UserImagePlaceholderRequested():
          final userImagePlaceholderUrl = await _authFacade
              .fetchUserImagePlaceHolder();
          emit(
            state.copyWith(
              imagePath: ImagePath.fromUrl(userImagePlaceholderUrl),
            ),
          );
        case ImageChanged():
          emit(
            state.copyWith(
              imagePath: ImagePath(event.imagePathString),
              registrationFailureOrSuccessOption: none(),
            ),
          );
        case ImageFetchedFromDb():
          emit(
            state.copyWith(
              imagePath: ImagePath.fromUrl(event.imagePathString),
              registrationFailureOrSuccessOption: none(),
            ),
          );
        case EmailChanged():
          emit(
            state.copyWith(
              emailAddress: EmailAddress(event.emailString),
              registrationFailureOrSuccessOption: none(),
            ),
          );
        case UsernameChanged():
          emit(
            state.copyWith(
              username: Username(event.usernameString),
              registrationFailureOrSuccessOption: none(),
            ),
          );
        case DescriptionChanged():
          emit(
            state.copyWith(
              description: Description(event.descriptionString),
              registrationFailureOrSuccessOption: none(),
            ),
          );
        case PasswordChanged():
          emit(
            state.copyWith(
              password: Password(event.passwordString),
              registrationFailureOrSuccessOption: none(),
            ),
          );
        case RegisterPressed():
          Either<RegistrationFailure, Either<EmailAddress, Unit>>?
          failureOrSuccess;

          final isImagePathValid = state.imagePath.isValid();
          final isEmailAddressValid = state.emailAddress.isValid();
          final isUsernameValid = state.username.isValid();
          final isDescriptionValid = state.description.isValid();
          final isPasswordValid = state.password.isValid();
          final isFormValidBeforeCheckingAgainstDb =
              isImagePathValid &&
              isEmailAddressValid &&
              isUsernameValid &&
              isDescriptionValid &&
              isPasswordValid;

          bool isUsernameValidAfterCheckingAgainstDb = false;
          if (isUsernameValid) {
            final username = await Username.checkAgainstDatabase(
              _userUtils,
              state.username.getOrCrash(),
            );
            isUsernameValidAfterCheckingAgainstDb = username.isValid();
            emit(state.copyWith(username: username));
          }

          final isFormValidAfterCheckingAgainstDb =
              isFormValidBeforeCheckingAgainstDb &&
              isUsernameValidAfterCheckingAgainstDb;

          if (isFormValidAfterCheckingAgainstDb) {
            emit(
              state.copyWith(
                isSubmitting: true,
                registrationFailureOrSuccessOption: none(),
              ),
            );

            final registrationResult = await _authFacade.register(
              imagePath: state.imagePath,
              emailAddress: state.emailAddress,
              username: state.username,
              description: state.description,
              password: state.password,
            );

            registrationResult.fold(
              (failure) {
                failureOrSuccess = Left(failure);
              },
              (unit) {
                failureOrSuccess = Right(Right(unit));
              },
            );
          }

          emit(
            state.copyWith(
              isSubmitting: false,
              showErrorMessages: true,
              registrationFailureOrSuccessOption: optionOf(failureOrSuccess),
            ),
          );
        case ReigsterWithGooglePressed():
          emit(
            state.copyWith(
              isSubmitting: true,
              registrationFailureOrSuccessOption: none(),
            ),
          );

          Either<RegistrationFailure, Either<EmailAddress, Unit>>?
          failureOrSuccessGoogle;

          final authenticationResult = await _authFacade.registerWithGoogle(
            ImagePath.fromUrl(event.imagePath),
          );
          authenticationResult.fold(
            (failure) {
              failureOrSuccessGoogle = Left(failure);
            },
            (emailAddress) {
              failureOrSuccessGoogle = Right(Left(emailAddress));
            },
          );

          emit(
            state.copyWith(
              isSubmitting: false,
              registrationFailureOrSuccessOption: optionOf(
                failureOrSuccessGoogle,
              ),
            ),
          );
        case ClearState():
          emit(
            state.copyWith(
              imagePath: ImagePath.fromUrl(event.imagePath),
              emailAddress: EmailAddress(''),
              username: Username(''),
              description: Description(''),
              password: Password(''),
              showErrorMessages: false,
              isSubmitting: false,
              registrationFailureOrSuccessOption: none(),
            ),
          );
      }
    });
  }
}
