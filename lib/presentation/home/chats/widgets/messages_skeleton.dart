import 'package:flutter/material.dart';
import 'package:routes_chat/presentation/core/widgets/skeleton.dart';

/// Stands in for a chat's messages while they load and decrypt: bubbles of
/// different lengths on both sides, the way the chat will look.
class MessagesSkeleton extends StatelessWidget {
  final int _count;
  final bool _fillsChat;

  /// Fills the chat, newest at the bottom, before any message is loaded.
  const MessagesSkeleton({super.key}) : _count = 14, _fillsChat = true;

  /// A few bubbles above the oldest message, while the ones before it load.
  const MessagesSkeleton.older({super.key}) : _count = 3, _fillsChat = false;

  /// Each bubble's width, as a share of the widest a bubble gets, and
  /// whether it is on the sender's side. The pattern repeats.
  static const _bubbles = [
    (0.55, false),
    (0.35, false),
    (0.7, true),
    (0.45, true),
    (0.6, false),
    (0.3, true),
    (0.5, false),
    (0.65, true),
    (0.4, false),
  ];

  @override
  Widget build(BuildContext context) {
    // Message bubbles are at most 70% of the screen wide.
    final widest = MediaQuery.sizeOf(context).width * 0.7;

    Widget bubble(int index) {
      final (share, sent) = _bubbles[index % _bubbles.length];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: Align(
          alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
          child: SkeletonBlock(
            width: widest * share,
            // Every fourth one as if it ran to a second line.
            height: index % 4 == 2 ? 56 : 36,
            radius: 12,
          ),
        ),
      );
    }

    final bubbles = _fillsChat
        ? ListView.builder(
            reverse: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _count,
            itemBuilder: (context, index) => bubble(index),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Continues the pattern where a full chat's skeleton left off.
              for (var index = _count - 1; index >= 0; index--)
                bubble(index + 5),
            ],
          );

    return Semantics(
      label: 'Loading messages',
      child: ExcludeSemantics(child: Shimmer(child: bubbles)),
    );
  }
}
