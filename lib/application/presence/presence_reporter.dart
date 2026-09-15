import 'dart:async';

import '../../domain/presence/presence_repository_interface.dart';
import '../../domain/settings/privacy_settings.dart';
import '../../domain/shared/user/current_user_session_interface.dart';

/// Tells friends when this user's app is on screen, while the user shares it.
///
/// While the app is on screen it says so every [defaultHeartbeat], so a phone
/// that dies without saying goodbye stops counting as online soon after. When
/// the app leaves the screen it says so at once. Turning sharing off deletes
/// what friends could see.
class PresenceReporter {
  static const defaultHeartbeat = Duration(seconds: 45);

  final IPresenceRepository _presence;
  final IPrivacySettingsReader _privacy;
  final ICurrentUserSession _session;
  final Duration _heartbeat;

  Timer? _timer;
  var _onScreen = false;

  PresenceReporter(
    this._presence,
    this._privacy,
    this._session, {
    Duration heartbeat = defaultHeartbeat,
  }) : _heartbeat = heartbeat {
    _privacy.privacyChanges.listen(_privacyChanged);
    _session.ended.listen((_) => _stopHeartbeat());
  }

  bool get _sharing => _session.current != null && _privacy.privacy.shareOnline;

  /// The app came on screen, signed in.
  void appResumed() {
    _onScreen = true;
    _startHeartbeat();
  }

  /// The app left the screen.
  void appPaused() {
    if (!_onScreen) return;
    _onScreen = false;
    _stopHeartbeat();
    if (_sharing) unawaited(_presence.reportOffline());
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    if (!_sharing) return;
    unawaited(_presence.reportOnline());
    _timer = Timer.periodic(_heartbeat, (_) {
      if (_sharing) unawaited(_presence.reportOnline());
    });
  }

  void _stopHeartbeat() {
    _timer?.cancel();
    _timer = null;
  }

  void _privacyChanged(PrivacySettings settings) {
    if (!settings.shareOnline) {
      _stopHeartbeat();
      final uid = _session.current?.id;
      if (uid != null) unawaited(_presence.clearPresence(uid));
    } else if (_onScreen) {
      _startHeartbeat();
    }
  }
}
