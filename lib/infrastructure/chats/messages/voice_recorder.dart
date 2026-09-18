import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:routes_chat/domain/chats/messages/message_attachment.dart';
import 'package:routes_chat/domain/chats/messages/voice_recorder_interface.dart';
import 'package:routes_chat/domain/core/value_objects.dart';

/// Records AAC in the app's own cache with the `record` plugin, sampling how
/// loud it is as it goes for the waveform.
class VoiceRecorder implements IVoiceRecorder {
  /// How often loudness is sampled.
  static const sampleEvery = Duration(milliseconds: 100);

  /// The quietest a sample counts as, in decibels below full scale.
  static const silence = -50.0;

  final AudioRecorder _recorder;
  final _levels = StreamController<double>.broadcast();
  StreamSubscription<Amplitude>? _amplitudes;
  final _decibels = <double>[];
  final _clock = Stopwatch();
  String? _path;

  /// Whether a recording is starting, which can take as long as the user
  /// takes to answer the microphone permission.
  var _starting = false;

  /// Whether it was stopped or cancelled while starting: once it has
  /// started, it is thrown away at once, so the microphone is never left on.
  var _endedWhileStarting = false;

  final Future<Directory> Function() _directory;

  VoiceRecorder({
    AudioRecorder? recorder,
    Future<Directory> Function()? directory,
  }) : _recorder = recorder ?? AudioRecorder(),
       _directory = directory ?? getTemporaryDirectory;

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<bool> start() async {
    if (_path != null || _starting) return false;
    _starting = true;
    _endedWhileStarting = false;
    try {
      if (!await _recorder.hasPermission()) return false;
      final directory = await _directory();
      final path =
          '${directory.path}/recording_${UniqueId.random().getOrCrash()}.m4a';
      await _recorder.start(
        const RecordConfig(
          bitRate: MediaLimits.voiceBitRate,
          sampleRate: MediaLimits.voiceSampleRate,
          numChannels: 1,
          noiseSuppress: true,
          echoCancel: true,
        ),
        path: path,
      );
      _path = path;
      if (_endedWhileStarting) {
        await _discard();
        return false;
      }
      _decibels.clear();
      _clock
        ..reset()
        ..start();
      _amplitudes = _recorder.onAmplitudeChanged(sampleEvery).listen((
        amplitude,
      ) {
        final decibels = amplitude.current;
        _decibels.add(decibels);
        final level = ((decibels - silence) / -silence).clamp(0.0, 1.0);
        if (!_levels.isClosed) _levels.add(level.isFinite ? level : 0);
      });
      return true;
    } on Exception catch (exception) {
      debugPrint('Recording not started: ${exception.runtimeType}');
      await _discard();
      return false;
    } finally {
      _starting = false;
    }
  }

  @override
  Future<VoiceRecording?> stop() async {
    if (_starting) {
      _endedWhileStarting = true;
      return null;
    }
    final path = _path;
    if (path == null) return null;
    _path = null;
    _clock.stop();
    await _amplitudes?.cancel();
    _amplitudes = null;
    try {
      final stoppedAt = await _recorder.stop();
      return VoiceRecording(
        path: stoppedAt ?? path,
        duration: _clock.elapsed,
        waveform: waveformOf(_decibels, floor: silence),
      );
    } on Exception catch (exception) {
      debugPrint('Recording not stopped: ${exception.runtimeType}');
      return null;
    }
  }

  @override
  Future<void> cancel() async {
    if (_starting) {
      _endedWhileStarting = true;
      return;
    }
    await _discard();
  }

  /// Stops the microphone and deletes what was recorded, if anything.
  Future<void> _discard() async {
    final path = _path;
    _path = null;
    _clock.stop();
    await _amplitudes?.cancel();
    _amplitudes = null;
    try {
      await _recorder.cancel();
    } on Exception catch (exception) {
      debugPrint('Recording not cancelled: ${exception.runtimeType}');
    }
    if (path != null) {
      try {
        await File(path).delete();
      } on FileSystemException {
        // The plugin removed it already.
      }
    }
  }

  @override
  Future<void> dispose() async {
    _endedWhileStarting = true;
    await _discard();
    await _levels.close();
    await _recorder.dispose();
  }
}
