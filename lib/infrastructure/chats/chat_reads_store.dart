import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/chats/chat_reads.dart';
import '../../domain/core/value_objects.dart';
import '../../domain/shared/user/current_user_session_interface.dart';
import '../core/local_vault.dart';

/// How far the user has read each chat, in a file on the phone encrypted
/// like drafts (see [LocalVault]), which signing out deletes.
class ChatReadsStore implements IChatReads {
  static const _file = 'chat_reads';

  final LocalVault _vault;
  final DateTime Function() _now;

  var _reads = BehaviorSubject<ChatReads>();
  Future<ChatReads>? _loaded;

  /// Each change waits for the one before, so none is lost.
  Future<void> _tail = Future.value();

  ChatReadsStore(
    this._vault,
    ICurrentUserSession session, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    // The next user starts from their own file.
    session.ended.listen((_) {
      final previous = _reads;
      _reads = BehaviorSubject<ChatReads>();
      _loaded = null;
      unawaited(previous.close());
    });
  }

  Future<T> _inTurn<T>(Future<T> Function() task) {
    final result = _tail.then((_) => task());
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<ChatReads> _load() => _loaded ??= () async {
    final reads = await _read() ?? await _started();
    _reads.add(reads);
    return reads;
  }();

  Future<ChatReads?> _read() async {
    try {
      final bytes = await _vault.read(_file);
      if (bytes == null) return null;
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return ChatReads(
        since: DateTime.fromMillisecondsSinceEpoch(
          json['since'] as int,
          isUtc: true,
        ),
        readUpTo: {
          for (final MapEntry(:key, :value)
              in (json['chats'] as Map<String, dynamic>).entries)
            key: DateTime.fromMicrosecondsSinceEpoch(value as int, isUtc: true),
        },
      );
    } on Object catch (error) {
      if (error is! TypeError && error is! FormatException) rethrow;
      debugPrint('Chat reads not in the stored format; starting again');
      return null;
    }
  }

  /// A phone that starts keeping track now: what came before counts as read.
  Future<ChatReads> _started() async {
    final reads = ChatReads(since: _now().toUtc());
    await _write(reads);
    return reads;
  }

  Future<void> _write(ChatReads reads) async {
    try {
      await _vault.write(
        _file,
        utf8.encode(
          jsonEncode({
            'since': reads.since.millisecondsSinceEpoch,
            'chats': {
              for (final MapEntry(:key, :value) in reads.readUpTo.entries)
                key: value.microsecondsSinceEpoch,
            },
          }),
        ),
      );
    } on Object catch (error) {
      debugPrint('Chat reads not saved: ${error.runtimeType}');
    }
  }

  @override
  Stream<ChatReads> watch() {
    unawaited(
      _inTurn(_load).catchError((Object error) {
        debugPrint('Chat reads not loaded: ${error.runtimeType}');
        return ChatReads(since: _now().toUtc());
      }),
    );
    return _reads.stream;
  }

  @override
  Future<void> markRead(UniqueId chatId, DateTime sentAt) => _inTurn(() async {
    try {
      final reads = await _load();
      final id = chatId.getOrCrash();
      if (!sentAt.isAfter(reads.readUpToIn(id))) return;
      final next = ChatReads(
        since: reads.since,
        readUpTo: {...reads.readUpTo, id: sentAt.toUtc()},
      );
      _loaded = Future.value(next);
      _reads.add(next);
      await _write(next);
    } on Object catch (error) {
      debugPrint('Chat not marked read: ${error.runtimeType}');
    }
  });
}
