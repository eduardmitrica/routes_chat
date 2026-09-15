import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/settings/privacy/privacy_bloc.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';

/// Whether others see when the user types, and when they are online. Each
/// works both ways, which the switch says.
class PrivacySwitches extends StatelessWidget {
  const PrivacySwitches({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrivacyBloc, PrivacySettings>(
      builder: (context, privacy) {
        final settings = context.read<PrivacyBloc>();
        return Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show when I\'m typing'),
              subtitle: const Text(
                'When off, you won\'t see others typing either.',
              ),
              value: privacy.shareTyping,
              onChanged: (share) =>
                  settings.add(PrivacyEvent.typingSharingChanged(share)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show when I\'m online'),
              subtitle: const Text(
                'Friends see when you\'re online or were last seen. When off, '
                'you won\'t see theirs either.',
              ),
              value: privacy.shareOnline,
              onChanged: (share) =>
                  settings.add(PrivacyEvent.onlineSharingChanged(share)),
            ),
          ],
        );
      },
    );
  }
}
