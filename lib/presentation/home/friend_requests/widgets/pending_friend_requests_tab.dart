import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/friend_requests/pending_friend_requests_watcher/pending_friend_requests_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/presentation/home/friend_requests/widgets/pending_friend_requests_tab_body.dart';

class PendingFriendRequestsTab extends StatelessWidget {
  const PendingFriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PendingFriendRequestsWatcherBloc,
        PendingFriendRequestsWatcherState>(
      listener: (context, state) {
        state.maybeMap(
            loadSuccess: (state) => BlocProvider.of<UsersWatcherBloc>(context)
              ..add(
                UsersWatcherEvent.watchStarted(
                  state.friendRequests
                      .map((friendRequest) => friendRequest.receiverId),
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
          loadSuccess: (state) => PendingFriendRequestsTabBody(
              state.friendRequests,
              BlocProvider.of<PendingFriendRequestsWatcherBloc>(context)
                  .refreshSubscription),
          loadFailure: (state) => Center(
            child: Text(state.failure.toString()),
          ),
        );
      },
    );
  }
}
