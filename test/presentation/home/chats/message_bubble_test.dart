import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/message_bubble.dart';

Message _message(String text, {MessageQuote? replyTo}) => Message(
  id: UniqueId.fromUniqueString('message-2'),
  senderId: UniqueId.fromUniqueString('uid-alice'),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content(text),
  replyTo: replyTo,
  lastUpdatedAt: null,
  isEdited: false,
);

final _quote = MessageQuote(
  messageId: UniqueId.fromUniqueString('message-1'),
  senderId: UniqueId.fromUniqueString('uid-bob'),
  text: 'Ne vedem mâine?',
);

Widget _chat(Widget bubble) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: Center(child: bubble)),
);

void main() {
  testWidgets('a reply shows who and what it answers', (tester) async {
    await tester.pumpWidget(
      _chat(
        MessageBubble(
          message: _message('Da, la 10', replyTo: _quote),
          sent: true,
          quoteAuthor: 'bob',
        ),
      ),
    );

    expect(find.text('bob'), findsOneWidget);
    expect(find.text('Ne vedem mâine?'), findsOneWidget);
    expect(find.text('Da, la 10'), findsOneWidget);
  });

  testWidgets('tapping the quote asks to show the original', (tester) async {
    var shown = 0;
    await tester.pumpWidget(
      _chat(
        MessageBubble(
          message: _message('Da, la 10', replyTo: _quote),
          sent: false,
          quoteAuthor: 'You',
          onQuoteTap: () => shown++,
        ),
      ),
    );

    await tester.tap(find.text('Ne vedem mâine?'));

    expect(shown, 1);
  });

  testWidgets('a message that is not a reply has no quote', (tester) async {
    await tester.pumpWidget(
      _chat(MessageBubble(message: _message('Salut'), sent: true)),
    );

    expect(find.text('Salut'), findsOneWidget);
    expect(find.byType(InkWell), findsOneWidget, reason: 'only the bubble');
  });

  testWidgets('a long press asks for the message actions', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      _chat(
        MessageBubble(
          message: _message('Salut'),
          sent: true,
          onLongPress: () => pressed++,
        ),
      ),
    );

    await tester.longPress(find.text('Salut'));

    expect(pressed, 1);
  });
}
