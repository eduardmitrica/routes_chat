import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/domain/shared/user/user_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';
import 'package:routes_chat/injection.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_page.dart';

class SearchPageBody extends StatelessWidget {
  final searchController = TextEditingController(text: '');

  SearchPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendRequestActorBloc, FriendRequestActorState>(
      listener: (context, state) {
        switch (state) {
          case FriendRequestActorSendingSuccess():
            showDialog<String>(
              context: context,
              builder: (context) => Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Request has been successfully sent.'),
                      const SizedBox(height: 5),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            );
            searchController.clear();
          case FriendRequestActorResetToInitial():
            searchController.clear();
          default:
            break;
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: searchController,
                  onChanged: (value) => BlocProvider.of<FriendRequestActorBloc>(
                    context,
                  ).add(const FriendRequestActorEvent.usernameChanged()),
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) => switch (BlocProvider.of<
                        FriendRequestActorBloc
                      >(context)
                      .state) {
                    FriendRequestActorSendingFailure() =>
                      'Hmm...Make sure that the username is correct',
                    FriendRequestActorRequestAlreadySent() =>
                      'You\'ve already sent a request to this user',
                    FriendRequestActorAlreadyFriends() =>
                      'You are already friends with this user',
                    FriendRequestActorFriendRequestAlreadySentFromReceiver() =>
                      'This user has already sent a request to you',
                    _ => null,
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(height: 20.0),
                FilledButton(
                  onPressed: state is FriendRequestActorActionInProgress
                      ? null
                      : () => BlocProvider.of<FriendRequestActorBloc>(context)
                            .add(
                              FriendRequestActorEvent.sent(
                                searchController.text,
                              ),
                            ),
                  child: const Text('Send friend request'),
                ),
                const SizedBox(height: 8.0),
                _MessageButton(username: searchController),
                const SizedBox(height: 4.0),
                Text(
                  'You can write to anyone. Until they accept, your message '
                  'waits in their requests.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (state is FriendRequestActorActionInProgress)
                  const LinearProgressIndicator()
                else
                  const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Opens a chat with the person whose username is typed, friend or not. What
/// is sent waits in their requests until they accept it.
class _MessageButton extends StatefulWidget {
  final TextEditingController username;

  const _MessageButton({required this.username});

  @override
  State<_MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends State<_MessageButton> {
  var _looking = false;

  Future<void> _open() async {
    final username = Username(widget.username.text.trim());
    if (!username.isValid()) {
      _tell('Type a username first.');
      return;
    }
    setState(() => _looking = true);
    final found = await getIt<IUserRepository>().findUserByUsername(username);
    if (!mounted) return;
    setState(() => _looking = false);
    found.fold(
      (_) => _tell('No one goes by that username.'),
      (user) => _openChatWith(user),
    );
  }

  void _openChatWith(User user) {
    widget.username.clear();
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                getIt<ChatsWatcherBloc>()
                  ..add(const ChatsWatcherEvent.watchAllStarted()),
            child: const ChatPage(),
          ),
          settings: RouteSettings(arguments: user),
        ),
      ),
    );
  }

  void _tell(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: _looking ? null : () => unawaited(_open()),
    icon: const Icon(Icons.chat_bubble_outline_rounded),
    label: const Text('Message'),
  );
}
