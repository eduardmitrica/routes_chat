import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/friend_requests/received_friend_requests_watcher/received_friend_requests_watcher_bloc.dart';
import 'package:routes_chat/application/friend_requests/senders_or_receivers_watcher/senders_or_receivers_watcher_bloc.dart';
import 'package:routes_chat/presentation/friend_requests/widgets/received_friend_requests_tab_body.dart';

import '../../../injection.dart';

class ReceivedFriendRequestsTab extends StatelessWidget {
  const ReceivedFriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceivedFriendRequestsWatcherBloc,
        ReceivedFriendRequestsWatcherState>(
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
                      .map((friendRequest) => friendRequest.senderId),
                ),
              ),
            child: ReceivedFriendRequestsTabBody(
                state.friendRequests,
                BlocProvider.of<ReceivedFriendRequestsWatcherBloc>(context)
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
