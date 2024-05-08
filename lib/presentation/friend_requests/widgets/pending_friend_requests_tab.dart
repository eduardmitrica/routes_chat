import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/friend_requests/pending_friend_requests_watcher/pending_friend_requests_watcher_bloc.dart';
import 'package:routes_chat/application/friend_requests/senders_or_receivers_watcher/senders_or_receivers_watcher_bloc.dart';
import 'package:routes_chat/presentation/friend_requests/widgets/pending_friend_requests_tab_body.dart';

import '../../../injection.dart';

class PendingFriendRequestsTab extends StatelessWidget {
  const PendingFriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PendingFriendRequestsWatcherBloc,
        PendingFriendRequestsWatcherState>(
      builder: (context, state) {
        return state.map(
          initial: (state) => const SizedBox(),
          loadInProgress: (state) => const Center(
            child: CircularProgressIndicator(),
          ),
          loadSuccess: (state) => BlocProvider(
            create: (context) => getIt<SendersOrReceiversWatcherBloc>()
              ..add(
                SendersOrReceiversWatcherEvent.watchStarted(
                  state.friendRequests
                      .map((friendRequest) => friendRequest.receiverId),
                ),
              ),
            child: PendingFriendRequestsTabBody(
                state.friendRequests,
                BlocProvider.of<PendingFriendRequestsWatcherBloc>(context)
                    .refreshSubscription),
          ),
          loadFailure: (state) => Center(
            child: Text(state.failure.toString()),
          ),
        );
      },
    );
  }
}
