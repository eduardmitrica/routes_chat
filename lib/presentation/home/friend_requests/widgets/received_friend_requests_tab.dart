import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/friend_requests/received_friend_requests_watcher/received_friend_requests_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/presentation/home/friend_requests/widgets/received_friend_requests_tab_body.dart';

class ReceivedFriendRequestsTab extends StatelessWidget {
  const ReceivedFriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      ReceivedFriendRequestsWatcherBloc,
      ReceivedFriendRequestsWatcherState
    >(
      listener: (context, state) {
        if (state is ReceivedFriendRequestsWatcherLoadSuccess) {
          BlocProvider.of<UsersWatcherBloc>(context).add(
            UsersWatcherEvent.watchStarted(
              state.friendRequests.map(
                (friendRequest) => friendRequest.senderId,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
          ReceivedFriendRequestsWatcherInitial() => const SizedBox(),
          ReceivedFriendRequestsWatcherLoadInProgress() => const Center(
            child: CircularProgressIndicator(),
          ),
          ReceivedFriendRequestsWatcherLoadSuccess(:final friendRequests) =>
            ReceivedFriendRequestsTabBody(
              friendRequests,
              BlocProvider.of<ReceivedFriendRequestsWatcherBloc>(
                context,
              ).refreshSubscription,
            ),
          ReceivedFriendRequestsWatcherLoadFailure(:final failure) => Center(
            child: Text(failure.toString()),
          ),
        };
      },
    );
  }
}
