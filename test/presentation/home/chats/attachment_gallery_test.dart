import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routes_chat/domain/chats/messages/media_failure.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/core/value_objects.dart';
import 'package:routes_chat/presentation/core/theme/app_theme.dart';
import 'package:routes_chat/presentation/home/chats/widgets/attachment_gallery.dart';
import 'package:routes_chat/presentation/home/chats/widgets/encrypted_image.dart';

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

Future<Either<MediaFailure, Uint8List>> _loads(MessageAttachment _) async =>
    Right(_png);

Widget _chat(Widget gallery) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: Center(child: gallery)),
);

void main() {
  testWidgets('one photo is shown on its own', (tester) async {
    await tester.pumpWidget(
      _chat(
        AttachmentGallery(attachments: [_photo(1)], loader: _loads, width: 300),
      ),
    );
    await tester.pump();

    expect(find.byType(EncryptedImage), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(find.textContaining('/'), findsNothing);
  });

  testWidgets('several photos are a carousel with a counter', (tester) async {
    await tester.pumpWidget(
      _chat(
        AttachmentGallery(
          attachments: [_photo(1), _photo(2), _photo(3)],
          loader: _loads,
          width: 300,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1/3'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-250, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('tapping a photo opens it full screen', (tester) async {
    await tester.pumpWidget(
      _chat(
        AttachmentGallery(
          attachments: [_photo(1), _photo(2)],
          loader: _loads,
          width: 300,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();
    expect(find.text('1 of 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 2'), findsNothing);
  });

  testWidgets('a photo that could not be loaded can be tried again', (
    tester,
  ) async {
    var loads = 0;
    Future<Either<MediaFailure, Uint8List>> failsOnce(
      MessageAttachment _,
    ) async => ++loads == 1 ? const Left(MediaUnavailable()) : Right(_png);
    await tester.pumpWidget(
      _chat(
        AttachmentGallery(
          attachments: [_photo(1)],
          loader: failsOnce,
          width: 300,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Tap to retry'), findsOneWidget);

    await tester.tap(find.text('Tap to retry'));
    await tester.pump();
    await tester.pump();

    expect(loads, 2);
    expect(find.text('Tap to retry'), findsNothing);
  });

  testWidgets('a GIF and a photo say what they are to screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _chat(
        SizedBox(
          width: 100,
          height: 100,
          child: EncryptedImage(
            attachment: MessageAttachment(
              id: UniqueId.fromUniqueString('gif-1'),
              kind: AttachmentKind.gif,
              width: 1,
              height: 1,
              byteSize: 1,
              key: Uint8List(32),
            ),
            loader: _loads,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('GIF'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a gallery given another message starts at its first photo', (
    tester,
  ) async {
    // A chat list hands a row's state to the next message: on a phone, a new
    // message's photos opened on the page the previous message was left on.
    Future<void> showPhotos(List<MessageAttachment> photos) =>
        tester.pumpWidget(
          _chat(
            AttachmentGallery(attachments: photos, loader: _loads, width: 300),
          ),
        );
    await showPhotos([_photo(1), _photo(2), _photo(3)]);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-250, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('2/3'), findsOneWidget);

    await showPhotos([_photo(4), _photo(5)]);
    await tester.pumpAndSettle();

    expect(find.text('1/2'), findsOneWidget);
  });
}
