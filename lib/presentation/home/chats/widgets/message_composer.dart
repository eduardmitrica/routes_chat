import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

/// Where the user writes a message. While replying, the message being
/// answered shows above the field, with a way to cancel. Chosen photos and
/// GIFs show above it too, and the text becomes their caption.
class MessageComposer extends StatefulWidget {
  /// The longest message allowed, in UTF-16 code units (see Content).
  static const maxLength = 1000;

  /// Focused when the user starts a reply.
  final FocusNode focusNode;

  final ValueChanged<String> onChanged;

  /// Called with the text, trimmed, when the user sends it. The text may be
  /// empty when photos are chosen.
  final ValueChanged<String> onSend;

  /// The message the next one sent answers, if the user is replying.
  final MessageQuote? replyingTo;

  /// Whose message [replyingTo] is, as the reply strip names them.
  final String replyingToName;

  final VoidCallback onCancelReply;

  /// Photos and GIFs chosen for the next message.
  final List<MediaDraft> media;

  /// Whether chosen photos are still being made ready.
  final bool preparingMedia;

  /// The text the field starts with, such as a restored draft.
  final String text;

  /// Changes each time [text] is set from outside the field, which then shows
  /// it in place of what it had.
  final int textRevision;

  /// Asks for photos to add. Without it there is no button for them.
  final VoidCallback? onAddMedia;

  final ValueChanged<UniqueId>? onRemoveMedia;

  const MessageComposer({
    super.key,
    required this.focusNode,
    required this.onChanged,
    required this.onSend,
    required this.replyingTo,
    required this.replyingToName,
    required this.onCancelReply,
    this.media = const [],
    this.preparingMedia = false,
    this.text = '',
    this.textRevision = 0,
    this.onAddMedia,
    this.onRemoveMedia,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  late final _text = TextEditingController(text: widget.text);

  @override
  void didUpdateWidget(MessageComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textRevision != oldWidget.textRevision) {
      _text.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool _canSend(String text) =>
      (text.trim().isNotEmpty || widget.media.isNotEmpty) &&
      !widget.preparingMedia;

  void _send() {
    final text = _text.text.trim();
    if (!_canSend(text)) return;
    widget.onSend(text);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final replyingTo = widget.replyingTo;
    final onAddMedia = widget.onAddMedia;
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
            if (widget.media.isNotEmpty || widget.preparingMedia)
              SizedBox(
                height: 84,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  children: [
                    for (final draft in widget.media)
                      _DraftThumbnail(
                        draft: draft,
                        onRemove: widget.onRemoveMedia == null
                            ? null
                            : () => widget.onRemoveMedia!(draft.id),
                      ),
                    if (widget.preparingMedia)
                      const SizedBox.square(
                        dimension: 72,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                onAddMedia == null ? 12 : 4,
                8,
                4,
                8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (onAddMedia != null)
                    IconButton(
                      tooltip: 'Add photos or GIFs',
                      color: scheme.primary,
                      onPressed: onAddMedia,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                    ),
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
                        hintText: widget.media.isEmpty
                            ? 'Start typing...'
                            : 'Add a caption...',
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
                      onPressed: _canSend(value.text) ? _send : null,
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

/// A chosen photo or GIF, with a way to take it out of the message.
class _DraftThumbnail extends StatelessWidget {
  final MediaDraft draft;
  final VoidCallback? onRemove;

  const _DraftThumbnail({required this.draft, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onRemove = this.onRemove;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox.square(
        dimension: 72,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                draft.bytes,
                fit: BoxFit.cover,
                cacheWidth: 216,
                gaplessPlayback: true,
                semanticLabel: draft.kind == AttachmentKind.gif
                    ? 'Chosen GIF'
                    : 'Chosen photo',
              ),
            ),
            if (draft.kind == AttachmentKind.gif)
              Positioned(
                left: 4,
                bottom: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.inverseSurface.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'GIF',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                ),
              ),
            if (onRemove != null)
              Positioned(
                top: 2,
                right: 2,
                child: IconButton(
                  tooltip: 'Remove photo',
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.inverseSurface,
                    foregroundColor: theme.colorScheme.onInverseSurface,
                  ),
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded),
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
    final thumbnail = quote.thumbnail;
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
          if (thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                thumbnail,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
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
