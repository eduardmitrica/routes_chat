import 'dart:typed_data';
import 'dart:ui' show ImageFilter;

// dartz exports its own State class, which would shadow Flutter's.
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/presentation/core/theme/app_colors.dart';

/// Downloads and decrypts a photo or GIF of a message.
typedef AttachmentLoader =
    Future<Either<MediaFailure, Uint8List>> Function(
      MessageAttachment attachment,
    );

/// A message's photo or GIF: its blurred preview while it loads, then the
/// image, or a way to try again if it could not be loaded.
class EncryptedImage extends StatefulWidget {
  final MessageAttachment attachment;
  final AttachmentLoader loader;
  final BoxFit fit;

  const EncryptedImage({
    super.key,
    required this.attachment,
    required this.loader,
    this.fit = BoxFit.cover,
  });

  @override
  State<EncryptedImage> createState() => _EncryptedImageState();
}

class _EncryptedImageState extends State<EncryptedImage> {
  late Future<Either<MediaFailure, Uint8List>> _image = widget.loader(
    widget.attachment,
  );

  @override
  void didUpdateWidget(EncryptedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attachment.id != widget.attachment.id) {
      _image = widget.loader(widget.attachment);
    }
  }

  // A block, not an arrow: setState refuses a callback that returns a future.
  void _retry() => setState(() {
    _image = widget.loader(widget.attachment);
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: widget.attachment.kind == AttachmentKind.gif ? 'GIF' : 'Photo',
      child: FutureBuilder(
        future: _image,
        builder: (context, snapshot) {
          // A retry keeps the last result until the new one arrives, so check
          // the state rather than the data.
          final result = snapshot.connectionState == ConnectionState.done
              ? snapshot.data
              : null;
          if (snapshot.hasError) return _Failed(onRetry: _retry);
          if (result == null) {
            return _Loading(
              thumbnail: widget.attachment.thumbnail,
              fit: widget.fit,
            );
          }
          return result.fold(
            (_) => _Failed(onRetry: _retry),
            (bytes) => Image.memory(
              bytes,
              fit: widget.fit,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
              excludeFromSemantics: true,
            ),
          );
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  final Uint8List? thumbnail;
  final BoxFit fit;

  const _Loading({required this.thumbnail, required this.fit});

  @override
  Widget build(BuildContext context) {
    final thumbnail = this.thumbnail;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumbnail != null)
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Image.memory(
                thumbnail,
                fit: fit,
                gaplessPlayback: true,
                excludeFromSemantics: true,
              ),
            ),
          )
        else
          ColoredBox(color: AppColors.of(context).skeleton),
        const Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  final VoidCallback onRetry;

  const _Failed({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onRetry,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_outlined, color: muted),
              const SizedBox(height: 4),
              Text(
                'Tap to retry',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
