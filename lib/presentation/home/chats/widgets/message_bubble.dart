import 'package:flutter/material.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/presentation/core/theme/app_colors.dart';

/// A message in the chat, on the side of whoever sent it. A reply shows the
/// message it answers above its own text.
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

  const MessageBubble({
    super.key,
    required this.message,
    required this.sent,
    this.highlighted = false,
    this.quoteAuthor,
    this.onQuoteTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final foreground = sent ? colors.onSentBubble : colors.onReceivedBubble;
    final quote = message.replyTo;
    const round = Radius.circular(18);
    const tucked = Radius.circular(4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: highlighted ? colors.messageHighlight : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
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
          child: InkWell(
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              // As wide as the wider of the quote and the text.
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (quote != null) ...[
                      _Quote(
                        author: quoteAuthor ?? '',
                        text: quote.text,
                        color: foreground,
                        onTap: onQuoteTap,
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      message.content.getOrCrash(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The message a reply answers: who sent it and the start of its text.
class _Quote extends StatelessWidget {
  final String author;
  final String text;
  final Color color;
  final VoidCallback? onTap;

  const _Quote({
    required this.author,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
