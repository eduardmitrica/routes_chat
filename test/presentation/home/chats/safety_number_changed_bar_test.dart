import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/presentation/home/chats/widgets/safety_number_changed_bar.dart';

void main() {
  testWidgets('says whose number changed, and offers to check it', (
    tester,
  ) async {
    var checked = 0;
    var dismissed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafetyNumberChangedBar(
            name: 'bob',
            onCheck: () => checked++,
            onDismiss: () => dismissed++,
          ),
        ),
      ),
    );

    expect(find.text('bob\'s safety number has changed.'), findsOneWidget);

    await tester.tap(find.text('Check'));
    await tester.tap(find.byTooltip('Dismiss'));
    expect([checked, dismissed], [1, 1]);
  });
}
