import 'package:flutter/material.dart';

/// The colors the app needs beyond the Material color scheme, derived from
/// it so that the light and dark themes each get their own.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  /// A message the user sent, its text, and links in it.
  final Color sentBubble;
  final Color onSentBubble;
  final Color linkOnSentBubble;

  /// A message the user received, its text, and links in it.
  final Color receivedBubble;
  final Color onReceivedBubble;
  final Color linkOnReceivedBubble;

  /// Behind a message the chat was just scrolled to.
  final Color messageHighlight;

  /// A placeholder shape for content that is loading, and the light that
  /// sweeps across it.
  final Color skeleton;
  final Color skeletonShine;

  const AppColors({
    required this.sentBubble,
    required this.onSentBubble,
    required this.linkOnSentBubble,
    required this.receivedBubble,
    required this.onReceivedBubble,
    required this.linkOnReceivedBubble,
    required this.messageHighlight,
    required this.skeleton,
    required this.skeletonShine,
  });

  factory AppColors.fromScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    return AppColors(
      sentBubble: scheme.primary,
      onSentBubble: scheme.onPrimary,
      // The bubble is already the brand color, so a link there stands out by
      // its underline alone.
      linkOnSentBubble: scheme.onPrimary,
      receivedBubble: scheme.surfaceContainerHighest,
      onReceivedBubble: scheme.onSurface,
      linkOnReceivedBubble: scheme.primary,
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
    Color? linkOnSentBubble,
    Color? receivedBubble,
    Color? onReceivedBubble,
    Color? linkOnReceivedBubble,
    Color? messageHighlight,
    Color? skeleton,
    Color? skeletonShine,
  }) => AppColors(
    sentBubble: sentBubble ?? this.sentBubble,
    onSentBubble: onSentBubble ?? this.onSentBubble,
    linkOnSentBubble: linkOnSentBubble ?? this.linkOnSentBubble,
    receivedBubble: receivedBubble ?? this.receivedBubble,
    onReceivedBubble: onReceivedBubble ?? this.onReceivedBubble,
    linkOnReceivedBubble: linkOnReceivedBubble ?? this.linkOnReceivedBubble,
    messageHighlight: messageHighlight ?? this.messageHighlight,
    skeleton: skeleton ?? this.skeleton,
    skeletonShine: skeletonShine ?? this.skeletonShine,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      sentBubble: mix(sentBubble, other.sentBubble),
      onSentBubble: mix(onSentBubble, other.onSentBubble),
      linkOnSentBubble: mix(linkOnSentBubble, other.linkOnSentBubble),
      receivedBubble: mix(receivedBubble, other.receivedBubble),
      onReceivedBubble: mix(onReceivedBubble, other.onReceivedBubble),
      linkOnReceivedBubble: mix(
        linkOnReceivedBubble,
        other.linkOnReceivedBubble,
      ),
      messageHighlight: mix(messageHighlight, other.messageHighlight),
      skeleton: mix(skeleton, other.skeleton),
      skeletonShine: mix(skeletonShine, other.skeletonShine),
    );
  }
}
