import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/authentication/authentication_bloc.dart';
import 'package:routes_chat/application/authentication/register_form/register_form_bloc.dart';
import 'package:routes_chat/application/shared/picture_placeholder_fetcher/placeholder_fetcher_bloc.dart';
import 'package:routes_chat/application/authentication/sign_in_form/sign_in_form_bloc.dart';
import 'package:routes_chat/presentation/core/routes/routes.dart';

import '../../injection.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<PlaceholderFetcherBloc>()
            ..add(
              const PlaceholderFetcherEvent.started(),
            ),
          lazy: false,
        ),
        BlocProvider(
            create: (_) => getIt<AuthenticationBloc>()
              ..add(const AuthenticationEvent.authenticationRequested())),
        BlocProvider(
          create: (_) => getIt<SignInFormBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<RegisterFormBloc>(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
          title: 'Routes Chat',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          routes: routes),
    );
  }
}
