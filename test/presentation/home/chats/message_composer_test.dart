import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/message_quote.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/message_composer.dart';

void main() {
  late FocusNode focus;
  late List<String> sent;
  late int cancelled;

  setUp(() {
    focus = FocusNode();
    sent = [];
    cancelled = 0;
  });
  tearDown(() => focus.dispose());

  Future<void> show(WidgetTester tester, {MessageQuote? replyingTo}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: MessageComposer(
                focusNode: focus,
                onChanged: (_) {},
                onSend: sent.add,
                replyingTo: replyingTo,
                replyingToName: 'bob',
                onCancelReply: () => cancelled++,
              ),
            ),
          ),
        ),
      );

  IconButton sendButton(WidgetTester tester) => tester.widget<IconButton>(
    find.widgetWithIcon(IconButton, Icons.send_rounded),
  );

  testWidgets('sends the text, trimmed, and clears the field', (tester) async {
    await show(tester);
    expect(sendButton(tester).onPressed, isNull, reason: 'nothing to send');

    await tester.enterText(find.byType(TextField), '  Salut!  ');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();

    expect(sent, ['Salut!']);
    expect(find.text('  Salut!  '), findsNothing);
    expect(sendButton(tester).onPressed, isNull);
  });

  testWidgets('spaces alone are not sent', (tester) async {
    await show(tester);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();

    expect(sendButton(tester).onPressed, isNull);
  });

  testWidgets('stops at the longest message allowed', (tester) async {
    await show(tester);

    await tester.enterText(find.byType(TextField), 'a' * 1200);
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, hasLength(MessageComposer.maxLength));
  });

  testWidgets('shows the message being replied to, and cancels it', (
    tester,
  ) async {
    await show(
      tester,
      replyingTo: MessageQuote(
        messageId: UniqueId.fromUniqueString('message-1'),
        senderId: UniqueId.fromUniqueString('uid-bob'),
        text: 'Ne vedem mâine?',
      ),
    );

    expect(find.text('Replying to bob'), findsOneWidget);
    expect(find.text('Ne vedem mâine?'), findsOneWidget);

    await tester.tap(find.byTooltip('Cancel reply'));

    expect(cancelled, 1);
  });

  testWidgets('shows no reply strip when not replying', (tester) async {
    await show(tester);

    expect(find.textContaining('Replying to'), findsNothing);
  });
}
