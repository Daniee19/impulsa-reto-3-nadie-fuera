import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps [SpeechToText] for voice recognition.
class SpeechRecognitionService {
  final _speech = SpeechToText();

  /// Initializes the speech recognition engine.
  Future<bool> initialize() => _speech.initialize();

  /// Starts listening for speech in Peruvian Spanish.
  Future<void> listen({required void Function(String) onResult}) async {
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult) onResult(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(localeId: 'es_PE'),
    );
  }

  /// Stops listening.
  Future<void> stop() => _speech.stop();

  /// Whether the engine is currently listening.
  bool get isListening => _speech.isListening;
}
