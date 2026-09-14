import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/messages_skeleton.dart';

Widget _chat(Widget body, {bool animationsOff = false}) => MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: animationsOff),
      child: Scaffold(body: body),
    ),
  ),
);

void main() {
  testWidgets('shimmers while the messages load', (tester) async {
    await tester.pumpWidget(_chat(const MessagesSkeleton()));

    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('keeps still for someone who turned animations off', (
    tester,
  ) async {
    await tester.pumpWidget(
      _chat(const MessagesSkeleton(), animationsOff: true),
    );

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('tells screen readers that messages are loading', (tester) async {
    // Disposed in the test body: the check for open handles runs before
    // tear-downs.
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(_chat(const MessagesSkeleton.older()));

    expect(find.bySemanticsLabel('Loading messages'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('fits a phone screen in the dark theme too', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(_chat(const MessagesSkeleton()));

    expect(tester.takeException(), isNull);
  });
}
