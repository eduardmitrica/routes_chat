import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/swipe_to_reply.dart';

Future<int> _repliesAfterDragging(WidgetTester tester, Offset drag) async {
  var replies = 0;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SwipeToReply(
            onReply: () => replies++,
            child: const SizedBox(width: 300, height: 48, child: Text('Salut')),
          ),
        ),
      ),
    ),
  );

  await tester.drag(find.text('Salut'), drag);
  await tester.pumpAndSettle();
  return replies;
}

void main() {
  testWidgets('swiping a message far enough to the right replies to it', (
    tester,
  ) async {
    expect(await _repliesAfterDragging(tester, const Offset(200, 0)), 1);
  });

  testWidgets('a short swipe springs back without replying', (tester) async {
    expect(await _repliesAfterDragging(tester, const Offset(60, 0)), 0);
  });

  testWidgets('swiping to the left does nothing', (tester) async {
    expect(await _repliesAfterDragging(tester, const Offset(-200, 0)), 0);
  });

  testWidgets('the message returns to its place', (tester) async {
    await _repliesAfterDragging(tester, const Offset(200, 0));

    final moved = tester.widget<Transform>(
      find
          .ancestor(of: find.text('Salut'), matching: find.byType(Transform))
          .first,
    );
    expect(moved.transform.getTranslation().x, 0);
  });
}
