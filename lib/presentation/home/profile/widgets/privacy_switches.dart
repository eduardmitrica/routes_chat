import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routes_chat/application/settings/privacy/privacy_bloc.dart';
import 'package:routes_chat/domain/settings/privacy_settings.dart';
import 'package:routes_chat/application/chats/message_requests/message_requests_bloc.dart';
import 'package:routes_chat/injection.dart';

/// Whether others see when the user types, when they are online, and when
/// they have read messages. Each works both ways, which the switch says.
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Read receipts'),
              subtitle: const Text(
                'Others see when you\'ve read their messages. When off, you '
                'won\'t see when they\'ve read yours either.',
              ),
              value: privacy.shareReadReceipts,
              onChanged: (share) =>
                  settings.add(PrivacyEvent.readReceiptsSharingChanged(share)),
            ),
            const _MessageRequestsSwitch(),
          ],
        );
      },
    );
  }
}

/// Whether people who are not friends may reach the user at all. Off, what
/// they send never shows and never rings; they are not told.
class _MessageRequestsSwitch extends StatelessWidget {
  const _MessageRequestsSwitch();

  @override
  Widget build(BuildContext context) {
    final requests = getIt<MessageRequestsBloc>();
    return BlocBuilder<MessageRequestsBloc, MessageRequestsState>(
      bloc: requests,
      builder: (context, state) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Message requests'),
        subtitle: const Text(
          'People you\'re not friends with can ask to message you. Their '
          'first message waits in Requests. When off, they can\'t reach you '
          'at all.',
        ),
        value: state.requests.allowFromAnyone,
        onChanged: (allow) =>
            requests.add(MessageRequestsEvent.allowFromAnyoneChanged(allow)),
      ),
    );
  }
}
