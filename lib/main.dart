import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:routes_chat/presentation/core/app_widget.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';
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
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignInInitializer.ensureInitialized();
  configureDependencies();
  runApp(const AppWidget());
}
