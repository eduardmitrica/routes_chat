import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:routes_chat/presentation/core/app_widget.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';
import 'infrastructure/core/app_check.dart';
import 'infrastructure/core/environment.dart';
import 'infrastructure/core/google_sign_in_initializer.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Stop with the missing .env keys rather than an obscure Firebase error.
  Environment.ensureConfigured();
  EquatableConfig.stringify = true;
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : // App support, not the cache: Android may clear the cache, and with
          // it settings such as the chosen appearance.
          HydratedStorageDirectory(
            (await getApplicationSupportDirectory()).path,
          ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Before anything reaches Firestore or Storage, so every request carries
  // its token.
  await activateAppCheck();
  await GoogleSignInInitializer.ensureInitialized();
  configureDependencies();
  runApp(const AppWidget());
}
