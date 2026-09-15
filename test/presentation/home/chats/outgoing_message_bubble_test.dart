import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart' show Right;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/outgoing_message.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/outgoing_message_bubble.dart';

import '../../../helpers/outbox_fakes.dart';

/// A 1×1 PNG.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  late int optionsShown;
  late List<String> loaded;

  setUp(() {
    optionsShown = 0;
    loaded = [];
  });

  Future<void> show(WidgetTester tester, OutgoingMessage entry) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            children: [
              OutgoingMessageBubble(
                entry: entry,
                quoteAuthor: null,
                loadAttachment: (attachment) async {
                  loaded.add(attachment.id.getOrCrash());
                  return Right<MediaFailure, Uint8List>(_png);
                },
                onOptions: () => optionsShown++,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a message being sent says so', (tester) async {
    await show(tester, outgoingMessage('m1', text: 'Salut'));

    expect(find.text('Salut', findRichText: true), findsOneWidget);
    expect(find.text('Sending…'), findsOneWidget);
    await tester.tap(find.text('Sending…'));
    expect(optionsShown, 0);
  });

  testWidgets('a message not sent yet says it will try again', (tester) async {
    await show(
      tester,
      outgoingMessage(
        'm1',
      ).copyWith(status: OutgoingStatus.waiting, failures: 1),
    );

    await tester.tap(find.text('Not sent yet. Trying again…'));

    expect(optionsShown, 1);
  });

  testWidgets('a message refused says it was not sent', (tester) async {
    await show(
      tester,
      outgoingMessage(
        'm1',
      ).copyWith(status: OutgoingStatus.failed, failures: 1),
    );

    await tester.tap(find.text('Not sent. Tap for options'));

    expect(optionsShown, 1);
  });

  testWidgets('its photos show from the phone before they upload', (
    tester,
  ) async {
    await show(tester, outgoingMessage('m1', media: [photoDraft('a')]));
    await tester.pump();

    expect(loaded, ['a']);
  });
}
