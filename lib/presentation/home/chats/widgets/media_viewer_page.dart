import 'package:dartz/dartz.dart' show Either, Unit;
import 'package:flutter/material.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';

import 'encrypted_image.dart';
import 'media_failure_message.dart';

/// Adds a message's photo or GIF to the phone's photos.
typedef AttachmentSaver =
    Future<Either<MediaFailure, Unit>> Function(MessageAttachment attachment);

/// A message's photos and GIFs full screen, dark in either theme: swipe
/// between them, pinch to zoom, and save the one shown.
class MediaViewerPage extends StatefulWidget {
  final List<MessageAttachment> attachments;
  final int initialIndex;
  final AttachmentLoader loader;

  /// Saves the photo shown. Without it there is no button for it.
  final AttachmentSaver? onSave;

  const MediaViewerPage({
    super.key,
    required this.attachments,
    required this.initialIndex,
    required this.loader,
    this.onSave,
  });

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late final _pages = PageController(initialPage: widget.initialIndex);
  late var _page = widget.initialIndex;
  var _saving = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final onSave = widget.onSave;
    if (onSave == null || _saving) return;
    final attachment = widget.attachments[_page];
    setState(() => _saving = true);
    final saved = await onSave(attachment);
    if (!mounted) return;
    setState(() => _saving = false);
    final kind = attachment.kind == AttachmentKind.gif ? 'GIF' : 'Photo';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            saved.fold(
              mediaFailureMessage,
              (_) => '$kind saved to your photos',
            ),
          ),
        ),
      );
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
            actions: [
              if (widget.onSave != null)
                _saving
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Save to your photos',
                        onPressed: _save,
                        icon: const Icon(Icons.download_rounded),
                      ),
            ],
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
