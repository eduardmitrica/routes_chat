import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/authentication/shared/placeholder_fetcher_bloc.dart';
import 'package:routes_chat/application/friend_requests/friend_request_actor/friend_request_actor_bloc.dart';
import 'package:routes_chat/application/friend_requests/senders_or_receivers_watcher/senders_or_receivers_watcher_bloc.dart';

import '../../../domain/friend_requests/friend_request.dart';
import '../../../injection.dart';

class PendingFriendRequestsTabBody extends StatelessWidget {
  final KtList<FriendRequest> pendingFriendRequest;
  final ValueGetter<Future<void>> onRefresh;

  const PendingFriendRequestsTabBody(this.pendingFriendRequest, this.onRefresh,
      {super.key});

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
                    itemCount: pendingFriendRequest.size,
                    itemBuilder: (context, index) {
                      final friendRequest = pendingFriendRequest[index];
                      final receivingUser = state.friendRequests.find((user) =>
                          user.id.getOrCrash() ==
                          friendRequest.receiverId.getOrCrash());
                      if (friendRequest.failureOption.isSome()) {
                        return ListTile(
                          key: UniqueKey(),
                          title: const Text('Fucked up'),
                        );
                      } else {
                        return ListTile(
                          key: ValueKey(friendRequest.id.getOrCrash()),
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
                                              receivingUser?.imageUrl
                                                  .getOrCrash() ??
                                                  getIt<PlaceholderFetcherBloc>()
                                                      .state
                                                      .imagePath
                                                      .getOrCrash()),
                                        ),
                                        const SizedBox(height: 10,),
                                        Text(receivingUser?.username.getOrCrash() ?? '', style: const TextStyle(color: Colors.deepPurpleAccent),),
                                        const SizedBox(height: 10),
                                        Text(receivingUser?.description.getOrCrash() ?? ''),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundImage: NetworkImage(
                                  receivingUser?.imageUrl.getOrCrash() ??
                                      getIt<PlaceholderFetcherBloc>()
                                          .state
                                          .imagePath
                                          .getOrCrash()),
                            ),
                          ),
                          title:
                              Text(receivingUser?.username.getOrCrash() ?? ''),
                          subtitle: Text(
                              receivingUser?.description.getOrCrash() ?? ''),
                          trailing: BlocProvider<FriendRequestActorBloc>(
                            create: (_) => getIt<FriendRequestActorBloc>(),
                            child: BlocBuilder<FriendRequestActorBloc,
                                FriendRequestActorState>(
                              builder: (context, state) {
                                return IconButton(
                                  onPressed: () =>
                                      BlocProvider.of<FriendRequestActorBloc>(
                                              context)
                                          .add(FriendRequestActorEvent.declined(
                                              friendRequest)),
                                  icon: const Icon(Icons.cancel),
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
