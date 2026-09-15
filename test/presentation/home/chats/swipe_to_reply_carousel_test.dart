import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/swipe_to_reply.dart';

void main() {
  // Regression: a message with several photos could not be swiped to reply,
  // because the carousel took every horizontal drag.
  late int replies;
  late PageController pages;

  setUp(() {
    replies = 0;
    pages = PageController();
  });
  tearDown(() => pages.dispose());

  Future<void> show(
    WidgetTester tester, {
    TextDirection direction = TextDirection.ltr,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(
            child: SwipeToReply(
              onReply: () => replies++,
              child: SizedBox(
                width: 300,
                height: 200,
                child: PageView(
                  controller: pages,
                  children: [
                    for (var photo = 1; photo <= 3; photo++)
                      Center(child: Text('Photo $photo')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('on the first photo, swiping towards the end replies', (
    tester,
  ) async {
    await show(tester);

    await tester.timedDrag(
      find.text('Photo 1'),
      const Offset(160, 0),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    expect(replies, 1);
    expect(pages.page, 0);
  });

  testWidgets('swiping the other way still turns the photos', (tester) async {
    await show(tester);

    await tester.timedDrag(
      find.text('Photo 1'),
      const Offset(-200, 0),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    expect(replies, 0);
    expect(pages.page, 1);
  });

  testWidgets('a short swipe on the first photo springs back, no reply', (
    tester,
  ) async {
    await show(tester);

    await tester.timedDrag(
      find.text('Photo 1'),
      const Offset(40, 0),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    expect(replies, 0);
  });

  testWidgets('right to left, towards the end is to the left', (tester) async {
    await show(tester, direction: TextDirection.rtl);

    await tester.timedDrag(
      find.text('Photo 1'),
      const Offset(-160, 0),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    expect(replies, 1);
  });
}
