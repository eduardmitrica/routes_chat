import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/authentication/shared/placeholder_fetcher_bloc.dart';

import '../../../application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart';
import '../../../application/friend_requests/senders_or_receivers_watcher/senders_or_receivers_watcher_bloc.dart';
import '../../../domain/friend_requests/friend_request.dart';
import '../../../injection.dart';

class ReceivedFriendRequestsTabBody extends StatelessWidget {
  final KtList<FriendRequest> receivedFriendRequests;
  final ValueGetter<Future<void>> onRefresh;

  const ReceivedFriendRequestsTabBody(this.receivedFriendRequests, this.onRefresh, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendersOrReceiversWatcherBloc,
        SendersOrReceiversWatcherState>(
      builder: (context, state) => state.map(
          initial: (state) => const SizedBox(),
          loadInProgress: (state) => const Center(
                child: CircularProgressIndicator(),
              ),
          loadSuccess: (state) => RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.builder(
                    itemCount: receivedFriendRequests.size,
                    itemBuilder: (context, index) {
                      final friendRequest = receivedFriendRequests[index];
                      final sendingUser = state.friendRequests.find((user) =>
                          user.id.getOrCrash() ==
                          friendRequest.senderId.getOrCrash());
                      if (friendRequest.failureOption.isSome()) {
                        return ListTile(
                          key: UniqueKey(),
                          title: const Text('Fucked up'),
                        );
                      } else {
                        return ListTile(
                          leading: InkWell(
                            borderRadius: BorderRadius.circular(20.0),
                            onTap: () {
                              showDialog<String>(
                                context: context,
                                builder: (context) => Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 80,
                                          foregroundImage: NetworkImage(
                                              sendingUser?.imageUrl
                                                  .getOrCrash() ??
                                                  getIt<PlaceholderFetcherBloc>()
                                                      .state
                                                      .imagePath
                                                      .getOrCrash()),
                                        ),
                                        const SizedBox(height: 10,),
                                        Text(sendingUser?.username.getOrCrash() ?? '', style: const TextStyle(color: Colors.deepPurpleAccent),),
                                        const SizedBox(height: 10),
                                        Text(sendingUser?.description.getOrCrash() ?? ''),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              key: ValueKey(friendRequest.id.getOrCrash()),
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundImage: NetworkImage(
                                  sendingUser?.imageUrl.getOrCrash() ??
                                      getIt<PlaceholderFetcherBloc>()
                                          .state
                                          .imagePath
                                          .getOrCrash()),
                            ),
                          ),
                          title: Text(sendingUser?.username.getOrCrash() ?? ''),
                          subtitle:
                              Text(sendingUser?.description.getOrCrash() ?? ''),
                          trailing: BlocProvider<FriendRequestActorBloc>(
                            create: (_) => getIt<FriendRequestActorBloc>(),
                            child: BlocBuilder<FriendRequestActorBloc,
                                FriendRequestActorState>(
                              builder: (context, state) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => BlocProvider.of<
                                              FriendRequestActorBloc>(context)
                                          .add(FriendRequestActorEvent.accepted(
                                              friendRequest)),
                                      icon: const Icon(Icons.check_circle),
                                    ),
                                    IconButton(
                                      onPressed: () => BlocProvider.of<
                                              FriendRequestActorBloc>(context)
                                          .add(FriendRequestActorEvent.declined(
                                              friendRequest)),
                                      icon: const Icon(Icons.cancel),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      }
                    }),
              ),
          loadFailure: (state) => Center(
                child: Text(state.failure.toString()),
              )),
    );
  }
}
