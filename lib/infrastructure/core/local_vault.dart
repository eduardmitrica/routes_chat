import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:routes_chat/domain/shared/user/current_user_session_interface.dart';

/// Where small secrets are kept: the phone's secure storage.
abstract interface class SecretStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class SecureSecretStore implements SecretStore {
  final FlutterSecureStorage _storage;

  const SecureSecretStore(this._storage);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Files the app keeps on the phone for the signed-in user, such as unsent
/// drafts and messages on their way.
///
/// They hold what messages hold, so each is encrypted with AES-256-GCM under
/// a key that lives in the phone's secure storage, and bound to its name: a
/// copy of the app's files alone reads nothing, and one file cannot pass for
/// another. When the session ends, every such file and the key are deleted.
class LocalVault {
  static const _keyEntry = 'local_chats_key';

  final SecretStore _secrets;
  final ICurrentUserSession _session;
  final Future<Directory> Function() _baseDirectory;
  SecretKey? _key;

  AesGcm get _aead => AesGcm.with256bits();

  LocalVault(
    this._secrets,
    this._session, {
    Future<Directory> Function()? baseDirectory,
  }) : _baseDirectory = baseDirectory ?? getApplicationSupportDirectory {
    _session.ended.listen((_) => wipe());
  }

  static String _safe(String part) =>
      part.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  Future<Directory> _root() async =>
      Directory('${(await _baseDirectory()).path}/local_chats');

  /// The signed-in user's directory. Files of a user who signed out are
  /// already deleted, so another user never finds them.
  Future<Directory> _directory() async {
    final uid = _session.current?.id;
    if (uid == null) {
      throw StateError('Nobody is signed in');
    }
    return Directory('${(await _root()).path}/${_safe(uid)}');
  }

  Future<File> _file(String name) async =>
      File('${(await _directory()).path}/${_safe(name)}');

  Future<SecretKey> _secretKey() async {
    if (_key case final key?) return key;
    final stored = await _secrets.read(_keyEntry);
    if (stored != null) {
      return _key = SecretKey(base64Decode(stored));
    }
    final created = SecretKeyData.random(length: 32);
    await _secrets.write(_keyEntry, base64Encode(created.bytes));
    return _key = created;
  }

  /// Keeps [content] as the file [name], replacing any before it.
  Future<void> write(String name, List<int> content) async {
    final file = await _file(name);
    await file.parent.create(recursive: true);
    final box = await _aead.encrypt(
      content,
      secretKey: await _secretKey(),
      aad: utf8.encode(name),
    );
    // Written beside it and moved into place, so a closed app never leaves
    // half a file.
    final partial = File('${file.path}.partial');
    await partial.writeAsBytes(box.concatenation(), flush: true);
    await partial.rename(file.path);
  }

  /// The content of [name]; null when there is none, or it does not decrypt.
  Future<Uint8List?> read(String name) async {
    final file = await _file(name);
    if (!await file.exists()) return null;
    final stored = await file.readAsBytes();
    if (stored.length < 28) return null;
    try {
      return Uint8List.fromList(
        await _aead.decrypt(
          SecretBox.fromConcatenation(
            stored,
            nonceLength: 12,
            macLength: 16,
            copy: false,
          ),
          secretKey: await _secretKey(),
          aad: utf8.encode(name),
        ),
      );
    } on SecretBoxAuthenticationError {
      debugPrint('Local file left out: it does not decrypt');
      return null;
    }
  }

  Future<void> delete(String name) async {
    final file = await _file(name);
    if (await file.exists()) await file.delete();
  }

  /// The names of the files that start with [prefix].
  Future<List<String>> names(String prefix) async {
    final directory = await _directory();
    if (!await directory.exists()) return [];
    return [
      await for (final entity in directory.list())
        if (entity is File)
          if (entity.uri.pathSegments.last case final name
              when name.startsWith(prefix) && !name.endsWith('.partial'))
            name,
    ];
  }

  /// Deletes every file kept, and the key they were encrypted with.
  Future<void> wipe() async {
    _key = null;
    try {
      final root = await _root();
      if (await root.exists()) await root.delete(recursive: true);
      await _secrets.delete(_keyEntry);
    } on Exception catch (exception) {
      debugPrint('Local files not deleted: ${exception.runtimeType}');
    }
  }
}
