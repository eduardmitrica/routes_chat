import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chats_list.dart';

import 'friends_search_bar.dart';

class ChatsPageBody extends StatelessWidget {
  const ChatsPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsWatcherBloc, ChatsWatcherState>(
      listener: (context, state) {
        state.maybeMap(
            loadSuccess: (state) => BlocProvider.of<UsersWatcherBloc>(context)
              ..add(
                UsersWatcherEvent.watchStarted(
                    state.friendsThatCurrentUserHasChatsTo),
              ),
            orElse: () {});
      },
      builder: (context, state) => state.map(
        initial: (state) => const SizedBox(),
        loadInProgress: (state) => const Center(
          child: CircularProgressIndicator(),
        ),
        loadSuccess: (state) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const FriendsSearchBar(),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ChatsList(
                    state.chats,
                    BlocProvider.of<ChatsWatcherBloc>(context)
                        .refreshSubscription),
              ),
            ],
          ),
        ),
        loadFailure: (state) => Center(
          child: Text(state.failure.toString()),
        ),
      ),
    );
  }
}
