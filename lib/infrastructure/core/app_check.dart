import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

import 'environment.dart';

/// Starts App Check, which gives each request to Firestore and Storage a
/// token saying it comes from this app, on a genuine phone. Once App Check is
/// enforced in the Firebase console, requests without one are refused, such
/// as from a script or a modified app with a user's sign-in.
///
/// Release builds prove it with Play Integrity on Android and App Attest on
/// iOS (DeviceCheck before iOS 14). Debug and profile builds use the debug
/// provider with [Environment.appCheckDebugToken], which must be registered
/// in the console; they would be refused otherwise.
Future<void> activateAppCheck() async {
  final debugToken = Environment.appCheckDebugToken.isEmpty
      ? null
      : Environment.appCheckDebugToken;
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kReleaseMode
          ? const AndroidPlayIntegrityProvider()
          : AndroidDebugProvider(debugToken: debugToken),
      providerApple: kReleaseMode
          ? const AppleAppAttestWithDeviceCheckFallbackProvider()
          : AppleDebugProvider(debugToken: debugToken),
    );
  } on Exception catch (exception) {
    // Nothing is refused while App Check is not enforced; once it is, the
    // requests themselves say what went wrong.
    debugPrint('App Check not started: ${exception.runtimeType}');
  }
}
