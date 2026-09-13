part of 'register_form_bloc.dart';

sealed class RegisterFormEvent extends Equatable {
  const RegisterFormEvent();

  const factory RegisterFormEvent.userImagePlaceholderRequested() =
      UserImagePlaceholderRequested;
  const factory RegisterFormEvent.imageChanged(String imagePathString) =
      ImageChanged;
  const factory RegisterFormEvent.imageFetchedFromDb(String imagePathString) =
      ImageFetchedFromDb;
  const factory RegisterFormEvent.emailChanged(String emailString) =
      EmailChanged;
  const factory RegisterFormEvent.usernameChanged(String usernameString) =
      UsernameChanged;
  const factory RegisterFormEvent.descriptionChanged(String descriptionString) =
      DescriptionChanged;
  const factory RegisterFormEvent.passwordChanged(String passwordString) =
      PasswordChanged;
  const factory RegisterFormEvent.registerPressed() = RegisterPressed;
  const factory RegisterFormEvent.registerWithGooglePressed(String imagePath) =
      ReigsterWithGooglePressed;
  const factory RegisterFormEvent.clearState(String imagePath) = ClearState;

  @override
  List<Object?> get props => const [];
}

final class UserImagePlaceholderRequested extends RegisterFormEvent {
  const UserImagePlaceholderRequested();
}

final class ImageChanged extends RegisterFormEvent {
  final String imagePathString;
  const ImageChanged(this.imagePathString);
  @override
  List<Object?> get props => [imagePathString];
}

final class ImageFetchedFromDb extends RegisterFormEvent {
  final String imagePathString;
  const ImageFetchedFromDb(this.imagePathString);
  @override
  List<Object?> get props => [imagePathString];
}

final class EmailChanged extends RegisterFormEvent {
  final String emailString;
  const EmailChanged(this.emailString);
  @override
  List<Object?> get props => [emailString];
}

final class UsernameChanged extends RegisterFormEvent {
  final String usernameString;
  const UsernameChanged(this.usernameString);
  @override
  List<Object?> get props => [usernameString];
}

final class DescriptionChanged extends RegisterFormEvent {
  final String descriptionString;
  const DescriptionChanged(this.descriptionString);
  @override
  List<Object?> get props => [descriptionString];
}

final class PasswordChanged extends RegisterFormEvent {
  final String passwordString;
  const PasswordChanged(this.passwordString);
  @override
  List<Object?> get props => [passwordString];
}

final class RegisterPressed extends RegisterFormEvent {
  const RegisterPressed();
}

final class ReigsterWithGooglePressed extends RegisterFormEvent {
  final String imagePath;
  const ReigsterWithGooglePressed(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

final class ClearState extends RegisterFormEvent {
  final String imagePath;
  const ClearState(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}
