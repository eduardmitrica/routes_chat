import 'dart:async';

import '../../../domain/shared/user/current_user_information_persistent.dart';
import '../../../domain/shared/user/current_user_session_interface.dart';

class CurrentUserSession implements ICurrentUserSession {
  CurrentUseInformationPersistent? _current;

  // Synchronous so that end() has already started cancelling every listener
  // bound to [ended] by the time it returns; the caller signs out of Firebase
  // on the very next line.
  final _ended = StreamController<void>.broadcast(sync: true);

  @override
  CurrentUseInformationPersistent? get current => _current;

  @override
  Stream<void> get ended => _ended.stream;

  @override
  void start(CurrentUseInformationPersistent user) => _current = user;

  @override
  void end() {
    if (_current == null) return;
    _current = null;
    _ended.add(null);
  }
}
