import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:routes_chat/application/friend_requests/pending_friend_requests_watcher/pending_friend_requests_watcher_bloc.dart';
import 'package:routes_chat/application/friend_requests/received_friend_requests_watcher/received_friend_requests_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/injection.dart';
import 'package:routes_chat/presentation/home/friend_requests/widgets/pending_friend_requests_tab.dart';
import 'package:routes_chat/presentation/home/friend_requests/widgets/received_friend_requests_tab.dart';

class FriendRequestsPage extends StatelessWidget {
  const FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Received',
              ),
              Tab(
                text: 'Pending',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => getIt<ReceivedFriendRequestsWatcherBloc>()
                    ..add(
                      const ReceivedFriendRequestsWatcherEvent
                          .watchAllStarted(),
                    ),
                ),
                BlocProvider(
                  create: (_) => getIt<UsersWatcherBloc>(),
                ),
              ],
              child: const ReceivedFriendRequestsTab(),
            ),
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => getIt<PendingFriendRequestsWatcherBloc>()
                    ..add(
                      const PendingFriendRequestsWatcherEvent.watchAllStarted(),
                    ),
                ),
                BlocProvider(
                  create: (_) => getIt<UsersWatcherBloc>(),
                )
              ],
              child: const PendingFriendRequestsTab(),
            ),
          ],
        ),
      ),
    );
  }
}
