# routes_chat

A chat app built with Flutter and Firebase, structured with Domain-Driven Design and the BLoC pattern.

## Setup

Firebase and Google client settings are read from a `.env` file at compile time, so none of them are hardcoded in the source.

1. Copy `.env.example` to `.env`, which is git-ignored, and fill in the values. You'll find them in the Firebase console under Project settings → Your apps.
2. Run the app with the file:
   ```
   flutter run --dart-define-from-file=.env
   ```
   The shared Android Studio run configuration (`main.dart`) already passes this flag. If the flag is missing, the app stops at startup and lists the missing keys.
3. Android also needs `android/app/google-services.json`, which is git-ignored. Download it from the Firebase console. Android uses it to deliver a notification while the app isn't running.

`flutterfire configure` rewrites `lib/firebase_options.dart` with literal values. If you run it, restore the committed file with `git checkout lib/firebase_options.dart`, and copy any new values into `.env` instead.

## Cloud Functions

`functions/` contains `notifyNewMessage`, which sends a push notification for every new chat message.

1. Copy `functions/.env.example` to `functions/.env` and set `FIRESTORE_DATABASE_ID`.
2. Install and test: `cd functions && npm ci && npm test`
3. Deploy: `firebase deploy --only functions`. This needs the Blaze plan and a local `firebase.json` with a `functions` entry (`"source": "functions"`, `"runtime": "nodejs22"`).

## Tests

`flutter analyze` and `flutter test` don't need a `.env` file.
