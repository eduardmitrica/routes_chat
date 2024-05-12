import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:routes_chat/domain/authentication/registration_failure.dart';

import '../../../domain/authentication/authentication_facade_interface.dart';
import '../../../domain/shared/user/value_objects.dart';

part 'register_form_event.dart';

part 'register_form_state.dart';

part 'register_form_bloc.freezed.dart';

@injectable
class RegisterFormBloc extends Bloc<RegisterFormEvent, RegisterFormState> {
  final IAuthFacade _authFacade;

  RegisterFormBloc(this._authFacade) : super(RegisterFormState.initial()) {
    on<RegisterFormEvent>((event, emit) async {
      await event.map(userImagePlaceholderRequested: (event) async {
        final userImagePlaceholderUrl =
            await _authFacade.fetchUserImagePlaceHolder();
        emit(
          state.copyWith(
            imagePath: ImagePath.fromUrl(userImagePlaceholderUrl),
          ),
        );
      }, imageChanged: (event) {
        emit(
          state.copyWith(
            imagePath: ImagePath(event.imagePathString),
            registrationFailureOrSuccessOption: none(),
          ),
        );
      }, imageFetchedFromDb: (event) {
        emit(
          state.copyWith(
            imagePath: ImagePath.fromUrl(event.imagePathString),
            registrationFailureOrSuccessOption: none(),
          ),
        );
      }, emailChanged: (event) {
        emit(
          state.copyWith(
            emailAddress: EmailAddress(event.emailString),
            registrationFailureOrSuccessOption: none(),
          ),
        );
      }, usernameChanged: (event) {
        emit(state.copyWith(
          username: Username(event.usernameString),
          registrationFailureOrSuccessOption: none(),
        ));
      }, descriptionChanged: (event) {
        emit(
          state.copyWith(
            description: Description(event.descriptionString),
            registrationFailureOrSuccessOption: none(),
          ),
        );
      }, passwordChanged: (event) {
        emit(
          state.copyWith(
            password: Password(event.passwordString),
            registrationFailureOrSuccessOption: none(),
          ),
        );
      }, registerPressed: (event) async {
        Either<RegistrationFailure, Either<EmailAddress, Unit>>?
            failureOrSuccess;

        final isImagePathValid = state.imagePath.isValid();
        final isEmailAddressValid = state.emailAddress.isValid();
        final isUsernameValid = state.username.isValid();
        final isDescriptionValid = state.description.isValid();
        final isPasswordValid = state.password.isValid();
        final isFormValidBeforeCheckingAgainstDb = isImagePathValid &&
            isEmailAddressValid &&
            isUsernameValid &&
            isDescriptionValid &&
            isPasswordValid;

        bool isUsernameValidAfterCheckingAgainstDb = false;
        if (isUsernameValid) {
          final username =
              await Username.checkAgainstDatabase(state.username.getOrCrash());
          isUsernameValidAfterCheckingAgainstDb = username.isValid();
          emit(state.copyWith(username: username));
        }

        final isFormValidAfterCheckingAgainstDb =
            isFormValidBeforeCheckingAgainstDb &&
                isUsernameValidAfterCheckingAgainstDb;

        if (isFormValidAfterCheckingAgainstDb) {
          emit(
            state.copyWith(
                isSubmitting: true, registrationFailureOrSuccessOption: none()),
          );

          final registrationResult = await _authFacade.register(
              imagePath: state.imagePath,
              emailAddress: state.emailAddress,
              username: state.username,
              description: state.description,
              password: state.password);

          registrationResult.fold((failure) {
            failureOrSuccess = Left(failure);
          }, (unit) {
            failureOrSuccess = Right(Right(unit));
          });
        }

        emit(
          state.copyWith(
            isSubmitting: false,
            showErrorMessages: true,
            registrationFailureOrSuccessOption: optionOf(failureOrSuccess),
          ),
        );
      }, registerWithGooglePressed: (event) async {
        emit(
          state.copyWith(
              isSubmitting: true, registrationFailureOrSuccessOption: none()),
        );

        Either<RegistrationFailure, Either<EmailAddress, Unit>>?
            failureOrSuccess;

        final authenticationResult = await _authFacade
            .registerWithGoogle(ImagePath.fromUrl(event.imagePath));
        authenticationResult.fold((failure) {
          failureOrSuccess = Left(failure);
        }, (emailAddress) {
          failureOrSuccess = Right(Left(emailAddress));
        });

        emit(
          state.copyWith(
            isSubmitting: false,
            registrationFailureOrSuccessOption: optionOf(failureOrSuccess),
          ),
        );
      }, clearState: (event) {
        emit(state.copyWith(
          imagePath: ImagePath.fromUrl(event.imagePath),
          emailAddress: EmailAddress(''),
          username: Username(''),
          description: Description(''),
          password:  Password(''),
          showErrorMessages: false,
          isSubmitting: false,
          registrationFailureOrSuccessOption: none(),
        ));
      });
    });
  }
}
