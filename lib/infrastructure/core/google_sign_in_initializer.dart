import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../firebase_options.dart';

/// google_sign_in 7.x requires a one-time [GoogleSignIn.initialize] call before
/// any authentication attempt. On Android the [serverClientId] (the OAuth 2.0
/// "Web application" client from google-services.json) is what makes
/// `GoogleSignInAuthentication.idToken` available, which Firebase needs to build
/// a Google credential.
class GoogleSignInInitializer {
  const GoogleSignInInitializer._();

  /// OAuth 2.0 Web client id for project `routes-chat`
  /// (google-services.json -> oauth_client -> client_type 3).
  static const String _serverClientId =
      '1018057414272-ms5smbdnp5ruklrtdp1u8likvfe5ppjf.apps.googleusercontent.com';

  static Future<void> ensureInitialized() async {
    final isIOS =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    await GoogleSignIn.instance.initialize(
      clientId: isIOS ? DefaultFirebaseOptions.ios.iosClientId : null,
      serverClientId: kIsWeb ? null : _serverClientId,
    );
  }
}
