import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/voice_recorder_interface.dart';
import 'package:routes_chat/presentation/core/system_gestures.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

/// Where the user writes a message. While replying, the message being
/// answered shows above the field, with a way to cancel. Chosen photos and
/// GIFs show above it too, and the text becomes their caption.
///
/// With nothing written, the send button is a microphone: holding it records
/// a voice message, sent when it is let go. Sliding left cancels it, and
/// sliding up keeps it recording without holding, to send or delete with a
/// tap.
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

  /// Whether the text is an edit of a message sent. Sending saves it, and
  /// photos cannot be added.
  final bool editing;

  /// Whether the edit is being saved.
  final bool savingEdit;

  /// Whether the edit may leave no text, as a photo's caption can.
  final bool canSaveEmpty;

  /// Makes the recorder for voice messages. Without it, or
  /// [onVoiceRecorded], there is no microphone.
  final IVoiceRecorder Function()? voiceRecorder;

  /// Called with a voice message the user recorded, to send it.
  final ValueChanged<VoiceRecording>? onVoiceRecorded;

  /// Called when recording could not start, such as without the microphone.
  final ValueChanged<MediaFailure>? onVoiceFailure;

  final VoidCallback? onCancelEdit;

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
    this.editing = false,
    this.savingEdit = false,
    this.canSaveEmpty = false,
    this.onCancelEdit,
    this.voiceRecorder,
    this.onVoiceRecorded,
    this.onVoiceFailure,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

/// Where a voice recording stands.
enum _Recording { none, held, locked }

class _MessageComposerState extends State<MessageComposer> {
  late final _text = TextEditingController(text: widget.text);

  /// How far left the finger goes to cancel a recording, and up to keep it.
  static const _cancelDistance = 110.0;
  static const _lockDistance = 70.0;

  /// Keeps the microphone the same widget, under the finger holding it, when
  /// the row around it changes to show the recording.
  final _microphoneKey = GlobalKey();

  IVoiceRecorder? _recorder;
  var _recording = _Recording.none;

  /// Whether the recorder is still starting, such as while the microphone
  /// permission is asked for.
  var _starting = false;
  var _held = false;
  var _slid = Offset.zero;
  Offset? _downAt;
  final _clock = Stopwatch();
  Timer? _ticker;
  var _level = 0.0;
  StreamSubscription<double>? _levels;

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
    _ticker?.cancel();
    unawaited(_levels?.cancel());
    SystemGestures.exclude(this, null);
    final recorder = _recorder;
    if (recorder != null) unawaited(recorder.dispose());
    super.dispose();
  }

  bool get _canRecord =>
      widget.voiceRecorder != null &&
      widget.onVoiceRecorded != null &&
      !widget.editing &&
      widget.media.isEmpty &&
      !widget.preparingMedia;

  Future<void> _startRecording({required bool locked}) async {
    if (_recording != _Recording.none) return;
    final recorder = _recorder ??= widget.voiceRecorder!();
    unawaited(HapticFeedback.mediumImpact());
    setState(() {
      _recording = locked ? _Recording.locked : _Recording.held;
      _slid = Offset.zero;
      _level = 0;
    });
    _starting = true;
    final bool started;
    try {
      started = await recorder.start();
    } finally {
      _starting = false;
    }
    if (!mounted) {
      if (started) await recorder.cancel();
      return;
    }
    // Cancelled, or let go, while it was starting.
    if (started &&
        (_recording == _Recording.none ||
            (_recording == _Recording.held && !_held))) {
      await recorder.cancel();
      if (_recording != _Recording.none) {
        setState(() => _recording = _Recording.none);
      }
      if (!_held) widget.onVoiceFailure?.call(const VoiceTooShort());
      return;
    }
    if (!started) {
      _clock.stop();
      setState(() => _recording = _Recording.none);
      widget.onVoiceFailure?.call(const MicrophoneDenied());
      return;
    }
    // Recording only starts once the microphone is ready; count from then.
    _clock
      ..reset()
      ..start();
    _levels = recorder.levels.listen((level) {
      if (mounted) setState(() => _level = level);
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      if (_clock.elapsed >= MediaLimits.maxVoiceDuration) {
        unawaited(_finishRecording());
      } else {
        setState(() {});
      }
    });
  }

  void _stopClock() {
    _ticker?.cancel();
    _ticker = null;
    _clock.stop();
    unawaited(_levels?.cancel());
    _levels = null;
  }

  Future<void> _finishRecording() async {
    // Still starting: the start sees it was let go, and ends it.
    if (_recording == _Recording.none || _starting) return;
    _stopClock();
    setState(() => _recording = _Recording.none);
    final recording = await _recorder?.stop();
    if (recording != null && mounted) widget.onVoiceRecorded?.call(recording);
  }

  Future<void> _cancelRecording() async {
    if (_recording == _Recording.none) return;
    _stopClock();
    unawaited(HapticFeedback.lightImpact());
    setState(() => _recording = _Recording.none);
    // While starting, the start sees it was cancelled, and ends it.
    if (!_starting) await _recorder?.cancel();
  }

  void _onMicDown(PointerDownEvent event) {
    if (!_canRecord || _recording != _Recording.none) return;
    _held = true;
    _downAt = event.position;
    unawaited(_startRecording(locked: false));
  }

  void _onMicMove(PointerMoveEvent event) {
    final downAt = _downAt;
    if (_recording != _Recording.held || downAt == null) return;
    final slid = event.position - downAt;
    if (slid.dx < -_cancelDistance) {
      _held = false;
      unawaited(_cancelRecording());
    } else if (slid.dy < -_lockDistance) {
      unawaited(HapticFeedback.selectionClick());
      setState(() => _recording = _Recording.locked);
    } else {
      setState(() => _slid = slid);
    }
  }

  void _onMicUp(PointerUpEvent event) {
    _held = false;
    _downAt = null;
    if (_recording == _Recording.held && !_starting) {
      unawaited(_finishRecording());
    }
  }

  void _onMicCancel(PointerCancelEvent event) {
    _held = false;
    _downAt = null;
    if (_recording == _Recording.held) unawaited(_cancelRecording());
  }

  bool _canSend(String text) =>
      (text.trim().isNotEmpty ||
          widget.media.isNotEmpty ||
          (widget.editing && widget.canSaveEmpty)) &&
      !widget.preparingMedia &&
      !widget.savingEdit;

  void _send() {
    final text = _text.text.trim();
    if (!_canSend(text)) return;
    widget.onSend(text);
    // An edit stays in the field until it is saved.
    if (!widget.editing) _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final replyingTo = widget.replyingTo;
    final onAddMedia = widget.editing ? null : widget.onAddMedia;
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
            if (widget.editing)
              _EditStrip(
                saving: widget.savingEdit,
                onCancel: widget.onCancelEdit,
              )
            else if (replyingTo != null)
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
              child: _recording != _Recording.none
                  ? _recordingRow(scheme)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (onAddMedia != null)
                          IconButton(
                            tooltip: 'Add photos or GIFs',
                            color: scheme.primary,
                            onPressed: onAddMedia,
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
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
                              hintText: widget.editing
                                  ? widget.canSaveEmpty
                                        ? 'Add a caption...'
                                        : 'Edit your message...'
                                  : widget.media.isEmpty
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
                          builder: (context, value, _) => widget.savingEdit
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : _canRecord && value.text.trim().isEmpty
                              ? _microphone(scheme)
                              : _withoutMicrophone(
                                  IconButton(
                                    tooltip: widget.editing
                                        ? 'Save edit'
                                        : 'Send',
                                    color: scheme.primary,
                                    onPressed: _canSend(value.text)
                                        ? _send
                                        : null,
                                    icon: Icon(
                                      widget.editing
                                          ? Icons.check_rounded
                                          : Icons.send_rounded,
                                    ),
                                  ),
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

  /// Where the microphone is on the screen, so sliding it to cancel, which
  /// starts near the edge, is not taken for the back gesture.
  void _keepBackGestureOffMicrophone() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box =
          _microphoneKey.currentContext?.findRenderObject() as RenderBox?;
      SystemGestures.exclude(
        this,
        box == null || !box.attached
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      );
    });
  }

  /// [send], and nothing kept from the back gesture while the microphone is
  /// not there.
  Widget _withoutMicrophone(Widget send) {
    if (_recording == _Recording.none) SystemGestures.exclude(this, null);
    return send;
  }

  /// The send button's place while nothing is written: hold to record.
  Widget _microphone(ColorScheme scheme) {
    _keepBackGestureOffMicrophone();
    final recording = _recording != _Recording.none;
    return Semantics(
      key: _microphoneKey,
      button: true,
      label: 'Record a voice message',
      hint: 'Hold to record, let go to send',
      // A tap from a screen reader records without holding.
      onTap: () => unawaited(_startRecording(locked: true)),
      excludeSemantics: true,
      child: Listener(
        onPointerDown: _onMicDown,
        onPointerMove: _onMicMove,
        onPointerUp: _onMicUp,
        onPointerCancel: _onMicCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: recording ? scheme.primary : Colors.transparent,
          ),
          child: Icon(
            Icons.mic_rounded,
            color: recording ? scheme.onPrimary : scheme.primary,
          ),
        ),
      ),
    );
  }

  /// While recording: how long, how loud, and how to cancel or send.
  Widget _recordingRow(ColorScheme scheme) {
    final textTheme = Theme.of(context).textTheme;
    final elapsed = Text(
      formatVoiceDuration(_clock.elapsed),
      style: textTheme.titleMedium?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final dot = Icon(
      Icons.fiber_manual_record_rounded,
      size: 14,
      color: scheme.error.withValues(alpha: 0.4 + 0.6 * _level),
    );
    if (_recording == _Recording.locked) {
      return Row(
        children: [
          TextButton.icon(
            onPressed: () => unawaited(_cancelRecording()),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
          ),
          const SizedBox(width: 8),
          dot,
          const SizedBox(width: 8),
          elapsed,
          const Spacer(),
          IconButton(
            tooltip: 'Send voice message',
            color: scheme.primary,
            onPressed: () => unawaited(_finishRecording()),
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      );
    }
    final pulled = (-_slid.dx / _cancelDistance).clamp(0.0, 1.0);
    return Row(
      children: [
        const SizedBox(width: 12),
        dot,
        const SizedBox(width: 8),
        elapsed,
        Expanded(
          child: Opacity(
            opacity: 1 - pulled * 0.7,
            child: Transform.translate(
              offset: Offset(_slid.dx.clamp(-_cancelDistance, 0), 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                  Text(
                    'Slide to cancel',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: scheme.onSurfaceVariant,
              semanticLabel: 'Slide up to keep recording',
            ),
            Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(width: 4),
        _microphone(scheme),
      ],
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

/// "Editing message" above the field, with a way to stop without saving.
class _EditStrip extends StatelessWidget {
  final bool saving;
  final VoidCallback? onCancel;

  const _EditStrip({required this.saving, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
      child: Row(
        children: [
          Icon(Icons.edit_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                saving ? 'Saving your edit…' : 'Editing message',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cancel edit',
            onPressed: saving ? null : onCancel,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
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
