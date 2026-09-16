import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/presentation/home/chats/requests_page.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chats_list.dart';

import 'friends_search_bar.dart';

class ChatsPageBody extends StatelessWidget {
  const ChatsPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsWatcherBloc, ChatsWatcherState>(
      listener: (context, state) {
        if (state is ChatsWatcherLoadSuccess) {
          BlocProvider.of<UsersWatcherBloc>(context).add(
            UsersWatcherEvent.watchStarted(
              state.friendsThatCurrentUserHasChatsTo,
            ),
          );
        }
      },
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
                if (requestChatIds.isNotEmpty)
                  _RequestsTile(count: requestChatIds.length),
                Expanded(
                  child: ChatsList(
                    chatsInList,
                    BlocProvider.of<ChatsWatcherBloc>(
                      context,
                    ).refreshSubscription,
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
    );
  }
}

/// Above the chats: how many people who are not friends are waiting to be
/// accepted.
class _RequestsTile extends StatelessWidget {
  final int count;

  const _RequestsTile({required this.count});

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
      subtitle: Text(
        count == 1
            ? '1 person you don\'t know wants to message you'
            : '$count people you don\'t know want to message you',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(
        RequestsPage.route(chats: BlocProvider.of<ChatsWatcherBloc>(context)),
      ),
    );
  }
}
