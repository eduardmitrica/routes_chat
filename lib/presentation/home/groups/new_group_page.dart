import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/chats/friends_watcher/friends_watcher_bloc.dart';
import 'package:routes_chat/application/groups/new_group_bloc.dart';
import 'package:routes_chat/application/shared/users_watcher/users_watcher_bloc.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/domain/groups/group_failure.dart';
import 'package:routes_chat/domain/groups/group_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/user.dart';
import 'package:routes_chat/domain/shared/user/user_repository_interface.dart';
import 'package:routes_chat/domain/shared/user/value_objects.dart';
import 'package:routes_chat/injection.dart';

import 'group_chat_page.dart';

/// Choosing who is in a new group, or who to add to [addTo]: friends, and
/// anyone else by username. Friends join straight away; anyone else is asked
/// first. Someone added to a group gets its history as the user chooses.
class NewGroupPage extends StatefulWidget {
  static const newGroupPageRoute = '/home/groups/new';

  /// The group people are added to; null for a new group.
  final Group? addTo;

  const NewGroupPage({super.key, this.addTo});

  static Route<void> route({Group? addTo}) => MaterialPageRoute(
    settings: const RouteSettings(name: newGroupPageRoute),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              NewGroupBloc(getIt<IGroupRepository>(), capacity: addTo?.room),
        ),
        BlocProvider(
          create: (_) =>
              getIt<FriendsWatcherBloc>()
                ..add(const FriendsWatcherEvent.watchAllStarted()),
        ),
        BlocProvider(create: (_) => getIt<UsersWatcherBloc>()),
      ],
      child: NewGroupPage(addTo: addTo),
    ),
  );

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  final _username = TextEditingController();

  /// People found by username, who are not among the friends listed.
  final _found = <User>[];
  var _looking = false;

  /// How much of the group's past people added can read. Nothing, unless the
  /// user chooses otherwise.
  var _history = HistoryShare.none;

  bool get _adding => widget.addTo != null;

  /// Whether [user] is in the group people are added to already.
  bool _inGroup(User user) =>
      widget.addTo?.everyone.contains(user.id.getOrCrash()) ?? false;

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _addByUsername() async {
    final username = Username(_username.text.trim());
    if (!username.isValid()) {
      _tell('Type a username first.');
      return;
    }
    setState(() => _looking = true);
    final found = await getIt<IUserRepository>().findUserByUsername(username);
    if (!mounted) return;
    setState(() => _looking = false);
    found.fold((_) => _tell('No one goes by that username.'), (user) {
      if (_inGroup(user)) {
        _tell('${user.username.getOrCrash()} is in this group already.');
        return;
      }
      final bloc = context.read<NewGroupBloc>();
      if (!bloc.state.isChosen(user.id)) {
        bloc.add(NewGroupEvent.personToggled(user.id));
      }
      setState(() {
        if (!_found.any((other) => other.id == user.id)) _found.add(user);
        _username.clear();
      });
    });
  }

  void _tell(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  String _failureText(
    GroupFailure failure,
    Map<String, String> names,
  ) => switch (failure) {
    GroupMemberWithoutKeys(:final userId) =>
      '${names[userId] ?? 'Someone you chose'} hasn\'t set up encryption '
          'yet, so they can\'t be in a group.',
    GroupTooBig() =>
      'A group holds at most ${Group.maxMembers} people, you included.',
    GroupInsufficientPermissions() =>
      _adding
          ? 'You can\'t add people to this group.'
          : 'The group couldn\'t be started. Try again.',
    GroupUnexpected() =>
      '${_adding ? 'They couldn\'t be added' : 'The group couldn\'t be started'}. '
          'Check your connection and try again.',
  };

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // The friends' names and photos are looked up once they are known.
        BlocListener<FriendsWatcherBloc, FriendsWatcherState>(
          listener: (context, state) {
            if (state is FriendsWatcherLoadSuccess) {
              context.read<UsersWatcherBloc>().add(
                UsersWatcherEvent.watchStarted(state.friendsIds),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<UsersWatcherBloc, UsersWatcherState>(
        builder: (context, users) {
          final allFriends = users is UsersWatcherLoadSuccess
              ? users.users.asList()
              : const <User>[];
          final friends = [
            for (final user in allFriends)
              if (!_inGroup(user)) user,
          ];
          final people = [
            ...friends,
            for (final user in _found)
              if (!friends.any((friend) => friend.id == user.id)) user,
          ];
          final names = {
            for (final person in people)
              person.id.getOrCrash(): person.username.getOrCrash(),
          };
          return BlocConsumer<NewGroupBloc, NewGroupState>(
            listenWhen: (previous, current) =>
                previous.createdId != current.createdId ||
                previous.failures != current.failures,
            listener: (context, state) {
              final created = state.createdId;
              if (created != null && _adding) {
                Navigator.of(context).pop();
              } else if (created != null) {
                unawaited(
                  Navigator.of(
                    context,
                  ).pushReplacement(GroupChatPage.route(created)),
                );
              } else if (state.failure case final failure?) {
                _tell(_failureText(failure, names));
              }
            },
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text(_adding ? 'Add people' : 'New group')),
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        _UsernameField(
                          controller: _username,
                          looking: _looking,
                          onAdd: () => unawaited(_addByUsername()),
                        ),
                        const _Heading('Friends join straight away'),
                        if (users is UsersWatcherLoadInProgress)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (friends.isEmpty)
                          _Muted(
                            allFriends.isNotEmpty
                                ? 'Your friends are all in it already.'
                                : 'No friends yet.',
                          ),
                        for (final friend in friends)
                          _PersonTile(user: friend, state: state),
                        if (_found.any(
                          (user) => !friends.any((f) => f.id == user.id),
                        )) ...[
                          const _Heading(
                            'Asked first, since you\'re not friends',
                          ),
                          for (final user in _found)
                            if (!friends.any((f) => f.id == user.id))
                              _PersonTile(user: user, state: state),
                        ],
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_adding) ...[
                            _HistoryChoice(
                              value: _history,
                              onChanged: state.creating
                                  ? null
                                  : (history) =>
                                        setState(() => _history = history),
                            ),
                            const SizedBox(height: 12),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: state.canCreate
                                  ? () => context.read<NewGroupBloc>().add(
                                      _adding
                                          ? NewGroupEvent.addedTo(
                                              widget.addTo!.id,
                                              history: _history,
                                            )
                                          : const NewGroupEvent.created(),
                                    )
                                  : null,
                              child: Text(_buttonText(state)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

extension on _NewGroupPageState {
  String _buttonText(NewGroupState state) {
    final count = state.chosen.length;
    if (_adding) {
      if (state.creating) {
        return _history.window == null
            ? 'Adding…'
            : 'Adding, and copying earlier messages…';
      }
      if (count == 0) return 'Choose who to add';
      return count == 1 ? 'Add 1 person' : 'Add $count people';
    }
    if (state.creating) return 'Starting the group…';
    if (count == 0) return 'Choose who is in it';
    return 'Start group with ${count + 1} people';
  }
}

/// How much of the group's past the people added can read.
class _HistoryChoice extends StatelessWidget {
  final HistoryShare value;
  final ValueChanged<HistoryShare>? onChanged;

  const _HistoryChoice({required this.value, required this.onChanged});

  static const _labels = {
    HistoryShare.none: (
      'From now on',
      'Only what is sent after they are added.',
    ),
    HistoryShare.day: (
      'The last 24 hours',
      'A copy of what was sent in the last day, for them alone.',
    ),
    HistoryShare.week: (
      'The last 7 days',
      'A copy of what was sent in the last week, for them alone.',
    ),
    HistoryShare.all: ('Everything', 'Every earlier message you can read.'),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onChanged = this.onChanged;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'What they can read',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        RadioGroup<HistoryShare>(
          groupValue: value,
          onChanged: (choice) {
            if (choice != null) onChanged?.call(choice);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final MapEntry(key: choice, value: (title, subtitle))
                  in _labels.entries)
                RadioListTile<HistoryShare>(
                  value: choice,
                  enabled: onChanged != null,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  title: Text(title),
                  subtitle: choice == value ? Text(subtitle) : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PersonTile extends StatelessWidget {
  final User user;
  final NewGroupState state;

  const _PersonTile({required this.user, required this.state});

  @override
  Widget build(BuildContext context) {
    final chosen = state.isChosen(user.id);
    return CheckboxListTile(
      value: chosen,
      onChanged:
          (!chosen &&
                  state.chosen.length >=
                      context.read<NewGroupBloc>().capacity) ||
              state.creating
          ? null
          : (_) => context.read<NewGroupBloc>().add(
              NewGroupEvent.personToggled(user.id),
            ),
      secondary: CircleAvatar(
        foregroundImage: NetworkImage(user.imageUrl.getOrCrash()),
      ),
      title: Text(user.username.getOrCrash()),
    );
  }
}

class _UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final bool looking;
  final VoidCallback onAdd;

  const _UsernameField({
    required this.controller,
    required this.looking,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onAdd(),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: const InputDecoration(
              labelText: 'Add someone by username',
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: looking ? null : onAdd,
          child: const Text('Add'),
        ),
      ],
    ),
  );
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

class _Muted extends StatelessWidget {
  final String text;

  const _Muted(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
