import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// The image work the phone does natively: re-encoding and measuring.
abstract interface class ImageTools {
  /// [image] as a JPEG whose shorter side is at most [side] pixels, turned
  /// upright, and without metadata such as where it was taken.
  Future<Uint8List> toJpeg(
    Uint8List image, {
    required int side,
    required int quality,
  });

  /// The width and height of [image], in pixels.
  Future<(int, int)> sizeOf(Uint8List image);
}

class NativeImageTools implements ImageTools {
  @override
  Future<Uint8List> toJpeg(
    Uint8List image, {
    required int side,
    required int quality,
  }) => FlutterImageCompress.compressWithList(
    image,
    minWidth: side,
    minHeight: side,
    quality: quality,
    format: CompressFormat.jpeg,
    keepExif: false,
  );

  @override
  Future<(int, int)> sizeOf(Uint8List image) async {
    final codec = await ui.instantiateImageCodec(image);
    try {
      final frame = await codec.getNextFrame();
      final size = (frame.image.width, frame.image.height);
      frame.image.dispose();
      return size;
    } finally {
      codec.dispose();
    }
  }
}
