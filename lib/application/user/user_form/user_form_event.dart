part of 'user_form_bloc.dart';

@freezed
class UserFormEvent with _$UserFormEvent {
  const factory UserFormEvent.initialized(Option<User> userOption) = _Initialized;
  const factory UserFormEvent.profilePictureChanged(String imagePath) = _ProfilePictureChanged;
  const factory UserFormEvent.usernameChanged(String username) = _UsernameChanged;
  const factory UserFormEvent.descriptionChanged(String description) = _DescriptionChanged;
  const factory UserFormEvent.saved() = _Saved;
  const factory UserFormEvent.rolledBackChanges() = _RolledBackChanges;
}
