import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// The camera, to read the code the other person is showing. It closes with
/// what it read, or with null when the user gives up or the camera cannot be
/// used.
///
/// Nothing is stored or sent: the code carries a safety number, which the
/// screen that opened this one compares with its own.
class ScanCodePage extends StatefulWidget {
  static const scanCodePageRoute = '/home/chats/safety-number/scan';

  final String name;

  const ScanCodePage({super.key, required this.name});

  static Route<String?> route(String name) => MaterialPageRoute<String?>(
    settings: const RouteSettings(name: scanCodePageRoute),
    builder: (_) => ScanCodePage(name: name),
  );

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  /// The first code closes the screen; later ones are ignored.
  var _done = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _found(BarcodeCapture capture) {
    if (_done) return;
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .where((value) => value != null && value.isNotEmpty)
        .firstOrNull;
    if (code == null) return;
    _done = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Scan ${widget.name}\'s code')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _found,
              errorBuilder: (context, error) => _CameraProblem(error: error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Point the camera at the code on ${widget.name}\'s phone.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The camera is not available, most often because the permission was
/// refused.
class _CameraProblem extends StatelessWidget {
  final MobileScannerException error;

  const _CameraProblem({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final refused = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.no_photography_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              refused
                  ? 'The camera is needed to read the code. You can still '
                        'compare the numbers by reading them out.'
                  : 'The camera could not be started. You can still compare '
                        'the numbers by reading them out.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
