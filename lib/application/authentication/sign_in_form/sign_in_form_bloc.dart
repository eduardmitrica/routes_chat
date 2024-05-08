import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:routes_chat/domain/authentication/sign_in_failure.dart';

import '../../../domain/authentication/authentication_facade_interface.dart';
import '../../../domain/authentication/value_objects.dart';

part 'sign_in_form_event.dart';

part 'sign_in_form_state.dart';

part 'sign_in_form_bloc.freezed.dart';

@injectable
class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _authFacade;

  SignInFormBloc(this._authFacade) : super(SignInFormState.initial()) {
    on<SignInFormEvent>((event, emit) async {
      await event.map(emailChanged: (event) {
        emit(
          state.copyWith(
            emailAddress: EmailAddress(event.emailString),
            signInFailureOrSuccessOption: none(),
          ),
        );
      }, passwordChanged: (event) {
        emit(
          state.copyWith(
            password: Password(event.passwordString),
            signInFailureOrSuccessOption: none(),
          ),
        );
      }, registerPressed: (event) async {
        Either<SignInFailure, Unit>? failureOrSuccess;

        final isEmailAddressValid = state.emailAddress.isValid();
        final isPasswordValid = state.password.isValid();
        final isFormValid = isEmailAddressValid && isPasswordValid;

        if (isFormValid) {
          emit(
            state.copyWith(
                isSubmitting: true, signInFailureOrSuccessOption: none()),
          );

          failureOrSuccess = await _authFacade.signInWithEmailAndPassword(
              emailAddress: state.emailAddress, password: state.password);
        }

        emit(
          state.copyWith(
            isSubmitting: false,
            showErrorMessages: true,
            signInFailureOrSuccessOption: optionOf(failureOrSuccess),
          ),
        );
      }, signInWithGooglePressed: (event) async {
        emit(
          state.copyWith(
              isSubmitting: true, signInFailureOrSuccessOption: none()),
        );

        final failureOrSuccess = await _authFacade.signInWithGoogle();

        emit(
          state.copyWith(
            isSubmitting: false,
            signInFailureOrSuccessOption: optionOf(failureOrSuccess),
          ),
        );
      }, clearState: (event) {
        emit(state.copyWith(
          emailAddress: EmailAddress(''),
          password: Password(''),
          showErrorMessages: false,
          isSubmitting: false,
          signInFailureOrSuccessOption: none(),
        ));
      });
    });
  }
}
