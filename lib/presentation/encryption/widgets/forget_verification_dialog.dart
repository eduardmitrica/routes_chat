import 'package:flutter/material.dart';

/// Asks before dropping the check the user made on [name]'s keys, once their
/// number is no longer the one that was checked.
///
/// It only clears what this phone remembers: [name] is not told, and nothing
/// about the chat changes.
Future<bool> confirmForgetVerification(
  BuildContext context,
  String name,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forget the check on $name?'),
        content: Text(
          'This phone stops treating the number you compared as $name\'s, so '
          'the warning goes away. $name isn\'t told, and nothing else about '
          'the chat changes. You can compare the new number whenever you '
          'want.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Forget'),
          ),
        ],
      ),
    ) ??
    false;
