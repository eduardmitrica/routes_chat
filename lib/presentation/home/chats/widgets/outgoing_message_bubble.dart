import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';

import 'encrypted_image.dart';
import 'message_bubble.dart';
import 'voice_note_player.dart';

/// A message the user sent that has not arrived yet, and where it stands:
/// being sent, waiting to try again, or not sent. Its photos show from the
/// phone.
class OutgoingMessageBubble extends StatelessWidget {
  final OutgoingMessage entry;

  /// Who sent the message it replies to, as its quote names them.
  final String? quoteAuthor;

  /// Shows its photos from the phone.
  final AttachmentLoader loadAttachment;

  /// Plays its voice message from the phone.
  final VoiceFileLoader? loadVoice;
  final VoiceFileRelease? releaseVoice;

  /// Offers what can be done with it, such as trying again or deleting it.
  final VoidCallback onOptions;

  const OutgoingMessageBubble({
    super.key,
    required this.entry,
    required this.quoteAuthor,
    required this.loadAttachment,
    this.loadVoice,
    this.releaseVoice,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    // Shown as it will look once sent. A photo whose key is not made yet
    // needs none: it shows from the phone.
    final message = entry.message.copyWith(
      attachments: [
        for (final draft in entry.media.iter)
          entry.attachments[draft.id.getOrCrash()] ??
              MessageAttachment(
                id: draft.id,
                kind: draft.kind,
                width: draft.width,
                height: draft.height,
                byteSize: draft.bytes.length,
                key: Uint8List(0),
                thumbnail: draft.thumbnail,
                duration: draft.duration,
                waveform: draft.waveform,
              ),
      ].toImmutableList(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MessageBubble(
          message: message,
          sent: true,
          quoteAuthor: quoteAuthor,
          onLongPress: onOptions,
          loadAttachment: loadAttachment,
          loadVoice: loadVoice,
          releaseVoice: releaseVoice,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _Status(status: entry.status, onTap: onOptions),
        ),
      ],
    );
  }
}

class _Status extends StatelessWidget {
  final OutgoingStatus status;
  final VoidCallback onTap;

  const _Status({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (icon, label, color) = switch (status) {
      OutgoingStatus.sending => (
        Icons.schedule_rounded,
        'Sending…',
        scheme.outline,
      ),
      OutgoingStatus.waiting => (
        Icons.sync_problem_rounded,
        'Not sent yet. Trying again…',
        scheme.error,
      ),
      OutgoingStatus.failed => (
        Icons.error_outline_rounded,
        'Not sent. Tap for options',
        scheme.error,
      ),
    };
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 16, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
    if (status == OutgoingStatus.sending) {
      return Semantics(liveRegion: true, child: row);
    }
    return Semantics(
      button: true,
      liveRegion: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: row,
      ),
    );
  }
}
