part of 'register_form_bloc.dart';

@freezed
class RegisterFormEvent with _$RegisterFormEvent {
  const factory RegisterFormEvent.userImagePlaceholderRequested() = UserImagePlaceholderRequested;
  const factory RegisterFormEvent.imageChanged(String imagePathString) = ImageChanged;
  const factory RegisterFormEvent.imageFetchedFromDb(String imagePathString) = ImageFetchedFromDb;
  const factory RegisterFormEvent.emailChanged(String emailString) = EmailChanged;
  const factory RegisterFormEvent.usernameChanged(String usernameString) = UsernameChanged;
  const factory RegisterFormEvent.descriptionChanged(String descriptionString) = DescriptionChanged;
  const factory RegisterFormEvent.passwordChanged(String passwordString) = PasswordChanged;
  const factory RegisterFormEvent.registerPressed() = RegisterPressed;
  const factory RegisterFormEvent.registerWithGooglePressed(String imagePath) = ReigsterWithGooglePressed;
  const factory RegisterFormEvent.clearState(String imagePath) = ClearState;
}
