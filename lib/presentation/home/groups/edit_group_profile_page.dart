import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routes_chat/application/groups/group_actor_bloc.dart';
import 'package:routes_chat/domain/groups/group.dart';
import 'package:routes_chat/domain/groups/group_failure.dart';
import 'package:routes_chat/domain/groups/group_profile.dart';

/// Naming a group and choosing its photo. Both are encrypted with the group's
/// key, and everyone in it sees that they changed.
class EditGroupProfilePage extends StatefulWidget {
  static const editGroupProfilePageRoute = '/home/groups/edit';

  final Group group;

  const EditGroupProfilePage({super.key, required this.group});

  /// Opens the editor with [actor], the group screen's own, so saving shows
  /// there at once.
  static Route<void> route(Group group, GroupActorBloc actor) =>
      MaterialPageRoute(
        settings: const RouteSettings(name: editGroupProfilePageRoute),
        builder: (_) => BlocProvider.value(
          value: actor,
          child: EditGroupProfilePage(group: group),
        ),
      );

  @override
  State<EditGroupProfilePage> createState() => _EditGroupProfilePageState();
}

class _EditGroupProfilePageState extends State<EditGroupProfilePage> {
  late final _name = TextEditingController(
    text: widget.group.profile?.name ?? '',
  );

  /// A photo chosen here and not saved yet.
  String? _photoPath;
  Uint8List? _photoPreview;
  var _removePhoto = false;

  /// How many saves the group screen had counted when this opened; one more
  /// means this one went through.
  late final int _savesAtOpen = context
      .read<GroupActorBloc>()
      .state
      .profilesSaved;

  @override
  void initState() {
    super.initState();
    _savesAtOpen;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    final bytes = await File(picked.path).readAsBytes();
    if (!mounted) return;
    setState(() {
      _photoPath = picked.path;
      _photoPreview = bytes;
      _removePhoto = false;
    });
  }

  void _save() => context.read<GroupActorBloc>().add(
    GroupActorEvent.profileSaved(
      name: _name.text,
      photoPath: _photoPath,
      removePhoto: _removePhoto,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saved = widget.group.profile?.photo;
    final ImageProvider? photo = _photoPreview != null
        ? MemoryImage(_photoPreview!)
        : _removePhoto || saved == null
        ? null
        : MemoryImage(Uint8List.fromList(saved));
    return BlocConsumer<GroupActorBloc, GroupActorState>(
      listenWhen: (previous, current) =>
          previous.profilesSaved != current.profilesSaved ||
          previous.failures != current.failures,
      listener: (context, state) {
        if (state.profilesSaved > _savesAtOpen) {
          Navigator.of(context).pop();
          return;
        }
        final failure = state.lastFailure;
        if (failure != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(switch (failure) {
                  GroupUnexpected() =>
                    'The name and photo couldn\'t be saved. Try a smaller '
                        'photo, or check your connection.',
                  _ =>
                    'The name and photo couldn\'t be saved. Someone may have '
                        'changed the group meanwhile.',
                }),
              ),
            );
        }
      },
      builder: (context, state) {
        final saving = state.busy.contains(GroupActorBloc.savingProfile);
        return Scaffold(
          appBar: AppBar(title: const Text('Name and photo')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                  foregroundImage: photo,
                  child: const Icon(Icons.groups_rounded, size: 48),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: saving ? null : () => unawaited(_choosePhoto()),
                    icon: const Icon(Icons.photo_outlined),
                    label: Text(photo == null ? 'Choose photo' : 'Change'),
                  ),
                  if (photo != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: saving
                          ? null
                          : () => setState(() {
                              _photoPath = null;
                              _photoPreview = null;
                              _removePhoto = saved != null;
                            }),
                      child: const Text('Remove'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _name,
                enabled: !saving,
                maxLength: GroupProfile.maxNameLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Group name',
                  helperText:
                      'Without one, the group is called after its '
                      'members.',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Only people in the group can see the name and photo. '
                'Everyone in it sees when they change.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: saving ? null : _save,
                child: Text(saving ? 'Saving…' : 'Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}
