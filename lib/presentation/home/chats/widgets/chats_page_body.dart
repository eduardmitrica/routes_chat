import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/groups/groups_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/injection.dart';
import 'package:routes_chat/presentation/home/chats/requests_page.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chats_list.dart';

import 'friends_search_bar.dart';

class ChatsPageBody extends StatefulWidget {
  const ChatsPageBody({super.key});

  @override
  State<ChatsPageBody> createState() => _ChatsPageBodyState();
}

class _ChatsPageBodyState extends State<ChatsPageBody> {
  /// One for the app, started in HomePage.
  final _groups = getIt<GroupsWatcherBloc>();

  /// Whose names and photos are being looked up, so they are asked for again
  /// only when someone new appears.
  Set<String>? _lookedUp;

  /// Looks up everyone the list names: chat partners and people in groups.
  void _lookUpPeople() {
    final chats = context.read<ChatsWatcherBloc>().state;
    final ids = <String>{
      if (chats is ChatsWatcherLoadSuccess)
        for (final id in chats.friendsThatCurrentUserHasChatsTo.iter)
          id.getOrCrash(),
      for (final group in _groups.state.joined.iter) ...group.everyone,
    };
    final lookedUp = _lookedUp;
    if (chats is! ChatsWatcherLoadSuccess ||
        (lookedUp != null && setEquals(ids, lookedUp))) {
      return;
    }
    _lookedUp = ids;
    context.read<UsersWatcherBloc>().add(
      UsersWatcherEvent.watchStarted(
        ids.map(UniqueId.fromUniqueString).toImmutableList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
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
                ChatsWatcherInitial() => const SizedBox(),
                ChatsWatcherLoadInProgress() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ChatsWatcherLoadSuccess(
                  :final chatsInList,
                  :final requestChatIds,
                  :final unreadChatIds,
                  :final blockedChatIds,
                  :final hiddenPreviewChatIds,
                ) =>
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        const FriendsSearchBar(),
                        const SizedBox(height: 20),
                        if (requestChatIds.isNotEmpty ||
                            groups.invitations.isNotEmpty())
                          _RequestsTile(
                            chats: requestChatIds.length,
                            groups: groups.invitations.size,
                          ),
                        Expanded(
                          child: ChatsList(
                            chatsInList,
                            BlocProvider.of<ChatsWatcherBloc>(
                              context,
                            ).refreshSubscription,
                            groups: groups.joined.asList(),
                            unreadChatIds: unreadChatIds,
                            blockedChatIds: blockedChatIds,
                            hiddenPreviewChatIds: hiddenPreviewChatIds,
                          ),
                        ),
                      ],
                    ),
                  ),
                ChatsWatcherLoadFailure(:final failure) => Center(
                  child: Text(failure.toString()),
                ),
              },
            ),
      ),
    );
  }
}

/// Above the chats: people who are not friends waiting to be accepted, and
/// groups the user was added to.
class _RequestsTile extends StatelessWidget {
  final int chats;
  final int groups;

  const _RequestsTile({required this.chats, required this.groups});

  String get _subtitle => switch ((chats, groups)) {
    (1, 0) => '1 person you don\'t know wants to message you',
    (_, 0) => '$chats people you don\'t know want to message you',
    (0, 1) => 'You were added to a group',
    (0, _) => 'You were added to $groups groups',
    _ => '${chats + groups} requests',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        child: const Icon(Icons.mark_email_unread_outlined),
      ),
      title: const Text('Requests'),
      subtitle: Text(_subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(
        RequestsPage.route(chats: BlocProvider.of<ChatsWatcherBloc>(context)),
      ),
    );
  }
}
