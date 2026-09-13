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
                ElevatedButton(
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
