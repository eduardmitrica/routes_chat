import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
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
      child: Column(
        children: [
          TextField(
            controller: textController,
            onChanged: (value) {
              setState(() {
                textController.text = value;
              });
            },
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                borderRadius: BorderRadius.circular(20.0),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          BlocBuilder<UsersWatcherBloc, UsersWatcherState>(
            builder: (context, state) => state.map(
              initial: (state) => const SizedBox(),
              loadInProgress: (state) => const Center(
                child: CircularProgressIndicator(),
              ),
              loadSuccess: (state) => SizedBox(
                height: 300,
                child: state.users.find((user) => user.username
                            .getOrCrash()
                            .toLowerCase()
                            .contains(textController.text.toLowerCase())) !=
                        null
                    ? ListView.builder(
                        itemCount: widget.acceptedFriendRequests.size,
                        itemBuilder: (context, index) {
                          final friendRequest =
                              widget.acceptedFriendRequests[index];
                          final user = state.users.find((user) =>
                              (user.id.getOrCrash() ==
                                      friendRequest.receiverId.getOrCrash() &&
                                  user.id.getOrCrash() !=
                                      friendRequest.senderId.getOrCrash()) ||
                              (user.id.getOrCrash() ==
                                      friendRequest.senderId.getOrCrash() &&
                                  user.id.getOrCrash() !=
                                      friendRequest.receiverId.getOrCrash()));

                          if (friendRequest.failureOption.isSome()) {
                            return ListTile(
                              key: UniqueKey(),
                              title: const Text('Fucked up'),
                            );
                          } else {
                            if (user?.username
                                    .getOrCrash()
                                    .toLowerCase()
                                    .contains(
                                        textController.text.toLowerCase()) ??
                                false) {
                              return ListTile(
                                key: ValueKey(friendRequest.id.getOrCrash()),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  foregroundImage: NetworkImage(
                                      user?.imageUrl.getOrCrash() ??
                                          getIt<PlaceholderFetcherBloc>()
                                              .state
                                              .imagePath
                                              .getOrCrash()),
                                ),
                                title: Text(user?.username.getOrCrash() ?? ''),
                                subtitle:
                                    Text(user?.description.getOrCrash() ?? ''),
                                onTap: () => user != null
                                    ? Navigator.of(context)
                                        .pushReplacementNamed(
                                            ChatPage.chatPageRoute,
                                            arguments: user)
                                    : null,
                              );
                            } else {
                              return Container();
                            }
                          }
                        })
                    : const Center(
                        child: Text(
                            'Sorry, we could not find the user you were searching for'),
                      ),
              ),
              loadFailure: (state) => Center(
                child: Text(
                  state.failure.toString(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
