import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kt_dart/collection.dart';
import 'package:routes_chat/domain/chats/messages/message.dart';
import 'package:routes_chat/domain/chats/messages/value_objects.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/message_bubble.dart';

Message _message(String text) => Message(
  id: UniqueId.fromUniqueString('message-1'),
  senderId: UniqueId.fromUniqueString('uid-bob'),
  imageUrls: const KtList.empty(),
  reactions: const KtList.empty(),
  content: Content(text),
  lastUpdatedAt: null,
  isEdited: false,
);

void main() {
  late List<Uri> opened;
  late int longPresses;

  setUp(() {
    opened = [];
    longPresses = 0;
  });

  Future<void> show(WidgetTester tester, String text) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: MessageBubble(
            message: _message(text),
            sent: false,
            onOpenLink: opened.add,
            onLongPress: () => longPresses++,
          ),
        ),
      ),
    ),
  );

  /// The spans the bubble's text is drawn with.
  List<TextSpan> spans(WidgetTester tester) {
    final paragraph = tester.renderObject<RenderParagraph>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText().contains('example'),
      ),
    );
    final spans = <TextSpan>[];
    paragraph.text.visitChildren((span) {
      if (span is TextSpan && span.text != null) spans.add(span);
      return true;
    });
    return spans;
  }

  testWidgets('a link is underlined and tappable, the rest is not', (
    tester,
  ) async {
    await show(tester, 'Uite https://example.ro aici');

    final [before, link, after] = spans(tester);
    expect(link.text, 'https://example.ro');
    expect(link.style?.decoration, TextDecoration.underline);
    expect(link.recognizer, isNotNull);
    expect(before.recognizer, isNull);
    expect(after.recognizer, isNull);
  });

  testWidgets('tapping a link opens it', (tester) async {
    await show(tester, 'https://example.ro/pagina');

    await tester.tap(
      find.text('https://example.ro/pagina', findRichText: true),
    );

    expect(opened, [Uri.parse('https://example.ro/pagina')]);
  });

  testWidgets('a long press on a link still shows the message actions', (
    tester,
  ) async {
    await show(tester, 'https://example.ro/pagina');

    await tester.longPress(
      find.text('https://example.ro/pagina', findRichText: true),
    );

    expect(longPresses, 1);
    expect(opened, isEmpty);
  });

  testWidgets('text without links has nothing to tap', (tester) async {
    await show(tester, 'Salut, example fără link');

    expect(spans(tester).every((span) => span.recognizer == null), isTrue);
  });
}
