import 'package:flutter/material.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';

import 'encrypted_image.dart';
import 'media_viewer_page.dart';

/// The photos and GIFs of a message, [width] wide: one on its own, several as
/// a carousel to swipe through, as on Instagram. Tapping one opens it full
/// screen.
class AttachmentGallery extends StatefulWidget {
  final List<MessageAttachment> attachments;
  final AttachmentLoader loader;
  final double width;

  /// Saves a photo from the full-screen view.
  final AttachmentSaver? onSave;

  const AttachmentGallery({
    super.key,
    required this.attachments,
    required this.loader,
    required this.width,
    this.onSave,
  });

  @override
  State<AttachmentGallery> createState() => _AttachmentGalleryState();
}

class _AttachmentGalleryState extends State<AttachmentGallery> {
  var _pages = PageController();
  var _page = 0;

  @override
  void didUpdateWidget(AttachmentGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A chat list can hand this state to another message's photos, which then
    // start at their first rather than where the other message was left.
    final old = oldWidget.attachments.map((attachment) => attachment.id);
    final current = widget.attachments.map((attachment) => attachment.id);
    if (old.length != current.length ||
        !old.toList().asMap().entries.every(
          (entry) => entry.value == current.elementAt(entry.key),
        )) {
      _pages.dispose();
      _pages = PageController();
      _page = 0;
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _open(int index) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MediaViewerPage(
        attachments: widget.attachments,
        initialIndex: index,
        loader: widget.loader,
        onSave: widget.onSave,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final attachments = widget.attachments;
    final count = attachments.length;
    // One photo keeps close to its own shape. A carousel takes the first
    // one's, kept near square so the others fit it too.
    final aspectRatio = count == 1
        ? attachments.first.aspectRatio.clamp(0.6, 1.8)
        : attachments.first.aspectRatio.clamp(0.8, 1.25);

    Widget image(int index) => GestureDetector(
      onTap: () => _open(index),
      child: EncryptedImage(
        attachment: attachments[index],
        loader: widget.loader,
      ),
    );

    return SizedBox(
      width: widget.width,
      height: widget.width / aspectRatio,
      child: count == 1
          ? image(0)
          : Stack(
              children: [
                PageView.builder(
                  controller: _pages,
                  itemCount: count,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) => image(index),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _Counter(current: _page + 1, count: count),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: _Dots(current: _page, count: count),
                ),
              ],
            ),
    );
  }
}

class _Counter extends StatelessWidget {
  final int current;
  final int count;

  const _Counter({required this.current, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$current of $count',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.inverseSurface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            '$current/$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onInverseSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int current;
  final int count;

  const _Dots({required this.current, required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < count; index++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: index == current ? 8 : 6,
              height: index == current ? 8 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == current
                    ? scheme.primary
                    : scheme.inverseSurface.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}
