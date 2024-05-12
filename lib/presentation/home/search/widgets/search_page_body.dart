import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart';

class SearchPageBody extends StatelessWidget {
  final searchController = TextEditingController(text: '');

  SearchPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendRequestActorBloc, FriendRequestActorState>(
      listener: (context, state) {
        state.maybeMap(
            sendingSuccess: (state) {
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
            },
            resetToInitial: (state) {
              searchController.clear();
            },
            orElse: () {});
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: searchController,
                  onChanged: (value) =>
                      BlocProvider.of<FriendRequestActorBloc>(context)
                          .add(const FriendRequestActorEvent.usernameChanged()),
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) => BlocProvider.of<FriendRequestActorBloc>(
                          context)
                      .state
                      .maybeMap(
                          sendingFailure: (state) =>
                              'Hmm...Make sure that the username is correct',
                          requestAlreadySent: (state) =>
                              'You\'ve already sent a request to this user',
                          alreadyFriends: (state) =>
                              'You are already friends with this user',
                          friendRequestAlreadySentFromReceiver: (state) =>
                              'This user has already sent a request to you',
                          orElse: () => null),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  onPressed: () =>
                      BlocProvider.of<FriendRequestActorBloc>(context).add(
                    FriendRequestActorEvent.sent(searchController.text),
                  ),
                  child: const Text('Send friend request'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
