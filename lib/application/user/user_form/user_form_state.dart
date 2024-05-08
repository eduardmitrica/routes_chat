part of 'user_form_bloc.dart';

@freezed
class UserFormState with _$UserFormState {
  const factory UserFormState({required User user,
    required ImagePath imagePath,
    required bool showErrorMessages,
    required bool isSaving,
    required Option<Either<UserFailure, Unit>>
    saveFailureOrSuccessOption}) = _UserFormState;

  factory UserFormState.initial() =>
      UserFormState(user: User.empty(),
          imagePath: ImagePath(''),
          showErrorMessages: false,
          isSaving: false,
          saveFailureOrSuccessOption: none());
}
