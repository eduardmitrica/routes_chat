import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';
import 'package:routes_chat/infrastructure/chats/messages/voice_recorder.dart';

/// A microphone whose permission answer the test gives when it likes.
class _Microphone implements AudioRecorder {
  final permission = Completer<bool>();
  final calls = <String>[];
  final _amplitudes = StreamController<Amplitude>.broadcast();

  @override
  Future<bool> hasPermission({bool request = true}) => permission.future;

  @override
  Future<void> start(RecordConfig config, {required String path}) async =>
      calls.add('start');

  @override
  Stream<Amplitude> onAmplitudeChanged(Duration interval) => _amplitudes.stream;

  @override
  Future<String?> stop() async {
    calls.add('stop');
    return null;
  }

  @override
  Future<void> cancel() async => calls.add('cancel');

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    await _amplitudes.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Microphone microphone;
  late VoiceRecorder recorder;

  setUp(() {
    microphone = _Microphone();
    recorder = VoiceRecorder(
      recorder: microphone,
      directory: () async => Directory.systemTemp,
    );
  });

  test(
    'let go while the permission is asked: the microphone is not left on',
    () async {
      final starting = recorder.start();

      // The user lets go, then allows the microphone.
      expect(await recorder.stop(), isNull);
      microphone.permission.complete(true);

      expect(await starting, isFalse);
      expect(microphone.calls, ['start', 'cancel']);
    },
  );

  test('cancelled while starting: the same', () async {
    final starting = recorder.start();

    await recorder.cancel();
    microphone.permission.complete(true);

    expect(await starting, isFalse);
    expect(microphone.calls, ['start', 'cancel']);
  });

  test('without the microphone, nothing starts', () async {
    microphone.permission.complete(false);

    expect(await recorder.start(), isFalse);
    expect(microphone.calls, isEmpty);
  });

  test('a recording that started is stopped with its waveform', () async {
    microphone.permission.complete(true);
    expect(await recorder.start(), isTrue);
    microphone._amplitudes.add(Amplitude(current: -20, max: -10));
    await pumpEventQueue();

    final recording = await recorder.stop();

    expect(recording, isNotNull);
    expect(recording!.waveform, isNotEmpty);
    expect(microphone.calls, ['start', 'stop']);
  });
}
