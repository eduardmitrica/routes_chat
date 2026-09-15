import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

/// The phone's photos, which the app can add to.
abstract interface class PhotoLibrary {
  Future<bool> hasAccess();

  /// Asks the user to let the app add photos. True if they did.
  Future<bool> requestAccess();

  /// Adds [image] to the phone's photos as [name], a GIF when [gif].
  ///
  /// Throws [PhotoAccessException] when the app may not add photos.
  Future<void> save(Uint8List image, {required String name, required bool gif});
}

final class PhotoAccessException implements Exception {
  const PhotoAccessException();
}

class GalPhotoLibrary implements PhotoLibrary {
  final Future<Directory> Function() _temporaryDirectory;

  GalPhotoLibrary({Future<Directory> Function()? temporaryDirectory})
    : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  @override
  Future<bool> hasAccess() => Gal.hasAccess();

  @override
  Future<bool> requestAccess() => Gal.requestAccess();

  @override
  Future<void> save(
    Uint8List image, {
    required String name,
    required bool gif,
  }) async {
    // Written to a file first, whose extension keeps a GIF a GIF.
    final file = File(
      '${(await _temporaryDirectory()).path}/$name.${gif ? 'gif' : 'jpg'}',
    );
    await file.writeAsBytes(image, flush: true);
    try {
      await Gal.putImage(file.path);
    } on GalException catch (exception) {
      if (exception.type == GalExceptionType.accessDenied) {
        throw const PhotoAccessException();
      }
      rethrow;
    } finally {
      if (await file.exists()) await file.delete();
    }
  }
}
