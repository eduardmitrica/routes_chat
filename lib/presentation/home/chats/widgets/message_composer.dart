import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';

/// Where the user writes a message. While replying, the message being
/// answered shows above the field, with a way to cancel.
class MessageComposer extends StatefulWidget {
  /// The longest message allowed, in UTF-16 code units (see Content).
  static const maxLength = 1000;

  /// Focused when the user starts a reply.
  final FocusNode focusNode;

  final ValueChanged<String> onChanged;

  /// Called with the text, trimmed, when the user sends it.
  final ValueChanged<String> onSend;

  /// The message the next one sent answers, if the user is replying.
  final MessageQuote? replyingTo;

  /// Whose message [replyingTo] is, as the reply strip names them.
  final String replyingToName;

  final VoidCallback onCancelReply;

  const MessageComposer({
    super.key,
    required this.focusNode,
    required this.onChanged,
    required this.onSend,
    required this.replyingTo,
    required this.replyingToName,
    required this.onCancelReply,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final replyingTo = widget.replyingTo;
    const pill = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      borderSide: BorderSide.none,
    );

    return Material(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingTo != null)
              _ReplyStrip(
                name: widget.replyingToName,
                quote: replyingTo,
                onCancel: widget.onCancelReply,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      focusNode: widget.focusNode,
                      onChanged: widget.onChanged,
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          MessageComposer.maxLength,
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Start typing...',
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: pill,
                        enabledBorder: pill,
                        focusedBorder: pill.copyWith(
                          borderSide: BorderSide(color: scheme.primary),
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _text,
                    builder: (context, value, _) => IconButton(
                      tooltip: 'Send',
                      color: scheme.primary,
                      onPressed: value.text.trim().isEmpty ? null : _send,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Replying to …" above the field, with the start of the message answered.
class _ReplyStrip extends StatelessWidget {
  final String name;
  final MessageQuote quote;
  final VoidCallback onCancel;

  const _ReplyStrip({
    required this.name,
    required this.quote,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
      child: Row(
        children: [
          Icon(Icons.reply_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to $name',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  quote.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cancel reply',
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}
