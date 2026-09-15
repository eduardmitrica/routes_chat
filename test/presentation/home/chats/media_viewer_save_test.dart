import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart' show Either, Right, Unit, left, right, unit;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/media_viewer_page.dart';

/// A 1×1 PNG.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

MessageAttachment _photo(int index) => MessageAttachment(
  id: UniqueId.fromUniqueString('photo-$index'),
  kind: AttachmentKind.photo,
  width: 400,
  height: 400,
  byteSize: _png.length,
  key: Uint8List(32),
);

void main() {
  late List<String> saved;
  late Either<MediaFailure, Unit> answer;

  setUp(() {
    saved = [];
    answer = right(unit);
  });

  Future<void> show(WidgetTester tester, {bool canSave = true}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaViewerPage(
          attachments: [_photo(0), _photo(1)],
          initialIndex: 1,
          loader: (_) async => Right(_png),
          onSave: canSave
              ? (attachment) async {
                  saved.add(attachment.id.getOrCrash());
                  return answer;
                }
              : null,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the photo shown is saved, and the user told', (tester) async {
    await show(tester);

    await tester.tap(find.byTooltip('Save to your photos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(saved, ['photo-1']);
    expect(find.text('Photo saved to your photos'), findsOneWidget);
  });

  testWidgets('a photo that could not be saved says why', (tester) async {
    answer = left(const PhotoAccessDenied());
    await show(tester);

    await tester.tap(find.byTooltip('Save to your photos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.textContaining('isn\'t allowed to add to your photos'),
      findsOneWidget,
    );
  });

  testWidgets('without a way to save there is no button', (tester) async {
    await show(tester, canSave: false);

    expect(find.byTooltip('Save to your photos'), findsNothing);
  });
}
