import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/message_composer.dart';

/// A 1×1 PNG.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

MediaDraft _draft(String id, {AttachmentKind kind = AttachmentKind.photo}) =>
    MediaDraft(
      id: UniqueId.fromUniqueString(id),
      kind: kind,
      bytes: _png,
      width: 1,
      height: 1,
    );

void main() {
  late FocusNode focus;
  late List<String> sent;
  late List<UniqueId> removed;
  late int addRequests;

  setUp(() {
    focus = FocusNode();
    sent = [];
    removed = [];
    addRequests = 0;
  });
  tearDown(() => focus.dispose());

  Future<void> show(
    WidgetTester tester, {
    List<MediaDraft> media = const [],
    String text = '',
    int textRevision = 0,
    bool preparing = false,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MessageComposer(
            focusNode: focus,
            onChanged: (_) {},
            onSend: sent.add,
            replyingTo: null,
            replyingToName: '',
            onCancelReply: () {},
            media: media,
            text: text,
            textRevision: textRevision,
            preparingMedia: preparing,
            onAddMedia: () => addRequests++,
            onRemoveMedia: removed.add,
          ),
        ),
      ),
    ),
  );

  IconButton sendButton(WidgetTester tester) => tester.widget<IconButton>(
    find.widgetWithIcon(IconButton, Icons.send_rounded),
  );

  testWidgets('the photo button asks for photos', (tester) async {
    await show(tester);

    await tester.tap(find.byTooltip('Add photos or GIFs'));

    expect(addRequests, 1);
  });

  testWidgets('chosen photos can be sent without a caption', (tester) async {
    await show(tester, media: [_draft('a'), _draft('b')]);
    expect(find.text('Add a caption...'), findsOneWidget);

    await tester.tap(find.byTooltip('Send'));

    expect(sent, ['']);
  });

  testWidgets('a chosen photo can be taken out', (tester) async {
    await show(tester, media: [_draft('a'), _draft('b')]);

    await tester.tap(find.byTooltip('Remove photo').first);

    expect(removed, [UniqueId.fromUniqueString('a')]);
  });

  testWidgets('a chosen GIF is marked as one', (tester) async {
    await show(tester, media: [_draft('a', kind: AttachmentKind.gif)]);

    expect(find.text('GIF'), findsOneWidget);
  });

  testWidgets('a draft brought back replaces what the field had', (
    tester,
  ) async {
    await show(tester);
    await tester.enterText(find.byType(TextField), 'typed');

    await show(tester, text: 'Ne vedem mâine', textRevision: 1);

    expect(find.text('Ne vedem mâine'), findsOneWidget);
    expect(sendButton(tester).onPressed, isNotNull);
  });

  testWidgets('what the user types is not replaced by the same draft', (
    tester,
  ) async {
    await show(tester, text: 'Ne vedem', textRevision: 1);
    await tester.enterText(find.byType(TextField), 'Ne vedem mâine');

    await show(tester, text: 'Ne vedem', textRevision: 1);

    expect(find.text('Ne vedem mâine'), findsOneWidget);
  });

  testWidgets('another message can be written while one is on its way', (
    tester,
  ) async {
    await show(tester, media: [_draft('a')]);

    expect(sendButton(tester).onPressed, isNotNull);
    expect(find.byTooltip('Remove photo'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('photos still being made ready cannot be sent yet', (
    tester,
  ) async {
    await show(tester, media: [_draft('a')], preparing: true);

    expect(sendButton(tester).onPressed, isNull);
  });
}
