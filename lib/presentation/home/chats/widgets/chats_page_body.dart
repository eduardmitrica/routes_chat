import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chats_list.dart';

import '../../../../injection.dart';
import 'friends_search_bar.dart';

class ChatsPageBody extends StatelessWidget {
  const ChatsPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsWatcherBloc, ChatsWatcherState>(
      builder: (context, state) => state.map(
        initial: (state) => const SizedBox(),
        loadInProgress: (state) => const Center(
          child: CircularProgressIndicator(),
        ),
        loadSuccess: (state) => BlocProvider(
          create: (_) => getIt<UsersWatcherBloc>()
            ..add(UsersWatcherEvent.watchStarted(
                state.friendsThatCurrentUserHasChatsTo)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const FriendsSearchBar(),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ChatsList(state.chats),
                ),
              ],
            ),
          ),
        ),
        loadFailure: (state) => Center(
          child: Text(state.failure.toString()),
        ),
      ),
    );
  }
}
