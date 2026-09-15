import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/safety/block_list_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/injection.dart';

/// Opens the people the user blocked.
class BlockedPeopleTile extends StatelessWidget {
  const BlockedPeopleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.block_rounded),
      title: const Text('Blocked people'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const BlockedPeoplePage())),
    );
  }
}

/// The people the user blocked, each with a way to unblock them.
class BlockedPeoplePage extends StatelessWidget {
  const BlockedPeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final blockList = getIt<BlockListBloc>();
    final muted = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked people')),
      body: BlocBuilder<BlockListBloc, BlockListState>(
        bloc: blockList,
        builder: (context, state) {
          final ids = state.blocks.blockedUserIds;
          if (ids.isEmpty) {
            return Center(
              child: Text('You haven\'t blocked anyone.', style: muted),
            );
          }
          return BlocProvider(
            key: ValueKey(ids.map((id) => id.getOrCrash()).join(',')),
            create: (_) =>
                getIt<UsersWatcherBloc>()
                  ..add(UsersWatcherEvent.watchStarted(ids.toImmutableList())),
            child: BlocBuilder<UsersWatcherBloc, UsersWatcherState>(
              builder: (context, users) => switch (users) {
                UsersWatcherLoadSuccess(:final users) => ListView(
                  children: [
                    for (final id in ids)
                      _BlockedPerson(
                        userId: id,
                        user: users.firstOrNull((user) => user.id == id),
                        unblocking: state.changing.contains(id.getOrCrash()),
                        onUnblock: () =>
                            blockList.add(BlockListEvent.unblockRequested(id)),
                      ),
                  ],
                ),
                UsersWatcherLoadFailure() => Center(
                  child: Text(
                    'Blocked people couldn\'t be loaded.',
                    style: muted,
                  ),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          );
        },
      ),
    );
  }
}

class _BlockedPerson extends StatelessWidget {
  final UniqueId userId;
  final User? user;
  final bool unblocking;
  final VoidCallback onUnblock;

  const _BlockedPerson({
    required this.userId,
    required this.user,
    required this.unblocking,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    return ListTile(
      leading: CircleAvatar(
        foregroundImage: user == null
            ? null
            : NetworkImage(user.imageUrl.getOrCrash()),
      ),
      title: Text(user?.username.getOrCrash() ?? 'Someone'),
      trailing: TextButton(
        onPressed: unblocking ? null : onUnblock,
        child: const Text('Unblock'),
      ),
    );
  }
}
