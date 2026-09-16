import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/presentation/home/chats/widgets/message_request_bar.dart';

void main() {
  testWidgets('says what accepting means, and offers a way out', (
    tester,
  ) async {
    var accepted = 0;
    var deleted = 0;
    var blocked = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageRequestBar(
            name: 'bob',
            onAccept: () => accepted++,
            onDelete: () => deleted++,
            onBlock: () => blocked++,
          ),
        ),
      ),
    );

    expect(
      find.textContaining('bob wants to send you messages'),
      findsOneWidget,
    );
    // The promise the feature makes: nothing reaches them until accepted.
    expect(
      find.textContaining('won\'t know whether you\'ve read them'),
      findsOneWidget,
    );

    await tester.tap(find.text('Accept'));
    await tester.tap(find.text('Delete'));
    await tester.tap(find.text('Block'));
    expect([accepted, deleted, blocked], [1, 1, 1]);
  });
}
