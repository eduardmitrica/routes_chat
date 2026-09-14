import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/chats/messages/messages_watcher/messages_watcher_bloc.dart';
import 'package:routes_chat/domain/chats/chat_failure.dart' as chat_failure;
import 'package:routes_chat/domain/chats/messages/message_failure.dart'
    as message_failure;
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
        if (state is! ChatsWatcherLoadSuccess) {
          return const Center(child: CircularProgressIndicator());
        }
        {
          final chat = state.chats.find(
            (chat) => chat.participantsList
                .getOrCrash()
                .map((participant) => participant.value1.getOrCrash())
                .contains(user.id.getOrCrash()),
          );
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
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
                    child: BlocProvider(
                      create: (_) => getIt<MessagesWatcherBloc>()
                        ..add(
                          MessagesWatcherEvent.watchAllStartedForChatWithId(
                            chat.id,
                          ),
                        ),
                      child:
                          BlocBuilder<
                            MessagesWatcherBloc,
                            MessagesWatcherState
                          >(
                            builder: (context, state) {
                              return switch (state) {
                                MessagesWatcherInitial() => const SizedBox(),
                                MessagesWatcherLoadInProgress() => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                MessagesWatcherLoadSuccess(:final messages) =>
                                  ListView.builder(
                                    itemCount: messages.size,
                                    itemBuilder: (context, index) {
                                      final message = messages[index];
                                      return BubbleSpecialThree(
                                        color: Colors.deepPurpleAccent,
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        tail: false,
                                        text: message.content.getOrCrash(),
                                        isSender:
                                            message.senderId.getOrCrash() !=
                                            user.id.getOrCrash(),
                                      );
                                    },
                                  ),
                                MessagesWatcherLoadFailure(:final failure) =>
                                  Center(child: Text(failure.toString())),
                              };
                            },
                          ),
                    ),
                  ),
                const SizedBox(height: 20),
                BlocProvider(
                  create: (context) => getIt<ChatBarBloc>(),
                  child: BlocConsumer<ChatBarBloc, ChatBarState>(
                    listenWhen: (previousState, currentState) =>
                        previousState.chatCreationFailureOrSuccessOption !=
                            currentState.chatCreationFailureOrSuccessOption ||
                        previousState.messageSendFailureOrSuccessOption !=
                            currentState.messageSendFailureOrSuccessOption,
                    listener: (context, state) {
                      final failureMessage = _sendFailureMessage(state);
                      if (failureMessage != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(failureMessage)));
                      }
                    },
                    buildWhen: (previousState, currentState) =>
                        previousState.showErrorMessages !=
                        currentState.showErrorMessages,
                    builder: (context, state) {
                      return MessageBar(
                        messageBarColor: Colors.deepPurpleAccent,
                        messageBarHintText: 'Start typing...',
                        onTextChanged: (value) => BlocProvider.of<ChatBarBloc>(
                          context,
                        ).add(ChatBarEvent.messageContentChanged(value)),
                        onSend: (value) {
                          if (chat == null) {
                            BlocProvider.of<ChatBarBloc>(context).add(
                              ChatBarEvent.newChatCreated(
                                [user.id].toImmutableList(),
                              ),
                            );
                          } else if (value.isNotEmpty) {
                            BlocProvider.of<ChatBarBloc>(context).add(
                              ChatBarEvent.newMessageAddedToChatWithId(
                                value,
                                chat.id,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

/// The snackbar text for the chat bar's latest failed send, or null when the
/// latest send succeeded or nothing has been sent since the last keystroke.
///
/// The message bar clears its text as soon as Send is tapped, so this is the
/// only sign a message did not go through.
String? _sendFailureMessage(ChatBarState state) {
  final chat_failure.ChatFailure? chatFailure = state
      .chatCreationFailureOrSuccessOption
      .fold(
        () => null,
        (either) => either.fold((failure) => failure, (_) => null),
      );
  if (chatFailure != null) {
    return switch (chatFailure) {
      chat_failure.InsufficientPermissions() =>
        'You are not allowed to start this chat',
      chat_failure.Unexpected() => 'The chat could not be started, try again',
    };
  }

  final message_failure.MessageFailure? messageFailure = state
      .messageSendFailureOrSuccessOption
      .fold(
        () => null,
        (either) => either.fold((failure) => failure, (_) => null),
      );
  return switch (messageFailure) {
    null => null,
    message_failure.InsufficientPermissions() =>
      'You are not allowed to send messages in this chat',
    message_failure.Unexpected() => 'The message could not be sent, try again',
  };
}
