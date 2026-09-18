import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Parts of the screen where Android's back gesture, a swipe in from the
/// edge, is left to the app, such as the voice message microphone, which is
/// slid to cancel. MainActivity.kt applies them; other platforms ignore them.
abstract final class SystemGestures {
  static const _channel = MethodChannel('routes_chat/system_gestures');

  /// The areas by owner, in logical pixels on the screen.
  static final _excluded = <Object, Rect>{};

  /// Keeps the back gesture out of [area] for [owner], or lets it back in
  /// when [area] is null.
  static void exclude(Object owner, Rect? area) {
    if (_excluded[owner] == area) return;
    if (area == null) {
      _excluded.remove(owner);
    } else {
      _excluded[owner] = area;
    }
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final ratio =
        PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1;
    unawaited(
      _channel
          .invokeMethod<void>('exclude', [
            for (final rect in _excluded.values)
              [
                (rect.left * ratio).floor(),
                (rect.top * ratio).floor(),
                (rect.right * ratio).ceil(),
                (rect.bottom * ratio).ceil(),
              ],
          ])
          .catchError((Object _) {}),
    );
  }
}
