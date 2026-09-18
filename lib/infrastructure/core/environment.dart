/// Compile-time configuration from `--dart-define-from-file=.env` (see
/// `.env.example`).
///
/// Every value is a `const String.fromEnvironment`, fixed when the app is built;
/// nothing is read from disk at runtime. These are client settings, not secrets:
/// they end up inside the app either way. Keeping them out of the source is
/// about configuration, and it lets the same code build against another Firebase
/// project.
///
/// Without the flag every value is an empty string. Tests and
/// `flutter analyze` still compile, and [ensureConfigured] stops a real run
/// with the missing keys instead of an obscure Firebase error.
abstract final class Environment {
  /// Named Firestore database. This project has no `(default)` database.
  static const firestoreDatabaseId = String.fromEnvironment(
    'FIRESTORE_DATABASE_ID',
  );

  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  static const firebaseAndroidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
  );
  static const firebaseAndroidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );

  /// The iOS app's settings, also used for macOS.
  static const firebaseAppleApiKey = String.fromEnvironment(
    'FIREBASE_APPLE_API_KEY',
  );
  static const firebaseAppleAppId = String.fromEnvironment(
    'FIREBASE_APPLE_APP_ID',
  );
  static const firebaseAppleBundleId = String.fromEnvironment(
    'FIREBASE_APPLE_BUNDLE_ID',
  );

  /// The web app's settings. Windows shares its API key and auth domain.
  static const firebaseWebApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
  );
  static const firebaseWebAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const firebaseWebAuthDomain = String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN',
  );
  static const firebaseWebMeasurementId = String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
  );

  static const firebaseWindowsAppId = String.fromEnvironment(
    'FIREBASE_WINDOWS_APP_ID',
  );
  static const firebaseWindowsMeasurementId = String.fromEnvironment(
    'FIREBASE_WINDOWS_MEASUREMENT_ID',
  );

  /// The OAuth "Web application" client Google Sign-In needs on Android to
  /// return an ID token.
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );
  static const googleAndroidClientId = String.fromEnvironment(
    'GOOGLE_ANDROID_CLIENT_ID',
  );

  /// The App Check debug token this phone presents in debug and profile
  /// builds, registered in the Firebase console (App Check > Apps > Manage
  /// debug tokens). A secret: it only lives in `.env`. Optional: without it
  /// the debug provider makes a token of its own and logs it once.
  static const appCheckDebugToken = String.fromEnvironment(
    'APP_CHECK_DEBUG_TOKEN',
  );

  /// Keys a run can do without, after [values] in `.env.example`.
  static const Map<String, String> optionalValues = {
    'APP_CHECK_DEBUG_TOKEN': appCheckDebugToken,
  };

  /// Every key and its value, in the order of `.env.example`.
  static const Map<String, String> values = {
    'FIRESTORE_DATABASE_ID': firestoreDatabaseId,
    'FIREBASE_PROJECT_ID': firebaseProjectId,
    'FIREBASE_MESSAGING_SENDER_ID': firebaseMessagingSenderId,
    'FIREBASE_STORAGE_BUCKET': firebaseStorageBucket,
    'FIREBASE_ANDROID_API_KEY': firebaseAndroidApiKey,
    'FIREBASE_ANDROID_APP_ID': firebaseAndroidAppId,
    'FIREBASE_APPLE_API_KEY': firebaseAppleApiKey,
    'FIREBASE_APPLE_APP_ID': firebaseAppleAppId,
    'FIREBASE_APPLE_BUNDLE_ID': firebaseAppleBundleId,
    'FIREBASE_WEB_API_KEY': firebaseWebApiKey,
    'FIREBASE_WEB_APP_ID': firebaseWebAppId,
    'FIREBASE_WEB_AUTH_DOMAIN': firebaseWebAuthDomain,
    'FIREBASE_WEB_MEASUREMENT_ID': firebaseWebMeasurementId,
    'FIREBASE_WINDOWS_APP_ID': firebaseWindowsAppId,
    'FIREBASE_WINDOWS_MEASUREMENT_ID': firebaseWindowsMeasurementId,
    'GOOGLE_SERVER_CLIENT_ID': googleServerClientId,
    'GOOGLE_IOS_CLIENT_ID': googleIosClientId,
    'GOOGLE_ANDROID_CLIENT_ID': googleAndroidClientId,
  };

  /// The keys that had no value at compile time.
  static List<String> get missingKeys => [
    for (final entry in values.entries)
      if (entry.value.isEmpty) entry.key,
  ];

  /// Throws a [StateError] naming every missing key, if there are any.
  static void ensureConfigured() {
    final missing = missingKeys;
    if (missing.isEmpty) return;
    throw StateError(
      'Missing configuration: ${missing.join(', ')}. '
      'Copy .env.example to .env, fill it in, and run with '
      '--dart-define-from-file=.env.',
    );
  }
}
