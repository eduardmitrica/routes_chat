import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_page.dart';

import 'chat_list_time.dart';

import '../../../../application/chats/chats_watcher/chats_watcher_bloc.dart';

class ChatsList extends StatelessWidget {
  final KtList<Chat> chats;
  final ValueGetter<Future<void>> onRefresh;

  /// The ids of the chats with messages the user has not read, which stand
  /// out.
  final Set<String> unreadChatIds;

  /// The ids of the chats with someone the user blocked.
  final Set<String> blockedChatIds;

  /// The ids of the chats whose last message stays hidden.
  final Set<String> hiddenPreviewChatIds;

  const ChatsList(
    this.chats,
    this.onRefresh, {
    super.key,
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
            if (chats.size == 0) {
              return const Center(child: Text('No chats so far'));
            } else {
              final sortedChats = chats
                  .sortedBy((chat) => chat.lastMessage.lastUpdatedAt!)
                  .reversed();
              return RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.builder(
                  itemCount: sortedChats.size,
                  itemBuilder: (context, index) {
                    final chat = sortedChats[index];
                    final participantsIds = chat.participantsList
                        .getOrCrash()
                        .map((participant) => participant.value1.getOrCrash());
                    final chatParticipants = state.users.filter(
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
                        time: sentAt == null
                            ? null
                            : chatListTime(sentAt, DateTime.now()),
                        unread: unread,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => BlocProvider.value(
                            value: BlocProvider.of<ChatsWatcherBloc>(context),
                            child: const ChatPage(),
                          ),
                          settings: RouteSettings(
                            arguments: chatParticipants.first(),
                          ),
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
                            : hiddenPreviewChatIds.contains(
                                chat.id.getOrCrash(),
                              )
                            ? 'Message hidden'
                            : chat.lastMessage.content.getOrCrash(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              );
            }
        }
      },
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
