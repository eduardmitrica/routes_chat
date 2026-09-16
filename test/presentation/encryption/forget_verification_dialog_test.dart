import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/presentation/encryption/widgets/forget_verification_dialog.dart';

void main() {
  Future<bool?> ask(WidgetTester tester) async {
    bool? answer;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async =>
                  answer = await confirmForgetVerification(context, 'bob'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return answer;
  }

  testWidgets('says what forgetting a check does, and what it does not', (
    tester,
  ) async {
    await ask(tester);

    expect(find.text('Forget the check on bob?'), findsOneWidget);
    expect(find.textContaining('bob isn\'t told'), findsOneWidget);
    expect(
      find.textContaining('compare the new number whenever you want'),
      findsOneWidget,
    );
  });

  testWidgets('forgets only when the user says so', (tester) async {
    await ask(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Forget the check on bob?'), findsNothing);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forget'));
    await tester.pumpAndSettle();
    expect(find.text('Forget the check on bob?'), findsNothing);
  });
}
