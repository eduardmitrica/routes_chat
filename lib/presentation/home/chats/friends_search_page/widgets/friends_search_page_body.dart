import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chats_watcher/chats_watcher_bloc.dart';
import 'package:routes_chat/presentation/home/chats/widgets/chat_page.dart';

import '../../../../../application/shared/picture_placeholder_fetcher/placeholder_fetcher_bloc.dart';
import '../../../../../application/shared/users_watcher/users_watcher_bloc.dart';
import '../../../../../domain/friend_requests/friend_request.dart';
import '../../../../../injection.dart';

class FriendsSearchPageBody extends StatefulWidget {
  final KtList<FriendRequest> acceptedFriendRequests;

  const FriendsSearchPageBody(this.acceptedFriendRequests, {super.key});

  @override
  State<FriendsSearchPageBody> createState() => _FriendsSearchPageBodyState();
}

class _FriendsSearchPageBodyState extends State<FriendsSearchPageBody> {
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: widget.acceptedFriendRequests.failureOption.isNone()
          ? Column(
              children: [
                TextField(
                  controller: textController,
                  onChanged: (value) {
                    setState(() {
                      textController.text = value;
                    });
                  },
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search your friends',
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<UsersWatcherBloc, UsersWatcherState>(
                  builder: (context, state) => switch (state) {
                    UsersWatcherInitial() => const SizedBox(),
                    UsersWatcherLoadInProgress() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    UsersWatcherLoadSuccess(:final users) => Expanded(
                      child: users.size > 0
                          ? users.find(
                                      (user) => user.username
                                          .getOrCrash()
                                          .toLowerCase()
                                          .contains(
                                            textController.text.toLowerCase(),
                                          ),
                                    ) !=
                                    null
                                ? ListView.builder(
                                    itemCount:
                                        widget.acceptedFriendRequests.size,
                                    itemBuilder: (context, index) {
                                      final friendRequest =
                                          widget.acceptedFriendRequests[index];
                                      final user = users.find(
                                        (user) =>
                                            (user.id.getOrCrash() ==
                                                    friendRequest.receiverId
                                                        .getOrCrash() &&
                                                user.id.getOrCrash() !=
                                                    friendRequest.senderId
                                                        .getOrCrash()) ||
                                            (user.id.getOrCrash() ==
                                                    friendRequest.senderId
                                                        .getOrCrash() &&
                                                user.id.getOrCrash() !=
                                                    friendRequest.receiverId
                                                        .getOrCrash()),
                                      );

                                      if (friendRequest.failureOption
                                          .isSome()) {
                                        return ListTile(
                                          key: UniqueKey(),
                                          title: const Text('Error occurred'),
                                        );
                                      } else {
                                        if (user?.username
                                                .getOrCrash()
                                                .toLowerCase()
                                                .contains(
                                                  textController.text
                                                      .toLowerCase(),
                                                ) ??
                                            false) {
                                          return ListTile(
                                            key: ValueKey(
                                              friendRequest.id.getOrCrash(),
                                            ),
                                            leading: CircleAvatar(
                                              foregroundImage: NetworkImage(
                                                user?.imageUrl.getOrCrash() ??
                                                    getIt<
                                                          PlaceholderFetcherBloc
                                                        >()
                                                        .state
                                                        .imagePath
                                                        .getOrCrash(),
                                              ),
                                            ),
                                            title: Text(
                                              user?.username.getOrCrash() ?? '',
                                            ),
                                            subtitle: Text(
                                              user?.description.getOrCrash() ??
                                                  '',
                                            ),
                                            onTap: () => user != null
                                                ? Navigator.of(
                                                    context,
                                                  ).pushReplacement(
                                                    MaterialPageRoute(
                                                      builder: (ctx) =>
                                                          BlocProvider.value(
                                                            value:
                                                                BlocProvider.of<
                                                                  ChatsWatcherBloc
                                                                >(context),
                                                            child:
                                                                const ChatPage(),
                                                          ),
                                                      settings: RouteSettings(
                                                        arguments: user,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          );
                                        } else {
                                          return Container();
                                        }
                                      }
                                    },
                                  )
                                : const Center(
                                    child: Text(
                                      'Sorry, we could not find the user you were searching for',
                                    ),
                                  )
                          : const Center(
                              child: Text(
                                'You have no contacts so far. Start adding some',
                              ),
                            ),
                    ),
                    UsersWatcherLoadFailure(:final failure) => Center(
                      child: Text(failure.toString()),
                    ),
                  },
                ),
              ],
            )
          : const Center(child: Text('Failed')),
    );
  }
}
