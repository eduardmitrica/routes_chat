import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:routes_chat/domain/chats/messages/emoji_usage.dart';
import 'package:routes_chat/infrastructure/core/local_vault.dart';

/// The emojis the user uses, counted on the phone only, in a file encrypted
/// like drafts (see [LocalVault]). What someone reacts with is encrypted in
/// the chat, and what they use most would say as much.
class EmojiPreferencesStore implements IEmojiPreferences {
  static const _file = 'emoji_usage';

  final LocalVault _vault;
  final DateTime Function() _now;

  /// Each update waits for the one before, so two at once both count.
  Future<void> _tail = Future.value();

  EmojiPreferencesStore(this._vault, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  Future<T> _inTurn<T>(Future<T> Function() task) {
    final result = _tail.then((_) => task());
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<EmojiUsage> _load() async {
    try {
      final bytes = await _vault.read(_file);
      if (bytes == null) return EmojiUsage.empty();
      return EmojiUsage.fromJson(jsonDecode(utf8.decode(bytes)));
    } on Exception catch (exception) {
      debugPrint('Emoji use not loaded: ${exception.runtimeType}');
      return EmojiUsage.empty();
    }
  }

  @override
  Future<List<String>> favourites({required int count}) =>
      _inTurn(() async => (await _load()).top(count, _now()));

  @override
  Future<void> recordUse(Iterable<String> emojis) => _inTurn(() async {
    if (emojis.isEmpty) return;
    final usage = await _load();
    final now = _now();
    for (final emoji in emojis) {
      usage.record(emoji, now);
    }
    try {
      await _vault.write(_file, utf8.encode(jsonEncode(usage.toJson())));
    } on Exception catch (exception) {
      debugPrint('Emoji use not saved: ${exception.runtimeType}');
    }
  });
}
