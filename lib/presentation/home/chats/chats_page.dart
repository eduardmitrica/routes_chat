import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/injection.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chats_page_body.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatsWatcherBloc>()
        ..add(const ChatsWatcherEvent.watchAllStarted()),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Chats'),
          ),
          body: const ChatsPageBody()),
    );
  }
}
