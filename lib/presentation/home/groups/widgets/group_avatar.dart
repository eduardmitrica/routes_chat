import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:routes_chat/domain/groups/group.dart';

/// A group's photo, or a groups icon when it has none or this phone cannot
/// open it yet.
class GroupAvatar extends StatelessWidget {
  final Group? group;
  final double radius;

  const GroupAvatar({super.key, required this.group, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photo = group?.profile?.photo;
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.secondaryContainer,
      foregroundColor: theme.colorScheme.onSecondaryContainer,
      foregroundImage: photo == null
          ? null
          : MemoryImage(Uint8List.fromList(photo)),
      child: Icon(Icons.groups_rounded, size: radius),
    );
  }
}
