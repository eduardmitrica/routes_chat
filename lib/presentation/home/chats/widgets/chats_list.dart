import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_page.dart';

class ChatsList extends StatelessWidget {
  final KtList<Chat> chats;

  const ChatsList(this.chats, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersWatcherBloc, UsersWatcherState>(
      builder: (context, state) => state.map(
        initial: (state) => const SizedBox(),
        loadInProgress: (state) => const Center(
          child: CircularProgressIndicator(),
        ),
        loadSuccess: (state) => chats.size == 0
            ? const Center(
                child: Text('No chats so far'),
              )
            : ListView.builder(
                itemCount: chats.size,
                itemBuilder: (context, index) {
                  final chat = chats[index];
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
                    onTap: () => Navigator.of(context).pushNamed(
                        ChatPage.chatPageRoute,
                        arguments: chatParticipants.first()),
                    title: Text('Chat with ${chatParticipants.size}'),
                  );
                },
              ),
        loadFailure: (state) => Center(
          child: Text(
            state.failure.toString(),
          ),
        ),
      ),
    );
  }
}
