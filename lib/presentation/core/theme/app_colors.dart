import 'package:flutter/material.dart';

/// The colors the app needs beyond the Material color scheme, derived from
/// it so that the light and dark themes each get their own.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  /// A message the user sent, and its text.
  final Color sentBubble;
  final Color onSentBubble;

  /// A message the user received, and its text.
  final Color receivedBubble;
  final Color onReceivedBubble;

  /// Behind a message the chat was just scrolled to.
  final Color messageHighlight;

  /// A placeholder shape for content that is loading, and the light that
  /// sweeps across it.
  final Color skeleton;
  final Color skeletonShine;

  const AppColors({
    required this.sentBubble,
    required this.onSentBubble,
    required this.receivedBubble,
    required this.onReceivedBubble,
    required this.messageHighlight,
    required this.skeleton,
    required this.skeletonShine,
  });

  factory AppColors.fromScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return AppColors(
      sentBubble: scheme.primary,
      onSentBubble: scheme.onPrimary,
      receivedBubble: scheme.surfaceContainerHighest,
      onReceivedBubble: scheme.onSurface,
      messageHighlight: scheme.tertiaryContainer,
      // The shine is lighter than the shape in both themes.
      skeleton: dark
          ? scheme.surfaceContainerHigh
          : scheme.surfaceContainerHighest,
      skeletonShine: dark
          ? scheme.surfaceContainerHighest
          : scheme.surfaceContainerLowest,
    );
  }

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? sentBubble,
    Color? onSentBubble,
    Color? receivedBubble,
    Color? onReceivedBubble,
    Color? messageHighlight,
    Color? skeleton,
    Color? skeletonShine,
  }) => AppColors(
    sentBubble: sentBubble ?? this.sentBubble,
    onSentBubble: onSentBubble ?? this.onSentBubble,
    receivedBubble: receivedBubble ?? this.receivedBubble,
    onReceivedBubble: onReceivedBubble ?? this.onReceivedBubble,
    messageHighlight: messageHighlight ?? this.messageHighlight,
    skeleton: skeleton ?? this.skeleton,
    skeletonShine: skeletonShine ?? this.skeletonShine,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      sentBubble: Color.lerp(sentBubble, other.sentBubble, t)!,
      onSentBubble: Color.lerp(onSentBubble, other.onSentBubble, t)!,
      receivedBubble: Color.lerp(receivedBubble, other.receivedBubble, t)!,
      onReceivedBubble: Color.lerp(
        onReceivedBubble,
        other.onReceivedBubble,
        t,
      )!,
      messageHighlight: Color.lerp(
        messageHighlight,
        other.messageHighlight,
        t,
      )!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
      skeletonShine: Color.lerp(skeletonShine, other.skeletonShine, t)!,
    );
  }
}
