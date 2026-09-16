import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/injection.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_page.dart';
import 'package:routes_chat/presentation/home/groups/group_chat_page.dart';
import 'package:routes_chat/presentation/home/groups/widgets/group_avatar.dart';

import 'chat_list_time.dart';

import '../../../../application/chats/chats_watcher/chats_watcher_bloc.dart';

class ChatsList extends StatelessWidget {
  final KtList<Chat> chats;
  final ValueGetter<Future<void>> onRefresh;

  /// The groups the user is in, listed among the chats by when anything last
  /// happened in them.
  final List<Group> groups;

  /// The ids of the chats and groups with messages the user has not read,
  /// which stand out.
  final Set<String> unreadChatIds;

  /// The ids of the chats with someone the user blocked.
  final Set<String> blockedChatIds;

  /// The ids of the chats whose last message stays hidden.
  final Set<String> hiddenPreviewChatIds;

  const ChatsList(
    this.chats,
    this.onRefresh, {
    super.key,
    this.groups = const [],
    this.unreadChatIds = const {},
    this.blockedChatIds = const {},
    this.hiddenPreviewChatIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersWatcherBloc, UsersWatcherState>(
      builder: (context, state) {
        switch (state) {
          case UsersWatcherInitial():
            return const SizedBox();
          case UsersWatcherLoadInProgress():
            return const Center(child: CircularProgressIndicator());
          case UsersWatcherLoadFailure():
            return Center(child: Text(state.failure.toString()));
          case UsersWatcherLoadSuccess():
            if (chats.size == 0 && groups.isEmpty) {
              return const Center(child: Text('No chats so far'));
            }
            // Chats and groups together, the most recent first.
            final rows = <(DateTime?, Object)>[
              for (final chat in chats.iter)
                (chat.lastMessage.lastUpdatedAt, chat),
              for (final group in groups) (group.lastActivityAt, group),
            ]..sort((a, b) => _newestFirst(a.$1, b.$1));
            return RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) => switch (rows[index].$2) {
                  final Chat chat => _chatTile(context, state.users, chat),
                  final Group group => _GroupTile(
                    key: ValueKey(group.id.getOrCrash()),
                    group: group,
                    users: state.users,
                    unread: unreadChatIds.contains(group.id.getOrCrash()),
                  ),
                  _ => const SizedBox.shrink(),
                },
              ),
            );
        }
      },
    );
  }

  static int _newestFirst(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }

  Widget _chatTile(BuildContext context, KtList<User> users, Chat chat) {
    final participantsIds = chat.participantsList.getOrCrash().map(
      (participant) => participant.value1.getOrCrash(),
    );
    final chatParticipants = users.filter(
      (user) => participantsIds.contains(user.id.getOrCrash()),
    );

    final theme = Theme.of(context);
    final unread = unreadChatIds.contains(chat.id.getOrCrash());
    final sentAt = chat.lastMessage.lastUpdatedAt;
    return ListTile(
      key: ValueKey(chat.id.getOrCrash()),
      titleTextStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: unread ? FontWeight.w700 : null,
      ),
      subtitleTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: unread
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: unread ? FontWeight.w600 : null,
      ),
      trailing: _ChatListTrailing(
        time: sentAt == null ? null : chatListTime(sentAt, DateTime.now()),
        unread: unread,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => BlocProvider.value(
            value: BlocProvider.of<ChatsWatcherBloc>(context),
            child: const ChatPage(),
          ),
          settings: RouteSettings(arguments: chatParticipants.first()),
        ),
      ),
      leading: chatParticipants.size == 1
          ? CircleAvatar(
              foregroundImage: NetworkImage(
                chatParticipants.first().imageUrl.getOrCrash(),
              ),
            )
          : null,
      title: chatParticipants.size == 1
          ? Text(chatParticipants.first().username.getOrCrash())
          : Text('Chat with ${chatParticipants.size}'),
      subtitle: Text(
        blockedChatIds.contains(chat.id.getOrCrash())
            ? 'Blocked'
            : hiddenPreviewChatIds.contains(chat.id.getOrCrash())
            ? 'Message hidden'
            : chat.lastMessage.content.getOrCrash(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// A group in the list: who is in it, and its newest message with who sent
/// it.
class _GroupTile extends StatelessWidget {
  final Group group;
  final KtList<User> users;
  final bool unread;

  const _GroupTile({
    super.key,
    required this.group,
    required this.users,
    this.unread = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myId = getIt<ICurrentUserSession>().current?.id;
    final names = {
      for (final user in users.iter)
        user.id.getOrCrash(): user.username.getOrCrash(),
    };
    final last = group.lastMessage;
    final lastSender = last?.senderId.getOrCrash();
    final at = group.lastActivityAt;
    return ListTile(
      leading: GroupAvatar(group: group),
      title: Text(
        group.titleWith([
          for (final id in group.everyone)
            if (id != myId) names[id] ?? '…',
        ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        last == null
            ? 'No messages yet'
            : '${lastSender == myId ? 'You' : names[lastSender] ?? '…'}: '
                  '${last.content.getOrCrash()}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      titleTextStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: unread ? FontWeight.w700 : null,
      ),
      subtitleTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: unread
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: unread ? FontWeight.w600 : null,
      ),
      trailing: _ChatListTrailing(
        time: at == null ? null : chatListTime(at, DateTime.now()),
        unread: unread,
      ),
      onTap: () => Navigator.of(context).push(GroupChatPage.route(group.id)),
    );
  }
}

/// When the last message was sent, and a dot while the chat is unread.
class _ChatListTrailing extends StatelessWidget {
  final String? time;
  final bool unread;

  const _ChatListTrailing({required this.time, required this.unread});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = this.time;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (time != null)
          Text(
            time,
            style: theme.textTheme.labelMedium?.copyWith(
              color: unread
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 6),
        Semantics(
          label: unread ? 'Unread' : null,
          child: SizedBox.square(
            dimension: 10,
            child: unread
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
