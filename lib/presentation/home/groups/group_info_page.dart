import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/groups/group_actor_bloc.dart';
import 'package:routes_chat/application/groups/groups_watcher_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/domain/groups/group_failure.dart';
import 'package:routes_chat/domain/groups/group_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/injection.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';

import '../home_page.dart';
import 'edit_group_profile_page.dart';
import 'new_group_page.dart';
import 'widgets/group_avatar.dart';

/// Who is in a group, who manages it, and what the user may change: adding
/// people, taking them out, admins, and leaving.
class GroupInfoPage extends StatefulWidget {
  static const groupInfoPageRoute = '/home/groups/info';

  final UniqueId groupId;

  const GroupInfoPage({super.key, required this.groupId});

  static Route<void> route(UniqueId groupId) => MaterialPageRoute(
    settings: const RouteSettings(name: groupInfoPageRoute),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GroupActorBloc(getIt<IGroupRepository>(), groupId),
        ),
        BlocProvider(create: (_) => getIt<UsersWatcherBloc>()),
      ],
      child: GroupInfoPage(groupId: groupId),
    ),
  );

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final _groups = getIt<GroupsWatcherBloc>();
  final String? _myId = getIt<ICurrentUserSession>().current?.id;
  Set<String>? _lookedUp;

  Group? _group(GroupsWatcherState state) => state.joined.find(
    (group) => group.id.getOrCrash() == widget.groupId.getOrCrash(),
  );

  void _lookUpNames(Group group) {
    final everyone = {...group.everyone, ...group.invitedBy.values};
    final lookedUp = _lookedUp;
    if (lookedUp != null && setEquals(everyone, lookedUp)) return;
    _lookedUp = everyone;
    context.read<UsersWatcherBloc>().add(
      UsersWatcherEvent.watchStarted(
        everyone.map(UniqueId.fromUniqueString).toImmutableList(),
      ),
    );
  }

  void _tell(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  static String _failureText(GroupFailure failure) => switch (failure) {
    GroupInsufficientPermissions() =>
      'That can\'t be changed. Someone may have changed the group meanwhile.',
    GroupTooBig() => 'A group holds at most ${Group.maxMembers} people.',
    GroupMemberWithoutKeys() =>
      'Someone hasn\'t set up encryption yet, so they can\'t be in a group.',
    GroupUnexpected() =>
      'That didn\'t go through. Check your connection and try again.',
  };

  Future<void> _remove(Group group, String userId, String name) async {
    final actor = context.read<GroupActorBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Take $name out of the group?'),
        content: Text(
          '$name won\'t be able to read anything sent from now on. They '
          'aren\'t told why.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: AppTheme.destructiveButton(Theme.of(context).colorScheme),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Take out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      actor.add(GroupActorEvent.removed(UniqueId.fromUniqueString(userId)));
    }
  }

  Future<void> _leave(Group group) async {
    final actor = context.read<GroupActorBloc>();
    final last = group.memberIds.length == 1;
    final onlyAdmin = group.adminIds.length == 1 && group.isAdmin(_myId ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave the group?'),
        content: Text(
          last
              ? 'You\'re the last one in it, so the group goes away with you, '
                    'along with its invitations.'
              : onlyAdmin
              ? 'You won\'t read anything sent from now on. Since you\'re its '
                    'only admin, whoever has been in it longest becomes one.'
              : 'You won\'t read anything sent from now on.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: AppTheme.destructiveButton(Theme.of(context).colorScheme),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) actor.add(const GroupActorEvent.left());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupActorBloc, GroupActorState>(
      listenWhen: (previous, current) =>
          previous.failures != current.failures ||
          previous.left != current.left,
      listener: (context, state) {
        if (state.left) {
          Navigator.of(
            context,
          ).popUntil(ModalRoute.withName(HomePage.homePageRoute));
        } else if (state.lastFailure case final failure?) {
          _tell(_failureText(failure));
        }
      },
      child: BlocBuilder<GroupsWatcherBloc, GroupsWatcherState>(
        bloc: _groups,
        builder: (context, groups) {
          final group = _group(groups);
          if (group == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Group')),
              body: Center(
                child: Text(
                  groups.loaded
                      ? 'You\'re no longer in this group.'
                      : 'Loading…',
                ),
              ),
            );
          }
          _lookUpNames(group);
          return BlocBuilder<UsersWatcherBloc, UsersWatcherState>(
            builder: (context, users) {
              final byId = <String, User>{
                if (users is UsersWatcherLoadSuccess)
                  for (final user in users.users.iter)
                    user.id.getOrCrash(): user,
              };
              return BlocBuilder<GroupActorBloc, GroupActorState>(
                builder: (context, actor) => _info(context, group, byId, actor),
              );
            },
          );
        },
      ),
    );
  }

  Widget _info(
    BuildContext context,
    Group group,
    Map<String, User> byId,
    GroupActorState actor,
  ) {
    final theme = Theme.of(context);
    final me = _myId ?? '';
    String nameOf(String id) =>
        id == me ? 'You' : byId[id]?.username.getOrCrash() ?? '…';
    final bloc = context.read<GroupActorBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Group')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Center(child: GroupAvatar(group: group, radius: 48)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              group.titleWith([
                for (final id in group.everyone)
                  if (id != me) nameOf(id),
              ]),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              [
                group.memberIds.length == 1
                    ? '1 member'
                    : '${group.memberIds.length} members',
                if (group.invitedIds.isNotEmpty)
                  '${group.invitedIds.length} invited',
              ].join(', '),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Center(
            child: TextButton.icon(
              onPressed: () => unawaited(
                Navigator.of(
                  context,
                ).push(EditGroupProfilePage.route(group, bloc)),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit name and photo'),
            ),
          ),
          if (group.canAdd(me))
            ListTile(
              leading: const Icon(Icons.person_add_alt_1_outlined),
              title: const Text('Add people'),
              subtitle: group.room == 0
                  ? Text('The group is full at ${Group.maxMembers}.')
                  : null,
              enabled: group.room > 0,
              onTap: () => unawaited(
                Navigator.of(context).push(NewGroupPage.route(addTo: group)),
              ),
            ),
          if (group.isAdmin(me))
            SwitchListTile(
              secondary: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Only admins can add people'),
              value: group.onlyAdminsAdd,
              onChanged:
                  actor.busy.contains(GroupActorBloc.settingOnlyAdminsAdd)
                  ? null
                  : (value) =>
                        bloc.add(GroupActorEvent.onlyAdminsAddSet(value)),
            ),
          _Heading('Members'),
          for (final id in group.memberIds)
            _PersonRow(
              user: byId[id],
              name: nameOf(id),
              subtitle: group.isAdmin(id) ? 'Admin' : null,
              busy: actor.busy.contains(id),
              actions: [
                if (group.canSetAdmin(me, id, admin: true))
                  (
                    'Make admin',
                    () => bloc.add(
                      GroupActorEvent.adminSet(
                        UniqueId.fromUniqueString(id),
                        admin: true,
                      ),
                    ),
                  ),
                if (group.canSetAdmin(me, id, admin: false))
                  (
                    id == me ? 'Stop being an admin' : 'Remove as admin',
                    () => bloc.add(
                      GroupActorEvent.adminSet(
                        UniqueId.fromUniqueString(id),
                        admin: false,
                      ),
                    ),
                  ),
                if (group.canRemove(me, id))
                  (
                    'Take out of the group',
                    () => unawaited(_remove(group, id, nameOf(id))),
                  ),
              ],
            ),
          if (group.invitedIds.isNotEmpty) ...[
            _Heading('Invited'),
            for (final id in group.invitedIds)
              _PersonRow(
                user: byId[id],
                name: nameOf(id),
                subtitle: 'Added by ${nameOf(group.invitedBy[id] ?? '')}',
                busy: actor.busy.contains(id),
                actions: [
                  if (group.canRemove(me, id))
                    (
                      'Take out of the group',
                      () => unawaited(_remove(group, id, nameOf(id))),
                    ),
                ],
              ),
          ],
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: actor.busy.contains(GroupActorBloc.leaving)
                  ? null
                  : () => unawaited(_leave(group)),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Leave group'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// One person in the group, with what the user may do about them.
class _PersonRow extends StatelessWidget {
  final User? user;
  final String name;
  final String? subtitle;
  final bool busy;
  final List<(String, VoidCallback)> actions;

  const _PersonRow({
    required this.user,
    required this.name,
    required this.subtitle,
    required this.busy,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    return ListTile(
      leading: CircleAvatar(
        foregroundImage: user == null
            ? null
            : NetworkImage(user.imageUrl.getOrCrash()),
        child: const Icon(Icons.person_outline_rounded),
      ),
      title: Text(name),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: busy
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : actions.isEmpty
          ? null
          : PopupMenuButton<VoidCallback>(
              tooltip: 'Options for $name',
              onSelected: (action) => action(),
              itemBuilder: (context) => [
                for (final (label, action) in actions)
                  PopupMenuItem(value: action, child: Text(label)),
              ],
            ),
    );
  }
}
