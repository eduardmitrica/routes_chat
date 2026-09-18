import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/application/chats/chat_bar/chat_bar_bloc.dart';
import 'package:routes_chat/application/chats/messages/message_actor/message_actor_bloc.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/media_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_changes.dart';
import 'package:routes_chat/domain/chats/messages/message_links.dart';
import 'package:routes_chat/domain/chats/messages/message_reaction.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'emoji_picker_sheet.dart';
import 'media_failure_message.dart';
import 'open_link_dialog.dart';
import 'reaction_bar.dart';

// What can be done with messages, the same in a chat and in a group.

/// Shows [text] in a snack bar, in place of any other.
void tellInSnackBar(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));

/// The long-press sheet of [message]: react, reply, edit, copy, save its
/// photos, copy its links, delete it. Each item's action runs once the sheet
/// has closed. Nothing for a deleted message.
Future<void> showMessageActions(
  BuildContext context, {
  required Message message,
  required String myId,
  required MessageActorBloc actor,
  required void Function(String emoji) onReact,
  required VoidCallback onReply,
  required VoidCallback onEdit,
  required VoidCallback onSaveAll,
  required VoidCallback onDelete,
}) async {
  if (message.isDeleted) return;
  final text = message.content.getOrCrash();
  // A voice message is played, not saved to the photos.
  final attachments = message.attachments.filter(
    (attachment) => !attachment.isVoice,
  );
  // A few at most: the sheet is for this message, not a list of links.
  final links = {
    for (final part in splitLinks(text))
      if (part.link != null) part.text,
  }.take(3);
  final myReaction = message.reactions
      .firstOrNull((reaction) => reaction.userId.getOrCrash() == myId)
      ?.emoji;
  // Emojis sent since the chat opened count too.
  actor.add(const MessageActorEvent.quickEmojisRequested());
  final action = await showModalBottomSheet<VoidCallback>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.canBeReactedTo) ...[
            BlocBuilder<MessageActorBloc, MessageActorState>(
              bloc: actor,
              buildWhen: (previous, current) =>
                  previous.quickEmojis != current.quickEmojis,
              builder: (barContext, state) => ReactionBar(
                favourites: state.quickEmojis,
                current: myReaction,
                onPicked: (emoji) =>
                    Navigator.of(barContext).pop(() => onReact(emoji)),
                onMore: () => Navigator.of(barContext).pop(() async {
                  final emoji = await pickEmoji(context);
                  if (emoji != null) onReact(emoji);
                }),
              ),
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.reply_rounded),
            title: const Text('Reply'),
            onTap: () => Navigator.of(sheetContext).pop(onReply),
          ),
          if (message.canBeEditedBy(myId, DateTime.now()))
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () => Navigator.of(sheetContext).pop(onEdit),
            ),
          if (text.trim().isNotEmpty)
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy text'),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(() => copyToClipboard(context, text, 'Message copied')),
            ),
          if (attachments.isNotEmpty())
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: Text(_saveLabel(attachments)),
              onTap: () => Navigator.of(sheetContext).pop(onSaveAll),
            ),
          for (final link in links)
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('Copy link'),
              subtitle: Text(
                link,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(() => copyToClipboard(context, link, 'Link copied')),
            ),
          if (message.canBeDeletedBy(myId))
            Builder(
              builder: (context) {
                final error = Theme.of(context).colorScheme.error;
                return ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: error),
                  title: Text(
                    'Delete for everyone',
                    style: TextStyle(color: error),
                  ),
                  onTap: () => Navigator.of(context).pop(onDelete),
                );
              },
            ),
        ],
      ),
    ),
  );
  if (context.mounted) action?.call();
}

String _saveLabel(KtList<MessageAttachment> attachments) => attachments.size > 1
    ? 'Save all ${attachments.size}'
    : attachments.first().kind == AttachmentKind.gif
    ? 'Save GIF'
    : 'Save photo';

/// Asks first, since deleting a message cannot be undone. [whoElse] says who
/// else loses it: "for you and for Ana", "for everyone in the group".
Future<bool> confirmDeleteForEveryone(
  BuildContext context, {
  required String whoElse,
}) async {
  final delete = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: const Text('Delete for everyone?'),
        content: Text(
          'The message will be deleted $whoElse, with its photos and '
          'reactions. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: AppTheme.destructiveButton(scheme),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return delete == true;
}

/// Who reacted to [message] with what, the user's own first; true when the
/// user taps theirs to take it back.
Future<bool> showReactionsSheet(
  BuildContext context, {
  required Message message,
  required String myId,
  required String Function(String userId) nameOf,
}) async {
  bool isMine(MessageReaction reaction) => reaction.userId.getOrCrash() == myId;
  final reactions = [
    ...message.reactions.iter.where(isMine),
    ...message.reactions.iter.where((reaction) => !isMine(reaction)),
  ];
  final remove = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('Reactions', style: textTheme.titleMedium),
              ),
            ),
            // A long list scrolls rather than overflowing, as in a big
            // group.
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final reaction in reactions)
                    if (isMine(reaction))
                      ListTile(
                        leading: Text(
                          reaction.emoji,
                          style: textTheme.headlineSmall,
                        ),
                        title: const Text('You'),
                        subtitle: const Text('Tap to remove'),
                        onTap: () => Navigator.of(context).pop(true),
                      )
                    else
                      ListTile(
                        leading: Text(
                          reaction.emoji,
                          style: textTheme.headlineSmall,
                        ),
                        title: Text(nameOf(reaction.userId.getOrCrash())),
                      ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
  return remove == true;
}

/// Adds [attachments] of a message in [chatId] to the phone's photos, one
/// after another, and says how it went.
Future<void> saveAttachmentsToPhotos(
  BuildContext context, {
  required IMediaRepository media,
  required UniqueId chatId,
  required KtList<MessageAttachment> attachments,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  MediaFailure? failure;
  var saved = 0;
  for (final attachment in attachments.iter) {
    (await media.saveToPhotos(
      chatId,
      attachment,
    )).fold<void>((problem) => failure ??= problem, (_) => saved++);
    // Without permission, the rest would fail the same way.
    if (failure is PhotoAccessDenied) break;
  }
  final problem = failure;
  final kinds = attachments.iter.map((attachment) => attachment.kind);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          problem == null
              ? '${describeAttachments(kinds)} saved to your photos'
              : saved == 0
              ? mediaFailureMessage(problem)
              : '$saved of ${attachments.size} saved. '
                    '${mediaFailureMessage(problem)}',
        ),
      ),
    );
}

Future<void> copyToClipboard(
  BuildContext context,
  String text,
  String confirmation,
) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) tellInSnackBar(context, confirmation);
}

/// What can be done with a message on its way: try again now, copy its
/// text, or give up sending it.
Future<void> showOutgoingActions(
  BuildContext context, {
  required OutgoingMessage entry,
  required ChatBarBloc chatBar,
}) async {
  final text = entry.message.content.getOrCrash();
  final action = await showModalBottomSheet<VoidCallback>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (entry.status != OutgoingStatus.sending)
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('Try again now'),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(() => chatBar.add(ChatBarEvent.retryRequested(entry.id))),
            ),
          if (text.trim().isNotEmpty)
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy text'),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(() => copyToClipboard(context, text, 'Message copied')),
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded),
            title: const Text('Delete message'),
            subtitle: const Text('It won\'t be sent'),
            onTap: () => Navigator.of(
              sheetContext,
            ).pop(() => chatBar.add(ChatBarEvent.discardRequested(entry.id))),
          ),
        ],
      ),
    ),
  );
  if (context.mounted) action?.call();
}

/// Asks first, then opens [link]: a web page in a browser tab over the app,
/// an email address in the mail app.
///
/// The tab is the browser's own (Custom Tabs on Android, Safari View
/// Controller on iOS), not a web view inside the app. The page keeps the
/// browser's protections, such as Safe Browsing, and the app cannot see what
/// is typed into it. Closing the tab returns to the chat.
Future<void> openMessageLink(BuildContext context, Uri link) async {
  if (!await confirmOpenLink(context, link) || !context.mounted) return;
  bool opened;
  try {
    opened = link.scheme == 'mailto'
        ? await launchUrl(link, mode: LaunchMode.externalApplication)
        : await launchUrl(link, mode: LaunchMode.inAppBrowserView) ||
              // Without a browser that supports tabs, the browser itself.
              await launchUrl(link, mode: LaunchMode.externalApplication);
  } on PlatformException {
    opened = false;
  }
  if (opened || !context.mounted) return;
  tellInSnackBar(context, 'No app on this phone can open that link');
}

/// Asks where the photos come from, then hands the chosen files to [chatBar].
Future<void> pickMedia(BuildContext context, ChatBarBloc chatBar) async {
  final room = MediaLimits.maxPerMessage - chatBar.state.media.size;
  if (room <= 0) {
    tellInSnackBar(
      context,
      'A message can hold up to ${MediaLimits.maxPerMessage} photos and GIFs.',
    );
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Photos and GIFs'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
        ],
      ),
    ),
  );
  if (source == null) return;
  final picker = ImagePicker();
  try {
    // The files are re-encoded before sending, so their metadata is not
    // needed, and asking for it needs more permissions on iOS.
    final files = source == ImageSource.camera
        ? [
            ?await picker.pickImage(
              source: ImageSource.camera,
              requestFullMetadata: false,
            ),
          ]
        : await picker.pickMultiImage(limit: room, requestFullMetadata: false);
    if (files.isNotEmpty) {
      chatBar.add(
        ChatBarEvent.mediaPicked([for (final file in files) file.path]),
      );
    }
  } on PlatformException {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Photos could not be opened. Check the app\'s permissions.',
          ),
        ),
      );
  }
}
