import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/injection.dart';

import 'widgets/chats_list.dart';

/// The chats waiting to be accepted or deleted: first messages from people
/// who are not the user's friends. Opening one shows the chat with Accept,
/// Delete and Block in place of the message box.
class RequestsPage extends StatefulWidget {
  static const requestsPageRoute = '/home/chats/requests';

  const RequestsPage({super.key});

  /// Opens the requests, with the blocs the chats list needs. [chats] is the
  /// caller's chats bloc when it has one; otherwise a new one starts.
  static Route<void> route({ChatsWatcherBloc? chats}) => MaterialPageRoute(
    settings: const RouteSettings(name: requestsPageRoute),
    builder: (_) => MultiBlocProvider(
      providers: [
        if (chats == null)
          BlocProvider(
            create: (_) =>
                getIt<ChatsWatcherBloc>()
                  ..add(const ChatsWatcherEvent.watchAllStarted()),
          )
        else
          BlocProvider.value(value: chats),
        BlocProvider(create: (_) => getIt<UsersWatcherBloc>()),
      ],
      child: const RequestsPage(),
    ),
  );

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  @override
  void initState() {
    super.initState();
    // The chats are usually loaded before this page opens, so the people in
    // them are looked up now; the listener keeps up with later changes.
    _lookUpPeople(context.read<ChatsWatcherBloc>().state);
  }

  void _lookUpPeople(ChatsWatcherState state) {
    if (state is ChatsWatcherLoadSuccess) {
      context.read<UsersWatcherBloc>().add(
        UsersWatcherEvent.watchStarted(state.friendsThatCurrentUserHasChatsTo),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: BlocConsumer<ChatsWatcherBloc, ChatsWatcherState>(
        listener: (context, state) => _lookUpPeople(state),
        builder: (context, state) => switch (state) {
          ChatsWatcherLoadSuccess(:final requests) =>
            requests.isEmpty()
                ? Center(child: Text('No message requests.', style: muted))
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: ChatsList(
                      requests,
                      BlocProvider.of<ChatsWatcherBloc>(
                        context,
                      ).refreshSubscription,
                    ),
                  ),
          ChatsWatcherLoadFailure() => Center(
            child: Text('Requests couldn\'t be loaded.', style: muted),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
