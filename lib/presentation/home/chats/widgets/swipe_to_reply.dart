import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swiping [child] towards the end of the line starts a reply to it, as in
/// most messaging apps. It follows the finger a short way, shows a reply icon,
/// and springs back when let go.
///
/// A photo carousel inside takes horizontal drags for itself. On its first
/// photo, a swipe towards the end has nowhere to scroll, so what the carousel
/// cannot use moves the message instead: the reply works there too, and swiping
/// the other way still turns the photos.
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

  void _follow(DragUpdateDetails details) => _move(
    Directionality.of(context) == TextDirection.ltr
        ? details.primaryDelta!
        : -details.primaryDelta!,
  );

  /// Moves the message [towardsEnd] logical pixels, negative to move it back.
  void _move(double towardsEnd) {
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

  /// A drag a horizontal scrollable inside could not use at its start.
  ///
  /// Scrolling back past the start is always towards the end of the line: in
  /// either text direction the first page sits at the start.
  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.horizontal) return false;
    switch (notification) {
      // Clamping scroll physics (Android): the unused part is reported.
      case OverscrollNotification(:final overscroll, :final dragDetails)
          when dragDetails != null && overscroll < 0:
        _move(-overscroll);
      // Bouncing scroll physics (iOS): it scrolls past the start instead.
      case ScrollUpdateNotification(:final scrollDelta?, :final dragDetails)
          when dragDetails != null &&
              scrollDelta < 0 &&
              notification.metrics.pixels <
                  notification.metrics.minScrollExtent:
        _move(-scrollDelta);
      case ScrollEndNotification() when _offset.value > 0:
        _letGo();
      default:
        break;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final direction = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: GestureDetector(
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
      ),
    );
  }
}
