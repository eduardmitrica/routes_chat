import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/chats/friends_watcher/friends_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/presentation/home/chats/friends_search_page/widgets/friends_search_page_body.dart';

import '../../../../injection.dart';

class FriendsSearchPage extends StatelessWidget {
  static const friendsSearchPageRoute = '/home/chats/friends-search-page';

  const FriendsSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<FriendsWatcherBloc>()
                ..add(const FriendsWatcherEvent.watchAllStarted()),
        ),
        BlocProvider.value(value: BlocProvider.of<ChatsWatcherBloc>(context)),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('search')),
        body: BlocBuilder<FriendsWatcherBloc, FriendsWatcherState>(
          builder: (BuildContext context, FriendsWatcherState state) {
            return switch (state) {
              FriendsWatcherInitial() => const SizedBox(),
              FriendsWatcherLoadInProgress() => const Center(
                child: CircularProgressIndicator(),
              ),
              FriendsWatcherLoadSuccess(
                :final friendRequests,
                :final friendsIds,
              ) =>
                BlocProvider(
                  create: (_) =>
                      getIt<UsersWatcherBloc>()
                        ..add(UsersWatcherEvent.watchStarted(friendsIds)),
                  child: FriendsSearchPageBody(friendRequests),
                ),
              FriendsWatcherLoadFailure(:final failure) => Center(
                child: Text(failure.toString()),
              ),
            };
          },
        ),
      ),
    );
  }
}
