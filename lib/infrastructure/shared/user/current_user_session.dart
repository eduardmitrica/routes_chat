import '../../../domain/shared/user/current_user_information_persistent.dart';
import '../../../domain/shared/user/current_user_session_interface.dart';

class CurrentUserSession implements ICurrentUserSession {
  CurrentUseInformationPersistent? _current;

  @override
  CurrentUseInformationPersistent? get current => _current;

  @override
  void start(CurrentUseInformationPersistent user) => _current = user;

  @override
  void end() => _current = null;
}
