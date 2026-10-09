import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/data/services/speech_recognition_service.dart';

/// Provider for the speech recognition service.
final speechRecognitionProvider = Provider<SpeechRecognitionService>(
  (ref) => SpeechRecognitionService(),
);
