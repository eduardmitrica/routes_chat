part of 'user_form_bloc.dart';

sealed class UserFormEvent extends Equatable {
  const UserFormEvent();

  const factory UserFormEvent.initialized(Option<User> userOption) =
      UserFormInitialized;
  const factory UserFormEvent.profilePictureChanged(String imagePath) =
      ProfilePictureChanged;
  const factory UserFormEvent.usernameChanged(String username) =
      UserFormUsernameChanged;
  const factory UserFormEvent.descriptionChanged(String description) =
      UserFormDescriptionChanged;
  const factory UserFormEvent.saved() = UserFormSaved;
  const factory UserFormEvent.rolledBackChanges() = UserFormRolledBackChanges;

  @override
  List<Object?> get props => const [];
}

final class UserFormInitialized extends UserFormEvent {
  final Option<User> userOption;
  const UserFormInitialized(this.userOption);
  @override
  List<Object?> get props => [userOption];
}

final class ProfilePictureChanged extends UserFormEvent {
  final String imagePath;
  const ProfilePictureChanged(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

final class UserFormUsernameChanged extends UserFormEvent {
  final String username;
  const UserFormUsernameChanged(this.username);
  @override
  List<Object?> get props => [username];
}

final class UserFormDescriptionChanged extends UserFormEvent {
  final String description;
  const UserFormDescriptionChanged(this.description);
  @override
  List<Object?> get props => [description];
}

final class UserFormSaved extends UserFormEvent {
  const UserFormSaved();
}

final class UserFormRolledBackChanges extends UserFormEvent {
  const UserFormRolledBackChanges();
}
