import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/injection.dart';

class ChatPage extends StatelessWidget {
  static const chatPageRoute = '/home/chats/chat';

  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;
    return BlocBuilder<ChatsWatcherBloc, ChatsWatcherState>(
      builder: (context, state) {
        return state.maybeMap(
            loadSuccess: (state) {
              final chat = state.chats.find((chat) => chat.participantsList
                  .getOrCrash()
                  .map((participant) => participant.value1.getOrCrash())
                  .contains(user.id.getOrCrash()));
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded)),
                  title: Text(
                    user.username.getOrCrash(),
                    style: const TextStyle(color: Colors.deepPurpleAccent),
                  ),
                  actions: [
                    CircleAvatar(
                      foregroundImage: NetworkImage(user.imageUrl.getOrCrash()),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    if (chat == null)
                      const Expanded(
                        child: Center(
                          child: Text('You have no messages with this user'),
                        ),
                      ),
                    if (chat != null)
                      Expanded(
                        child: BubbleSpecialThree(
                          text: chat.messages.first().content.getOrCrash(),
                          color: const Color(0xFF1B97F3),
                          tail: false,
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    BlocProvider(
                      create: (context) => getIt<ChatBarBloc>(),
                      child: BlocBuilder<ChatBarBloc, ChatBarState>(
                        buildWhen: (previousState, currentState) =>
                            previousState.showErrorMessages !=
                            currentState.showErrorMessages,
                        builder: (context, state) {
                          return MessageBar(
                            messageBarColor: Colors.deepPurpleAccent,
                            messageBarHintText: 'Start typing...',
                            onTextChanged: (value) =>
                                BlocProvider.of<ChatBarBloc>(context).add(
                                    ChatBarEvent.messageContentChanged(value)),
                            onSend: (value) {
                              if (chat == null) {
                                BlocProvider.of<ChatBarBloc>(context).add(
                                    ChatBarEvent.newChatCreated(
                                        [user.id].toImmutableList()));
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            orElse: () => const Center(
                  child: CircularProgressIndicator(),
                ));
      },
    );
  }
}
