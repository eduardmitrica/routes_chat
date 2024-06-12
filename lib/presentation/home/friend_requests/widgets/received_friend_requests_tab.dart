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
    return BlocConsumer<ReceivedFriendRequestsWatcherBloc,
        ReceivedFriendRequestsWatcherState>(
      listener: (context, state) {
        state.maybeMap(
            loadSuccess: (state) => BlocProvider.of<UsersWatcherBloc>(context)
              ..add(
                UsersWatcherEvent.watchStarted(
                  state.friendRequests
                      .map((friendRequest) => friendRequest.senderId),
                ),
              ),
            orElse: () {});
      },
      builder: (context, state) {
        return state.map(
          initial: (state) => const SizedBox(),
          loadInProgress: (state) => const Center(
            child: CircularProgressIndicator(),
          ),
          loadSuccess: (state) => ReceivedFriendRequestsTabBody(
              state.friendRequests,
              BlocProvider.of<ReceivedFriendRequestsWatcherBloc>(context)
                  .refreshSubscription),
          loadFailure: (state) => Center(
            child: Text(state.failure.toString()),
          ),
        );
      },
    );
  }
}
