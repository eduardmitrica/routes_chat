import 'dart:typed_data';

/// A voice message recorded on the phone, not sent yet.
final class VoiceRecording {
  /// Where the recording is, in a file the app deletes once it is sent.
  final String path;

  final Duration duration;

  /// The loudness over the recording's length, as [waveformOf] makes it.
  final Uint8List waveform;

  const VoiceRecording({
    required this.path,
    required this.duration,
    required this.waveform,
  });

  @override
  String toString() => 'VoiceRecording(${duration.inMilliseconds} ms)';
}

/// Records voice messages from the microphone.
abstract interface class IVoiceRecorder {
  /// Starts recording, asking for the microphone first if needed. False when
  /// the app may not use it, or it is busy.
  Future<bool> start();

  /// How loud the recording is right now, from 0 to 1, while recording.
  Stream<double> get levels;

  /// Stops and returns the recording; null when nothing was recorded.
  Future<VoiceRecording?> stop();

  /// Stops and throws the recording away.
  Future<void> cancel();

  Future<void> dispose();
}
