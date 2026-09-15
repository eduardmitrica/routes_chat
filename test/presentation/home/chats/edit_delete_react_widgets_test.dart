import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_changes.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/message_reaction.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/message_bubble.dart';
import 'package:routes_chat/presentation/home/chats/widgets/message_composer.dart';
import 'package:routes_chat/presentation/home/chats/widgets/message_reactions.dart';
import 'package:routes_chat/presentation/home/chats/widgets/reaction_bar.dart';

Message _message({
  String text = 'Salut',
  bool edited = false,
  bool deleted = false,
  MessageQuote? replyTo,
}) => Message(
  id: UniqueId.fromUniqueString('message-2'),
  senderId: UniqueId.fromUniqueString('uid-alice'),
  imageUrls: const KtList.empty(),
  content: Content(text),
  replyTo: replyTo,
  lastUpdatedAt: null,
  isEdited: edited,
  isDeleted: deleted,
);

MessageReaction _reaction(String userId, String emoji) => MessageReaction(
  messageId: UniqueId.fromUniqueString('message-2'),
  userId: UniqueId.fromUniqueString(userId),
  emoji: emoji,
);

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('a message bubble', () {
    testWidgets('of a deleted message says only that', (tester) async {
      await tester.pumpWidget(
        _app(
          MessageBubble(message: _message(text: '', deleted: true), sent: true),
        ),
      );

      expect(find.text(deletedMessageText), findsOneWidget);
    });

    testWidgets('of an edited message says it was edited', (tester) async {
      await tester.pumpWidget(
        _app(MessageBubble(message: _message(edited: true), sent: false)),
      );
      expect(find.text('edited'), findsOneWidget);

      await tester.pumpWidget(
        _app(MessageBubble(message: _message(), sent: false)),
      );
      expect(find.text('edited'), findsNothing);
    });

    testWidgets('of a reply to a deleted message says it was deleted', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          MessageBubble(
            message: _message(
              text: 'Da',
              replyTo: MessageQuote(
                messageId: UniqueId.fromUniqueString('message-1'),
                senderId: UniqueId.fromUniqueString('uid-bob'),
                text: '',
                originalDeleted: true,
              ),
            ),
            sent: true,
            quoteAuthor: 'bob',
          ),
        ),
      );

      expect(find.text(deletedMessageText), findsOneWidget);
      expect(find.text('Da'), findsOneWidget);
    });

    testWidgets('shows its reactions: each emoji once, with how many', (
      tester,
    ) async {
      var tapped = 0;
      await tester.pumpWidget(
        _app(
          MessageBubble(
            message: _message(),
            sent: false,
            reactions: MessageReactions(
              reactions: KtList.of(
                _reaction('uid-bob', '❤️'),
                _reaction('uid-alice', '👍'),
                _reaction('uid-carol', '❤️'),
              ),
              onTap: () => tapped++,
            ),
          ),
        ),
      );

      expect(find.text('❤️👍'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.text('❤️👍'));
      expect(tapped, 1);
    });
  });

  test('reactions show the most common emoji first, then by who was first', () {
    expect(
      MessageReactions.emojisByCount(
        KtList.of(
          _reaction('a', '😂'),
          _reaction('b', '👍'),
          _reaction('c', '🔥'),
          _reaction('d', '👍'),
        ),
      ),
      ['👍', '😂', '🔥'],
    );
  });

  group('the reaction bar', () {
    testWidgets('offers only the full picker before any emoji was used', (
      tester,
    ) async {
      var more = 0;
      await tester.pumpWidget(
        _app(
          ReactionBar(
            favourites: const [],
            current: null,
            onPicked: (_) {},
            onMore: () => more++,
          ),
        ),
      );

      await tester.tap(find.text('React'));

      expect(more, 1);
    });

    testWidgets("shows the user's reaction and favourites; tapping picks", (
      tester,
    ) async {
      final picked = <String>[];
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          ReactionBar(
            favourites: const ['❤️', '👍'],
            current: '🔥',
            onPicked: picked.add,
            onMore: () {},
          ),
        ),
      );

      expect(find.text('🔥'), findsOneWidget);
      expect(find.bySemanticsLabel('Remove your reaction 🔥'), findsOneWidget);
      expect(find.bySemanticsLabel('React with ❤️'), findsOneWidget);
      await tester.tap(find.text('👍'));

      expect(picked, ['👍']);
      semantics.dispose();
    });
  });

  group('the composer, editing', () {
    late FocusNode focus;

    setUp(() => focus = FocusNode());
    tearDown(() => focus.dispose());

    Future<void> show(
      WidgetTester tester, {
      String text = 'Salut',
      bool savingEdit = false,
      bool canSaveEmpty = false,
      List<String>? sent,
      VoidCallback? onCancelEdit,
    }) => tester.pumpWidget(
      _app(
        MessageComposer(
          focusNode: focus,
          onChanged: (_) {},
          onSend: (text) => sent?.add(text),
          replyingTo: null,
          replyingToName: 'bob',
          onCancelReply: () {},
          text: text,
          textRevision: 1,
          onAddMedia: () {},
          editing: true,
          savingEdit: savingEdit,
          canSaveEmpty: canSaveEmpty,
          onCancelEdit: onCancelEdit ?? () {},
        ),
      ),
    );

    IconButton saveButton(WidgetTester tester) => tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.check_rounded),
    );

    testWidgets('saves the new text, keeps it in the field, and cancels', (
      tester,
    ) async {
      final sent = <String>[];
      var cancelled = 0;
      await show(tester, sent: sent, onCancelEdit: () => cancelled++);

      expect(find.text('Editing message'), findsOneWidget);
      expect(find.byTooltip('Add photos or GIFs'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Salut!  ');
      await tester.pump();
      await tester.tap(find.byTooltip('Save edit'));
      await tester.pump();
      await tester.tap(find.byTooltip('Cancel edit'));

      expect(sent, ['Salut!']);
      expect(find.text('Salut!  '), findsOneWidget);
      expect(cancelled, 1);
    });

    testWidgets('may leave a photo without a caption, not a text empty', (
      tester,
    ) async {
      await show(tester, text: '', canSaveEmpty: true);
      expect(saveButton(tester).onPressed, isNotNull);

      await show(tester, text: '');
      expect(saveButton(tester).onPressed, isNull);
    });

    testWidgets('while saving, neither saves again nor cancels', (
      tester,
    ) async {
      await show(tester, savingEdit: true);

      expect(find.text('Saving your edit…'), findsOneWidget);
      expect(find.byTooltip('Save edit'), findsNothing);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.close_rounded),
            )
            .onPressed,
        isNull,
      );
    });
  });
}
