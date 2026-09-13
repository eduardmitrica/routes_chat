import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/user/user_watcher/user_watcher_bloc.dart';
import 'package:routes_chat/presentation/home/profile/widgets/user_form.dart';

class ProfilePageBody extends StatelessWidget {
  const ProfilePageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserWatcherBloc, UserWatcherState>(
      builder: (context, state) => switch (state) {
        UserWatcherInitial() => const SizedBox(),
        UserWatcherLoadInProgress() => const Center(
          child: CircularProgressIndicator(),
        ),
        UserWatcherLoadSuccess(:final user) => UserForm(user),
        UserWatcherLoadFailure(:final failure) => Center(
          child: Center(child: Text(failure.toString())),
        ),
      },
    );
  }
}
