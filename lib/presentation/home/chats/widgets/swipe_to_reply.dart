import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swiping [child] towards the end of the line starts a reply to it, as in
/// most messaging apps. It follows the finger a short way, shows a reply icon,
/// and springs back when let go.
class SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;

  const SwipeToReply({super.key, required this.child, required this.onReply});

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply>
    with SingleTickerProviderStateMixin {
  /// How far the message follows the finger, and how far starts a reply.
  static const _furthest = 72.0;
  static const _replyAt = 56.0;

  late final _offset = AnimationController(
    vsync: this,
    upperBound: _furthest,
    duration: const Duration(milliseconds: 200),
  );
  var _willReply = false;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void _follow(DragUpdateDetails details) {
    final towardsEnd = Directionality.of(context) == TextDirection.ltr
        ? details.primaryDelta!
        : -details.primaryDelta!;
    // It lags behind the finger, so it feels held rather than dragged.
    _offset.value += towardsEnd * 0.6;
    final willReply = _offset.value >= _replyAt;
    if (willReply && !_willReply) {
      HapticFeedback.selectionClick();
    }
    _willReply = willReply;
  }

  void _letGo([DragEndDetails? _]) {
    if (_willReply) {
      widget.onReply();
    }
    _willReply = false;
    _offset.animateBack(0, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final direction = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _follow,
      onHorizontalDragEnd: _letGo,
      onHorizontalDragCancel: _letGo,
      child: AnimatedBuilder(
        animation: _offset,
        child: widget.child,
        builder: (context, child) {
          final progress = (_offset.value / _replyAt).clamp(0.0, 1.0);
          return Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              PositionedDirectional(
                start: 16,
                child: Opacity(
                  opacity: progress,
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * progress,
                    child: Icon(Icons.reply_rounded, color: iconColor),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(direction * _offset.value, 0),
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }
}
