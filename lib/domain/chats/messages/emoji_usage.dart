import 'dart:math';

import 'package:characters/characters.dart';

/// Keeps what the user reacts with, and the emojis they send.
abstract interface class IEmojiPreferences {
  /// Up to [count] of the emojis the user uses most, favouring recent use.
  /// Empty until they use any: there is no fixed set to start from.
  Future<List<String>> favourites({required int count});

  /// Counts one use of each of [emojis].
  Future<void> recordUse(Iterable<String> emojis);
}

/// The emojis in [text], each one as it was written, such as with a skin
/// tone, in order.
List<String> emojisIn(String text) => [
  for (final character in text.characters)
    if (_emoji.hasMatch(character)) character,
];

/// A character shown as an emoji: one whose default look is an emoji, one
/// asked to look like one (U+FE0F), or a flag.
///
/// The analyzer does not know Unicode property escapes; Dart does, with
/// `unicode: true`, and emoji_usage_test.dart checks the pattern.
final _emoji = RegExp(
  // ignore: valid_regexps
  r'\p{Emoji_Presentation}|\p{Extended_Pictographic}️|\p{Regional_Indicator}',
  unicode: true,
);

/// How often the user used each emoji, weighed by how recently.
///
/// Each use adds one to the emoji's score, and scores halve every [halfLife]
/// that passes, so the favourites follow what the user uses these days, the
/// way the reactions Instagram suggests do.
final class EmojiUsage {
  static const halfLife = Duration(days: 7);

  /// The most emojis remembered. The least used are forgotten first.
  static const maxRemembered = 64;

  final Map<String, ({double score, DateTime at})> _scores;

  EmojiUsage._(this._scores);

  EmojiUsage.empty() : this._({});

  /// What [toJson] made. Entries in any other shape are passed over.
  factory EmojiUsage.fromJson(Object? json) {
    final scores = <String, ({double score, DateTime at})>{};
    if (json is Map) {
      for (final MapEntry(:key, :value) in json.entries) {
        if (key is String && value is List && value.length == 2) {
          final [score, at] = value;
          if (score is num && at is int) {
            scores[key] = (
              score: score.toDouble(),
              at: DateTime.fromMillisecondsSinceEpoch(at, isUtc: true),
            );
          }
        }
      }
    }
    return EmojiUsage._(scores);
  }

  Map<String, Object> toJson() => {
    for (final MapEntry(:key, :value) in _scores.entries)
      key: [value.score, value.at.millisecondsSinceEpoch],
  };

  static double _decayed(({double score, DateTime at}) entry, DateTime now) {
    final elapsed = now.difference(entry.at);
    if (elapsed <= Duration.zero) return entry.score;
    return entry.score *
        pow(0.5, elapsed.inMilliseconds / halfLife.inMilliseconds);
  }

  /// Counts one use of [emoji] at [now].
  void record(String emoji, DateTime now) {
    final before = _scores[emoji];
    _scores[emoji] = (
      score: (before == null ? 0 : _decayed(before, now)) + 1,
      at: now,
    );
    if (_scores.length > maxRemembered) {
      // Never the emoji just used.
      final least = _scores.keys
          .where((key) => key != emoji)
          .reduce(
            (a, b) => _decayed(_scores[a]!, now) <= _decayed(_scores[b]!, now)
                ? a
                : b,
          );
      _scores.remove(least);
    }
  }

  /// Up to [count] emojis, the most used first. Ties go to the one used
  /// last.
  List<String> top(int count, DateTime now) {
    final ranked = _scores.entries.toList()
      ..sort((a, b) {
        final byScore = _decayed(
          b.value,
          now,
        ).compareTo(_decayed(a.value, now));
        return byScore != 0 ? byScore : b.value.at.compareTo(a.value.at);
      });
    return [for (final entry in ranked.take(count)) entry.key];
  }
}
