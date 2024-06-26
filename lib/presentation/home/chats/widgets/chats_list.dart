import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_page.dart';

import '../../../../application/chats/chats_watcher/chats_watcher_bloc.dart';

class ChatsList extends StatelessWidget {
  final KtList<Chat> chats;
  final ValueGetter<Future<void>> onRefresh;

  const ChatsList(this.chats, this.onRefresh, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersWatcherBloc, UsersWatcherState>(
      builder: (context, state) => state.map(
        initial: (state) => const SizedBox(),
        loadInProgress: (state) => const Center(
          child: CircularProgressIndicator(),
        ),
        loadSuccess: (state) {
          if (chats.size == 0) {
            return const Center(
              child: Text('No chats so far'),
            );
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
                    (user) => participantsIds.contains(
                      user.id.getOrCrash(),
                    ),
                  );

                  return ListTile(
                    key: ValueKey(
                      chat.id.getOrCrash(),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => BlocProvider.value(
                          value: BlocProvider.of<ChatsWatcherBloc>(context),
                          child: const ChatPage(),
                        ),
                        settings:
                            RouteSettings(arguments: chatParticipants.first()),
                      ),
                    ),
                    leading: chatParticipants.size == 1
                        ? CircleAvatar(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundImage: NetworkImage(
                                chatParticipants.first().imageUrl.getOrCrash()),
                          )
                        : null,
                    title: chatParticipants.size == 1
                        ? Text(chatParticipants.first().username.getOrCrash())
                        : Text('Chat with ${chatParticipants.size}'),
                    subtitle: Text(chat.lastMessage.content.getOrCrash()),
                  );
                },
              ),
            );
          }
        },
        loadFailure: (state) => Center(
          child: Text(
            state.failure.toString(),
          ),
        ),
      ),
    );
  }
}
