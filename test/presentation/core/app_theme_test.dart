import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/presentation/core/theme/app_colors.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';

/// The WCAG contrast ratio between two colors, from 1 to 21.
double _contrast(Color a, Color b) {
  final (lighter, darker) = a.computeLuminance() > b.computeLuminance()
      ? (a.computeLuminance(), b.computeLuminance())
      : (b.computeLuminance(), a.computeLuminance());
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  for (final (name, theme, brightness) in [
    ('light', AppTheme.light, Brightness.light),
    ('dark', AppTheme.dark, Brightness.dark),
  ]) {
    group('the $name theme', () {
      final colors = theme.extension<AppColors>()!;

      test('is $name', () {
        expect(theme.brightness, brightness);
        expect(theme.colorScheme.brightness, brightness);
      });

      test('keeps message text readable in both kinds of bubble', () {
        // 4.5:1 is the WCAG AA minimum for body text.
        expect(
          _contrast(colors.sentBubble, colors.onSentBubble),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(colors.receivedBubble, colors.onReceivedBubble),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('tells sent and received messages apart', () {
        expect(colors.sentBubble, isNot(colors.receivedBubble));
      });

      test('has a skeleton shine that shows against the skeleton', () {
        expect(
          colors.skeletonShine.computeLuminance(),
          greaterThan(colors.skeleton.computeLuminance()),
        );
      });

      test('gives the main buttons a touch target of at least 48', () {
        final minimum = theme.filledButtonTheme.style!.minimumSize!.resolve(
          const {},
        )!;
        expect(minimum.height, greaterThanOrEqualTo(48));
      });
    });
  }

  testWidgets('keeps the type scale in app bars and buttons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          appBar: AppBar(title: const Text('Chats')),
          body: FilledButton(onPressed: () {}, child: const Text('Sign in')),
        ),
      ),
    );

    double sizeOf(String text) => tester
        .renderObject<RenderParagraph>(find.text(text))
        .text
        .style!
        .fontSize!;
    expect(sizeOf('Chats'), 22);
    expect(sizeOf('Sign in'), 14);
  });
}
