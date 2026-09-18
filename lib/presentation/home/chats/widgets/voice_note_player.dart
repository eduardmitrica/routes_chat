import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';

/// Gives a file that plays [attachment], and takes it back once it is no
/// longer played.
typedef VoiceFileLoader =
    Future<Either<MediaFailure, String>> Function(MessageAttachment attachment);
typedef VoiceFileRelease = Future<void> Function(String path);

/// A voice message in a bubble: play and pause, its waveform, which shows how
/// far it has played and can be tapped or dragged to jump, how long it is,
/// and how fast it plays.
///
/// Nothing is downloaded until the user plays it. One voice message plays at
/// a time: starting one pauses the one playing.
class VoiceNotePlayer extends StatefulWidget {
  final MessageAttachment attachment;
  final VoiceFileLoader? load;
  final VoiceFileRelease? release;

  /// The colour of the text and the part played; the rest is fainter.
  final Color color;
  final double width;

  const VoiceNotePlayer({
    super.key,
    required this.attachment,
    required this.load,
    required this.release,
    required this.color,
    required this.width,
  });

  /// The speeds the speed button goes through, in order.
  static const speeds = [1.0, 1.5, 2.0];

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

/// The player playing now, so starting another pauses it.
final _playing = ValueNotifier<_VoiceNotePlayerState?>(null);

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  AudioPlayer? _player;
  String? _path;
  final _subscriptions = <StreamSubscription<Object?>>[];
  var _loading = false;
  var _failed = false;
  var _isPlaying = false;
  var _position = Duration.zero;
  var _speed = VoiceNotePlayer.speeds.first;

  Duration get _duration => widget.attachment.duration ?? Duration.zero;

  @override
  void initState() {
    super.initState();
    _playing.addListener(_pauseIfAnotherPlays);
  }

  @override
  void dispose() {
    _playing.removeListener(_pauseIfAnotherPlays);
    if (_playing.value == this) _playing.value = null;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_player?.dispose());
    if (_path case final path?) unawaited(widget.release?.call(path));
    super.dispose();
  }

  void _pauseIfAnotherPlays() {
    final playing = _playing.value;
    if (playing != null && playing != this && _isPlaying) {
      unawaited(_player?.pause());
    }
  }

  /// The player, with the voice message loaded; null when it could not be.
  Future<AudioPlayer?> _ready() async {
    if (_player case final player?) return player;
    final load = widget.load;
    if (load == null || _loading) return null;
    setState(() {
      _loading = true;
      _failed = false;
    });
    final loaded = await load(widget.attachment);
    if (!mounted) {
      loaded.fold((_) {}, (path) => unawaited(widget.release?.call(path)));
      return null;
    }
    final path = loaded.fold((_) => null, (path) => path);
    if (path == null) {
      setState(() {
        _loading = false;
        _failed = true;
      });
      return null;
    }
    final player = AudioPlayer();
    try {
      await player.setFilePath(path);
      await player.setSpeed(_speed);
    } on Exception {
      await player.dispose();
      unawaited(widget.release?.call(path));
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
      return null;
    }
    if (!mounted) {
      await player.dispose();
      unawaited(widget.release?.call(path));
      return null;
    }
    _path = path;
    _player = player;
    _subscriptions
      ..add(
        player.positionStream.listen((position) {
          if (mounted) setState(() => _position = position);
        }),
      )
      ..add(
        player.playerStateStream.listen((state) {
          if (!mounted) return;
          if (state.processingState == ProcessingState.completed) {
            // Back to the start, ready to play again.
            unawaited(player.pause());
            unawaited(player.seek(Duration.zero));
          }
          setState(
            () => _isPlaying =
                state.playing &&
                state.processingState != ProcessingState.completed,
          );
        }),
      );
    setState(() => _loading = false);
    return player;
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player?.pause();
      return;
    }
    final player = await _ready();
    if (player == null) return;
    _playing.value = this;
    unawaited(player.play());
  }

  Future<void> _seekTo(double fraction) async {
    final target = _duration * fraction.clamp(0.0, 1.0);
    setState(() => _position = target);
    final player = await _ready();
    await player?.seek(target);
  }

  Future<void> _changeSpeed() async {
    final speeds = VoiceNotePlayer.speeds;
    final next = speeds[(speeds.indexOf(_speed) + 1) % speeds.length];
    setState(() => _speed = next);
    await _player?.setSpeed(next);
  }

  static String _speedLabel(double speed) =>
      '${speed == speed.roundToDouble() ? speed.toInt() : speed}×';

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final faint = color.withValues(alpha: 0.35);
    final textTheme = Theme.of(context).textTheme;
    final duration = _duration;
    final played = duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    final shown = _isPlaying || _position > Duration.zero
        ? _position
        : duration;

    return SizedBox(
      width: widget.width,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 48,
            child: _loading
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : IconButton(
                    tooltip: _failed
                        ? 'Couldn\'t load. Try again'
                        : _isPlaying
                        ? 'Pause'
                        : 'Play voice message',
                    color: color,
                    onPressed: widget.load == null ? null : _toggle,
                    icon: Icon(
                      _failed
                          ? Icons.refresh_rounded
                          : _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 32,
                    ),
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    void seekAt(double dx) =>
                        unawaited(_seekTo(dx / constraints.maxWidth));
                    return Semantics(
                      slider: true,
                      label: 'Voice message',
                      value:
                          '${formatVoiceDuration(_position)} of '
                          '${formatVoiceDuration(duration)}',
                      increasedValue: formatVoiceDuration(
                        _position + const Duration(seconds: 5),
                      ),
                      decreasedValue: formatVoiceDuration(
                        _position - const Duration(seconds: 5),
                      ),
                      onIncrease: () => unawaited(
                        _seekTo(
                          (_position + const Duration(seconds: 5))
                                  .inMilliseconds /
                              math.max(1, duration.inMilliseconds),
                        ),
                      ),
                      onDecrease: () => unawaited(
                        _seekTo(
                          (_position - const Duration(seconds: 5))
                                  .inMilliseconds /
                              math.max(1, duration.inMilliseconds),
                        ),
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (details) => seekAt(details.localPosition.dx),
                        onHorizontalDragUpdate: (details) =>
                            seekAt(details.localPosition.dx),
                        child: SizedBox(
                          height: 32,
                          child: CustomPaint(
                            painter: _WaveformPainter(
                              waveform: widget.attachment.waveform,
                              played: played,
                              playedColor: color,
                              restColor: faint,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    Text(
                      formatVoiceDuration(shown),
                      style: textTheme.labelSmall?.copyWith(color: color),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _changeSpeed,
                      style: TextButton.styleFrom(
                        foregroundColor: color,
                        minimumSize: const Size(40, 28),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        textStyle: textTheme.labelMedium,
                      ),
                      child: Text(
                        _speedLabel(_speed),
                        semanticsLabel: 'Playback speed ${_speedLabel(_speed)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final Uint8List? waveform;
  final double played;
  final Color playedColor;
  final Color restColor;

  const _WaveformPainter({
    required this.waveform,
    required this.played,
    required this.playedColor,
    required this.restColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bars = waveform == null || waveform!.isEmpty
        ? MediaLimits.waveformBars
        : waveform!.length;
    const gap = 2.0;
    final barWidth = math.max(1.5, (size.width - gap * (bars - 1)) / bars);
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var bar = 0; bar < bars; bar++) {
      final loudness = waveform == null || waveform!.isEmpty
          ? 0.15
          : waveform![bar] / 255;
      final height = math.max(3.0, size.height * loudness);
      final left = bar * (barWidth + gap);
      paint.color = (bar + 0.5) / bars <= played ? playedColor : restColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, (size.height - height) / 2, barWidth, height),
          Radius.circular(barWidth / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.played != played ||
      old.waveform != waveform ||
      old.playedColor != playedColor ||
      old.restColor != restColor;
}
