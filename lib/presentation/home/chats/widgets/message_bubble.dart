import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/presentation/core/theme/app_colors.dart';

import 'attachment_gallery.dart';
import 'encrypted_image.dart';
import 'linkified_text.dart';

/// A message in the chat, on the side of whoever sent it. A reply shows the
/// message it answers above its own text, photos and GIFs show above their
/// caption, and links in the text open when tapped.
class MessageBubble extends StatelessWidget {
  final Message message;

  /// Whether the user sent it, which puts it on the right.
  final bool sent;

  /// Whether the chat was just scrolled to it.
  final bool highlighted;

  /// Who sent the message a reply answers, as its quote names them.
  final String? quoteAuthor;

  /// Called when the quote of a reply is tapped, to show the original.
  final VoidCallback? onQuoteTap;

  final VoidCallback? onLongPress;

  /// Called with a link in the text that was tapped.
  final ValueChanged<Uri>? onOpenLink;

  /// Loads the message's photos and GIFs. Without it they are not shown.
  final AttachmentLoader? loadAttachment;

  const MessageBubble({
    super.key,
    required this.message,
    required this.sent,
    this.highlighted = false,
    this.quoteAuthor,
    this.onQuoteTap,
    this.onLongPress,
    this.onOpenLink,
    this.loadAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final foreground = sent ? colors.onSentBubble : colors.onReceivedBubble;
    final linkColor = sent
        ? colors.linkOnSentBubble
        : colors.linkOnReceivedBubble;
    final text = message.content.getOrCrash();
    final attachments = message.attachments.asList();
    final loader = loadAttachment;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.75;
    final quote = message.replyTo;
    const round = Radius.circular(18);
    const tucked = Radius.circular(4);

    final quoteView = quote == null
        ? null
        : _Quote(
            author: quoteAuthor ?? '',
            text: quote.text,
            thumbnail: quote.thumbnail,
            color: foreground,
            onTap: onQuoteTap,
          );
    final caption = text.isEmpty
        ? null
        : LinkifiedText(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: foreground),
            linkStyle: TextStyle(
              color: linkColor,
              decoration: TextDecoration.underline,
              decorationColor: linkColor,
            ),
            onOpenLink: onOpenLink,
          );

    final Widget content;
    if (attachments.isNotEmpty && loader != null) {
      // A carousel has no intrinsic width, so a bubble with photos takes the
      // widest a bubble gets.
      content = SizedBox(
        width: maxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (quoteView != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: quoteView,
              ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AttachmentGallery(
                  attachments: attachments,
                  loader: loader,
                  width: maxWidth - 8,
                ),
              ),
            ),
            if (caption != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                child: caption,
              ),
          ],
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // As wide as the wider of the quote and the text.
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (quoteView != null) ...[quoteView, const SizedBox(height: 6)],
              ?caption,
            ],
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: highlighted ? colors.messageHighlight : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: sent ? colors.sentBubble : colors.receivedBubble,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: round,
              topRight: round,
              bottomLeft: sent ? round : tucked,
              bottomRight: sent ? tucked : round,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onLongPress: onLongPress, child: content),
        ),
      ),
    );
  }
}

/// The message a reply answers: who sent it, the start of its text, and a
/// preview of its photo.
class _Quote extends StatelessWidget {
  final String author;
  final String text;
  final Uint8List? thumbnail;
  final Color color;
  final VoidCallback? onTap;

  const _Quote({
    required this.author,
    required this.text,
    required this.thumbnail,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final thumbnail = this.thumbnail;
    return Semantics(
      button: onTap != null,
      hint: onTap == null ? null : 'Shows the message this replies to',
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColoredBox(
                  color: color.withValues(alpha: 0.7),
                  child: const SizedBox(width: 3),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: color.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (thumbnail != null)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(
                        thumbnail,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
