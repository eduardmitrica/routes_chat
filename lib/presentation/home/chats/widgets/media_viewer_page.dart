import 'package:flutter/material.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';

import 'encrypted_image.dart';

/// A message's photos and GIFs full screen, dark in either theme: swipe
/// between them, pinch to zoom.
class MediaViewerPage extends StatefulWidget {
  final List<MessageAttachment> attachments;
  final int initialIndex;
  final AttachmentLoader loader;

  const MediaViewerPage({
    super.key,
    required this.attachments,
    required this.initialIndex,
    required this.loader,
  });

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late final _pages = PageController(initialPage: widget.initialIndex);
  late var _page = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.attachments.length;
    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
            title: count > 1 ? Text('${_page + 1} of $count') : null,
          ),
          body: PageView.builder(
            controller: _pages,
            itemCount: count,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: EncryptedImage(
                  attachment: widget.attachments[index],
                  loader: widget.loader,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
