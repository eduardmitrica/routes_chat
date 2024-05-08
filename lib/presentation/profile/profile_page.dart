import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/user/user_form/user_form_bloc.dart';
import 'package:routes_chat/application/user/user_watcher/user_watcher_bloc.dart';
import 'package:routes_chat/presentation/profile/widgets/profile_page_body.dart';

import '../../injection.dart';

class ProfilePage extends StatelessWidget {
  static const profilePageRoute = '/home/profile';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserWatcherBloc>(
          create: (_) => getIt<UserWatcherBloc>()
            ..add(
              const UserWatcherEvent.watchStarted(),
            ),
        ),
        BlocProvider<UserFormBloc>.value(
          value: BlocProvider.of<UserFormBloc>(context),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const ProfilePageBody(),
      ),
    );
  }
}
