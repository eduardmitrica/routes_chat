import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/encryption/widgets/recovery_key_confirmation.dart';

const _recoveryKey = 'AAAA-BBBB-CCCC-DDDD-EEEE-FFFF-GGGG-HHHH';
const _mismatch =
    'That doesn\'t match group 3. Check the key above and try again.';

void main() {
  late List<String> confirmed;

  setUp(() => confirmed = []);

  Future<void> show(WidgetTester tester, {int rejections = 0}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: RecoveryKeyConfirmation(
              recoveryKey: _recoveryKey,
              groupNumber: 3,
              rejections: rejections,
              onConfirmed: confirmed.add,
            ),
          ),
        ),
      );

  testWidgets('says nothing before a group is typed back', (tester) async {
    await show(tester);

    expect(find.text(_mismatch), findsNothing);
  });

  testWidgets(
    'a group that doesn\'t match is said under the field, every time',
    (tester) async {
      await show(tester);
      await tester.enterText(find.byType(TextField), 'ZZZZ');
      await tester.tap(find.text('I saved it'));
      expect(confirmed, ['ZZZZ']);

      await show(tester, rejections: 1);
      await tester.pump();
      expect(find.text(_mismatch), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'ZZZY');
      await tester.pump();
      expect(find.text(_mismatch), findsNothing);

      await tester.tap(find.text('I saved it'));
      await show(tester, rejections: 2);
      await tester.pump();
      expect(find.text(_mismatch), findsOneWidget);
    },
  );
}
