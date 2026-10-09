import 'package:flutter_tts/flutter_tts.dart';

/// Wraps [FlutterTts] optimized for older adults (rate 0.45).
class TextToSpeechService {
  final _tts = FlutterTts();

  /// Configures TTS for Spanish at a slow, clear pace.
  Future<void> initialize() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1);
    await _tts.setPitch(1);
  }

  /// Speaks the given text.
  Future<void> speak(String text) => _tts.speak(text);

  /// Stops any ongoing speech.
  Future<void> stop() => _tts.stop();

  /// Sets speech rate (absolute value, not a multiplier).
  Future<void> setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  /// Registers a handler called when speech finishes.
  void setCompletionHandler(void Function() handler) {
    _tts.setCompletionHandler(handler);
  }
}
