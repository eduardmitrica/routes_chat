import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/local_chat_repository_interface.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/infrastructure/core/local_vault.dart';

/// Drafts and messages on their way, kept encrypted on the phone (see
/// [LocalVault]).
///
/// Each draft and each message is a small JSON file. Their photos are files
/// of their own, which a draft and the message sent from it share, deleted
/// once nothing refers to them.
class LocalChatStore implements IDraftRepository, IOutboxRepository {
  static const _draftPrefix = 'draft_';
  static const _outboxPrefix = 'outbox_';
  static const _mediaPrefix = 'media_';
  static const _filesToDelete = 'files_to_delete';

  final LocalVault _vault;

  /// Every operation waits for the one before, so a photo written for one
  /// file is never deleted as unused before that file refers to it.
  Future<void> _tail = Future.value();

  LocalChatStore(this._vault);

  Future<T> _inTurn<T>(Future<T> Function() task) {
    final result = _tail.then((_) => task());
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }

  /// Whether [error] comes from a stored file in an unexpected shape.
  static bool _malformed(Object error) =>
      error is TypeError || error is ArgumentError || error is FormatException;

  // ─── Drafts ─────────────────────────────────────────────────────────────

  @override
  Future<ChatDraft?> loadDraft(UniqueId chatId) => _inTurn(() async {
    final json = await _readJson('$_draftPrefix${chatId.getOrCrash()}');
    if (json == null) return null;
    try {
      return ChatDraft(
        text: json['text'] as String? ?? '',
        replyTo: _quoteFrom(json['replyTo']),
        media: await _mediaFrom(json['media']),
      );
    } catch (error) {
      if (!_malformed(error)) rethrow;
      debugPrint('Draft left out: not in the stored format');
      return null;
    }
  });

  @override
  Future<void> saveDraft(UniqueId chatId, ChatDraft draft) => _inTurn(() async {
    final name = '$_draftPrefix${chatId.getOrCrash()}';
    if (draft.isEmpty) {
      await _vault.delete(name);
    } else {
      await _keepMedia(draft.media);
      await _writeJson(name, {
        'text': draft.text,
        if (draft.replyTo case final quote?) 'replyTo': _quoteToJson(quote),
        'media': [for (final photo in draft.media.iter) _draftToJson(photo)],
      });
    }
    await _deleteUnusedMedia();
  });

  // ─── Outbox ─────────────────────────────────────────────────────────────

  @override
  Future<KtList<OutgoingMessage>> queued() => _inTurn(() async {
    final messages = <OutgoingMessage>[];
    for (final name in await _vault.names(_outboxPrefix)) {
      final json = await _readJson(name);
      if (json == null) continue;
      try {
        messages.add(await _outgoingFrom(json));
      } catch (error) {
        if (!_malformed(error)) rethrow;
        debugPrint('Message on its way left out: not in the stored format');
      }
    }
    messages.sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
    return messages.toImmutableList();
  });

  @override
  Future<void> keep(OutgoingMessage message) => _inTurn(() async {
    await _keepMedia(message.media);
    await _writeJson(
      '$_outboxPrefix${message.id.getOrCrash()}',
      _outgoingToJson(message),
    );
  });

  @override
  Future<void> forget(UniqueId messageId) => _inTurn(() async {
    await _vault.delete('$_outboxPrefix${messageId.getOrCrash()}');
    await _deleteUnusedMedia();
  });

  @override
  Future<List<(UniqueId, UniqueId)>> filesToDelete() =>
      _inTurn(_readFilesToDelete);

  @override
  Future<void> addFilesToDelete(Iterable<(UniqueId, UniqueId)> files) =>
      _inTurn(() async {
        final current = await _readFilesToDelete();
        await _writeFilesToDelete([
          ...current,
          ...files.where((file) => !current.contains(file)),
        ]);
      });

  @override
  Future<void> removeFileToDelete(UniqueId chatId, UniqueId fileId) =>
      _inTurn(() async {
        await _writeFilesToDelete([
          for (final file in await _readFilesToDelete())
            if (file != (chatId, fileId)) file,
        ]);
      });

  Future<List<(UniqueId, UniqueId)>> _readFilesToDelete() async {
    final files = (await _readJson(_filesToDelete))?['files'];
    return [
      if (files is List)
        for (final file in files)
          if (file case {
            'chatId': final String chatId,
            'fileId': final String fileId,
          })
            (
              UniqueId.fromUniqueString(chatId),
              UniqueId.fromUniqueString(fileId),
            ),
    ];
  }

  Future<void> _writeFilesToDelete(List<(UniqueId, UniqueId)> files) =>
      files.isEmpty
      ? _vault.delete(_filesToDelete)
      : _writeJson(_filesToDelete, {
          'files': [
            for (final (chatId, fileId) in files)
              {'chatId': chatId.getOrCrash(), 'fileId': fileId.getOrCrash()},
          ],
        });

  // ─── Photos ─────────────────────────────────────────────────────────────

  Future<void> _keepMedia(KtList<MediaDraft> media) async {
    final stored = (await _vault.names(_mediaPrefix)).toSet();
    for (final photo in media.iter) {
      final name = '$_mediaPrefix${photo.id.getOrCrash()}';
      if (!stored.contains(name)) await _vault.write(name, photo.bytes);
    }
  }

  /// Deletes the photos no draft and no message on its way refers to.
  Future<void> _deleteUnusedMedia() async {
    final used = <String>{};
    for (final name in [
      ...await _vault.names(_draftPrefix),
      ...await _vault.names(_outboxPrefix),
    ]) {
      final media = (await _readJson(name))?['media'];
      if (media is! List) continue;
      for (final photo in media) {
        if (photo case {'id': final String id}) used.add('$_mediaPrefix$id');
      }
    }
    for (final name in await _vault.names(_mediaPrefix)) {
      if (!used.contains(name)) await _vault.delete(name);
    }
  }

  Future<KtList<MediaDraft>> _mediaFrom(Object? json) async {
    final media = <MediaDraft>[];
    for (final item in json as List? ?? const []) {
      final photo = item as Map;
      final id = photo['id'] as String;
      final bytes = await _vault.read('$_mediaPrefix$id');
      // Its file is gone: the photo is left out rather than the whole draft.
      if (bytes == null) continue;
      media.add(
        MediaDraft(
          id: UniqueId.fromUniqueString(id),
          kind: AttachmentKind.values.byName(photo['kind'] as String),
          bytes: bytes,
          width: photo['width'] as int,
          height: photo['height'] as int,
          thumbnail: _bytesFrom(photo['thumb']),
          duration: _durationFrom(photo['durationMs']),
          waveform: _bytesFrom(photo['waveform']),
        ),
      );
    }
    return media.toImmutableList();
  }

  // ─── JSON ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _readJson(String name) async {
    final bytes = await _vault.read(name);
    if (bytes == null) return null;
    try {
      final json = jsonDecode(utf8.decode(bytes));
      return json is Map<String, dynamic> ? json : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> _writeJson(String name, Map<String, Object?> json) =>
      _vault.write(name, utf8.encode(jsonEncode(json)));

  static Uint8List? _bytesFrom(Object? json) =>
      json is String ? base64Decode(json) : null;

  static Duration? _durationFrom(Object? json) =>
      json is int ? Duration(milliseconds: json) : null;

  static Map<String, Object?> _draftToJson(MediaDraft photo) => {
    'id': photo.id.getOrCrash(),
    'kind': photo.kind.name,
    'width': photo.width,
    'height': photo.height,
    if (photo.thumbnail case final thumb?) 'thumb': base64Encode(thumb),
    'durationMs': ?photo.duration?.inMilliseconds,
    if (photo.waveform case final waveform?) 'waveform': base64Encode(waveform),
  };

  static Map<String, Object?> _quoteToJson(MessageQuote quote) => {
    'id': quote.messageId.getOrCrash(),
    'senderId': quote.senderId.getOrCrash(),
    'text': quote.text,
    if (quote.thumbnail case final thumb?) 'thumb': base64Encode(thumb),
  };

  static MessageQuote? _quoteFrom(Object? json) => json is Map
      ? MessageQuote(
          messageId: UniqueId.fromUniqueString(json['id'] as String),
          senderId: UniqueId.fromUniqueString(json['senderId'] as String),
          text: json['text'] as String,
          thumbnail: _bytesFrom(json['thumb']),
        )
      : null;

  static Map<String, Object?> _attachmentToJson(MessageAttachment file) => {
    'id': file.id.getOrCrash(),
    'kind': file.kind.name,
    'width': file.width,
    'height': file.height,
    'size': file.byteSize,
    'key': base64Encode(file.key),
    if (file.thumbnail case final thumb?) 'thumb': base64Encode(thumb),
    'durationMs': ?file.duration?.inMilliseconds,
    if (file.waveform case final waveform?) 'waveform': base64Encode(waveform),
  };

  static MessageAttachment _attachmentFrom(Map<dynamic, dynamic> json) =>
      MessageAttachment(
        id: UniqueId.fromUniqueString(json['id'] as String),
        kind: AttachmentKind.values.byName(json['kind'] as String),
        width: json['width'] as int,
        height: json['height'] as int,
        byteSize: json['size'] as int,
        key: base64Decode(json['key'] as String),
        thumbnail: _bytesFrom(json['thumb']),
        duration: _durationFrom(json['durationMs']),
        waveform: _bytesFrom(json['waveform']),
      );

  static Map<String, Object?> _outgoingToJson(OutgoingMessage outgoing) => {
    'id': outgoing.id.getOrCrash(),
    'senderId': outgoing.message.senderId.getOrCrash(),
    'text': outgoing.message.content.getOrCrash(),
    if (outgoing.message.replyTo case final quote?)
      'replyTo': _quoteToJson(quote),
    'chatId': outgoing.chatId.getOrCrash(),
    'startsChatWith': [
      for (final id in outgoing.startsChatWith.iter) id.getOrCrash(),
    ],
    'media': [for (final photo in outgoing.media.iter) _draftToJson(photo)],
    'attachments': {
      for (final MapEntry(:key, :value) in outgoing.attachments.entries)
        key: _attachmentToJson(value),
    },
    'status': outgoing.status.name,
    'failures': outgoing.failures,
    'queuedAt': outgoing.queuedAt.toUtc().toIso8601String(),
  };

  Future<OutgoingMessage> _outgoingFrom(Map<String, dynamic> json) async =>
      OutgoingMessage(
        message: Message(
          id: UniqueId.fromUniqueString(json['id'] as String),
          senderId: UniqueId.fromUniqueString(json['senderId'] as String),
          imageUrls: const KtList.empty(),
          reactions: const KtList.empty(),
          content: Content(json['text'] as String),
          replyTo: _quoteFrom(json['replyTo']),
          lastUpdatedAt: null,
          isEdited: false,
        ),
        chatId: UniqueId.fromUniqueString(json['chatId'] as String),
        startsChatWith: [
          for (final id in json['startsChatWith'] as List)
            UniqueId.fromUniqueString(id as String),
        ].toImmutableList(),
        media: await _mediaFrom(json['media']),
        attachments: {
          for (final MapEntry(:key, :value)
              in (json['attachments'] as Map).entries)
            key as String: _attachmentFrom(value as Map),
        },
        status: OutgoingStatus.values.byName(json['status'] as String),
        failures: json['failures'] as int,
        queuedAt: DateTime.parse(json['queuedAt'] as String),
      );
}
