import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'environment.dart';

/// google_sign_in 7.x requires a one-time [GoogleSignIn.initialize] call before
/// any authentication attempt. On Android the server client id (the OAuth 2.0
/// "Web application" client, `GOOGLE_SERVER_CLIENT_ID`) is what makes
/// `GoogleSignInAuthentication.idToken` available, which Firebase needs to build
/// a Google credential.
class GoogleSignInInitializer {
  const GoogleSignInInitializer._();

  static Future<void> ensureInitialized() async {
    final isIOS =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    await GoogleSignIn.instance.initialize(
      clientId: isIOS ? Environment.googleIosClientId : null,
      serverClientId: kIsWeb ? null : Environment.googleServerClientId,
    );
  }
}
