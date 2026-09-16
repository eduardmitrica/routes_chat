import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/groups/groups_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/injection.dart';

import 'widgets/chats_list.dart';

/// What waits for the user to decide: first messages from people who are not
/// friends, and groups someone who is not a friend added them to.
///
/// Opening a message request shows the chat with Accept, Delete and Block in
/// place of the message box. A group invitation is answered right here.
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
  /// One for the app, started in HomePage.
  final _groups = getIt<GroupsWatcherBloc>();

  var _lookedUp = const <String>{};

  @override
  void initState() {
    super.initState();
    // The chats and groups are usually loaded before this page opens, so the
    // people in them are looked up now; the listeners keep up with changes.
    _lookUpPeople();
  }

  void _lookUpPeople() {
    final chats = context.read<ChatsWatcherBloc>().state;
    final ids = <String>{
      if (chats is ChatsWatcherLoadSuccess)
        for (final id in chats.friendsThatCurrentUserHasChatsTo.iter)
          id.getOrCrash(),
      for (final group in _groups.state.invitations.iter) ...group.everyone,
    };
    if (ids.isEmpty || setEquals(ids, _lookedUp)) return;
    _lookedUp = ids;
    context.read<UsersWatcherBloc>().add(
      UsersWatcherEvent.watchStarted(
        ids.map(UniqueId.fromUniqueString).toImmutableList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChatsWatcherBloc, ChatsWatcherState>(
            listener: (context, _) => _lookUpPeople(),
          ),
          BlocListener<GroupsWatcherBloc, GroupsWatcherState>(
            bloc: _groups,
            listener: (context, _) => _lookUpPeople(),
          ),
        ],
        child: BlocBuilder<GroupsWatcherBloc, GroupsWatcherState>(
          bloc: _groups,
          builder: (context, groups) =>
              BlocBuilder<ChatsWatcherBloc, ChatsWatcherState>(
                builder: (context, state) => switch (state) {
                  ChatsWatcherLoadSuccess(:final requests)
                      when requests.isEmpty() && groups.invitations.isEmpty() =>
                    Center(child: Text('No requests.', style: muted)),
                  ChatsWatcherLoadSuccess(:final requests) => Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        if (groups.invitations.isNotEmpty())
                          _GroupInvitations(
                            invitations: groups.invitations.asList(),
                            answering: groups.answering,
                            onAccept: (id) =>
                                _groups.add(GroupsWatcherEvent.accepted(id)),
                            onDecline: (id) =>
                                _groups.add(GroupsWatcherEvent.declined(id)),
                          ),
                        if (requests.isNotEmpty())
                          Expanded(
                            child: ChatsList(
                              requests,
                              BlocProvider.of<ChatsWatcherBloc>(
                                context,
                              ).refreshSubscription,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ChatsWatcherLoadFailure() => Center(
                    child: Text('Requests couldn\'t be loaded.', style: muted),
                  ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
        ),
      ),
    );
  }
}

/// The groups the user was added to by someone who is not a friend. Their
/// messages stay unread until the user joins.
class _GroupInvitations extends StatelessWidget {
  final List<Group> invitations;
  final Set<String> answering;
  final ValueChanged<UniqueId> onAccept;
  final ValueChanged<UniqueId> onDecline;

  const _GroupInvitations({
    required this.invitations,
    required this.answering,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myId = getIt<ICurrentUserSession>().current?.id;
    return BlocBuilder<UsersWatcherBloc, UsersWatcherState>(
      builder: (context, users) {
        final names = <String, String>{
          if (users is UsersWatcherLoadSuccess)
            for (final user in users.users.iter)
              user.id.getOrCrash(): user.username.getOrCrash(),
        };
        return Column(
          children: [
            for (final group in invitations)
              Card.outlined(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              groupTitleOf([
                                for (final id in group.everyone)
                                  if (id != myId) names[id] ?? '…',
                              ]),
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${names[group.invitedBy[myId]] ?? 'Someone'} added '
                        'you to this group. You\'ll see its messages once '
                        'you join.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: answering.contains(group.id.getOrCrash())
                                ? null
                                : () => onDecline(group.id),
                            child: const Text('Turn down'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: answering.contains(group.id.getOrCrash())
                                ? null
                                : () => onAccept(group.id),
                            child: const Text('Join'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
