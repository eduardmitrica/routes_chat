import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/open_link_dialog.dart';

void main() {
  /// Shows the dialog for [link] and returns what it answered, once [answer]
  /// has been done to it.
  Future<bool?> ask(
    WidgetTester tester,
    Uri link, {
    Future<void> Function()? answer,
  }) async {
    bool? answered;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async =>
                    answered = await confirmOpenLink(context, link),
                child: const Text('link'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('link'));
    await tester.pumpAndSettle();
    if (answer != null) {
      await answer();
      await tester.pumpAndSettle();
    }
    return answered;
  }

  testWidgets('shows the site and the whole address before opening', (
    tester,
  ) async {
    await ask(tester, Uri.parse('https://example.ro/meniu?zi=luni'));

    expect(find.text('Open this link?'), findsOneWidget);
    expect(find.text('example.ro'), findsOneWidget);
    expect(find.text('https://example.ro/meniu?zi=luni'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });

  testWidgets('opens only when the user chooses Open', (tester) async {
    expect(
      await ask(
        tester,
        Uri.parse('https://example.ro'),
        answer: () => tester.tap(find.text('Open')),
      ),
      isTrue,
    );
  });

  testWidgets('Cancel does not open it', (tester) async {
    expect(
      await ask(
        tester,
        Uri.parse('https://example.ro'),
        answer: () => tester.tap(find.text('Cancel')),
      ),
      isFalse,
    );
  });

  testWidgets('closing the dialog any other way does not open it', (
    tester,
  ) async {
    expect(
      await ask(
        tester,
        Uri.parse('https://example.ro'),
        answer: () => tester.tapAt(const Offset(5, 5)),
      ),
      isFalse,
    );
  });

  testWidgets('warns about a link that is not secure', (tester) async {
    await ask(tester, Uri.parse('http://example.ro'));

    expect(find.textContaining('not secure'), findsOneWidget);
  });

  testWidgets('warns about a site name in look-alike letters', (tester) async {
    // A Cyrillic "а" in place of the Latin one.
    await ask(tester, Uri.parse('https://аpple.com/login'));

    expect(find.textContaining('other alphabets'), findsOneWidget);
    expect(find.text('аpple.com'), findsOneWidget, reason: 'as it reads');
  });

  testWidgets('warns about a site name spelled in punycode', (tester) async {
    await ask(tester, Uri.parse('https://xn--pple-43d.com/login'));

    expect(find.textContaining('other alphabets'), findsOneWidget);
  });

  testWidgets('an email address asks to write an email', (tester) async {
    await ask(tester, Uri(scheme: 'mailto', path: 'ana.pop@example.ro'));

    expect(find.text('Write an email?'), findsOneWidget);
    expect(find.text('ana.pop@example.ro'), findsOneWidget);
    expect(find.text('Write'), findsOneWidget);
  });
}
