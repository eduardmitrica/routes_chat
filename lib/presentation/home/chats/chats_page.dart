import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/injection.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chats_page_body.dart';
import 'package:routes_chat/presentation/home/groups/new_group_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<UsersWatcherBloc>()),
        BlocProvider(
          create: (_) =>
              getIt<ChatsWatcherBloc>()
                ..add(const ChatsWatcherEvent.watchAllStarted()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                tooltip: 'New group',
                onPressed: () =>
                    Navigator.of(context).push(NewGroupPage.route()),
                icon: const Icon(Icons.group_add_outlined),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: const ChatsPageBody(),
      ),
    );
  }
}
