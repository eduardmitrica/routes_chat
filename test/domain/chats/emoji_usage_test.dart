import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/emoji_usage.dart';

void main() {
  group('the emojis in a text', () {
    test('are found as written, in order', () {
      expect(emojisIn('Salut 👋🏽! Ce faci? ❤️ 🇷🇴'), ['👋🏽', '❤️', '🇷🇴']);
    });

    test('leave out letters, digits and symbols not shown as emojis', () {
      expect(emojisIn('Preț: 10 € © 2026 #1 ❤ ăîșț'), isEmpty);
    });

    test('keep a sequence such as a couple as one emoji', () {
      expect(emojisIn('👩‍❤️‍💋‍👨 da'), ['👩‍❤️‍💋‍👨']);
    });
  });

  group('the emojis a user uses', () {
    final now = DateTime.utc(2026, 9, 15, 12);

    test('are none to start with: nothing is chosen for the user', () {
      expect(EmojiUsage.empty().top(6, now), isEmpty);
    });

    test('come most used first', () {
      final usage = EmojiUsage.empty();
      for (final emoji in ['😂', '❤️', '❤️', '👍', '❤️', '👍']) {
        usage.record(emoji, now);
      }

      expect(usage.top(6, now), ['❤️', '👍', '😂']);
      expect(usage.top(2, now), ['❤️', '👍']);
    });

    test('favour what is used these days over what was used a lot', () {
      final usage = EmojiUsage.empty();
      final monthAgo = now.subtract(const Duration(days: 30));
      for (var time = 0; time < 5; time++) {
        usage.record('😂', monthAgo);
      }
      usage
        ..record('🔥', now)
        ..record('🔥', now);

      expect(usage.top(2, now), ['🔥', '😂']);
    });

    test('forget the least used past the limit, never the one just used', () {
      final usage = EmojiUsage.empty()
        ..record('❤️', now)
        ..record('❤️', now);
      for (var index = 0; index < EmojiUsage.maxRemembered; index++) {
        usage.record(String.fromCharCode(0x1F600 + index), now);
      }

      final remembered = usage.top(1000, now);
      expect(remembered, hasLength(EmojiUsage.maxRemembered));
      expect(remembered.first, '❤️');
      expect(remembered, contains(String.fromCharCode(0x1F600 + 63)));
    });

    test('come back from what was stored', () {
      final usage = EmojiUsage.empty()
        ..record('❤️', now)
        ..record('👍', now)
        ..record('❤️', now);

      final restored = EmojiUsage.fromJson(
        jsonDecode(jsonEncode(usage.toJson())),
      );

      expect(restored.top(6, now), ['❤️', '👍']);
    });

    test('pass over stored entries in another shape', () {
      expect(
        EmojiUsage.fromJson({
          '❤️': 'lots',
          '👍': [1, 'yesterday'],
          '🔥': [2.5, 0],
        }).top(6, now),
        ['🔥'],
      );
      expect(EmojiUsage.fromJson('nothing').top(6, now), isEmpty);
    });
  });
}
