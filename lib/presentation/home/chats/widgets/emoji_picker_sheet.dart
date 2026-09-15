import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Opens every emoji to choose from, and returns the one chosen; null when
/// closed without choosing.
///
/// The picker's own recent emojis are off: it would keep them unencrypted in
/// the phone's shared preferences. The emojis the user uses most are offered
/// before this opens, and kept encrypted (EmojiPreferencesStore).
Future<String?> pickEmoji(BuildContext context) => showModalBottomSheet<String>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) {
    final scheme = Theme.of(context).colorScheme;
    final background = scheme.surfaceContainerLow;
    return Padding(
      // The search field brings up the keyboard, which the picker stays above.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: EmojiPicker(
          onEmojiSelected: (_, emoji) => Navigator.of(context).pop(emoji.emoji),
          config: Config(
            height: 360,
            emojiViewConfig: EmojiViewConfig(
              backgroundColor: background,
              columns: 8,
              emojiSizeMax: 30,
            ),
            categoryViewConfig: CategoryViewConfig(
              recentTabBehavior: RecentTabBehavior.NONE,
              initCategory: Category.SMILEYS,
              backgroundColor: background,
              indicatorColor: scheme.primary,
              iconColor: scheme.onSurfaceVariant,
              iconColorSelected: scheme.primary,
              backspaceColor: scheme.primary,
              dividerColor: scheme.outlineVariant,
            ),
            skinToneConfig: SkinToneConfig(
              dialogBackgroundColor: scheme.surfaceContainerHighest,
              indicatorColor: scheme.onSurfaceVariant,
            ),
            bottomActionBarConfig: BottomActionBarConfig(
              showBackspaceButton: false,
              backgroundColor: background,
              buttonColor: background,
              buttonIconColor: scheme.onSurfaceVariant,
            ),
            searchViewConfig: SearchViewConfig(
              backgroundColor: background,
              buttonIconColor: scheme.onSurfaceVariant,
              hintText: 'Search emoji',
            ),
          ),
        ),
      ),
    );
  },
);
