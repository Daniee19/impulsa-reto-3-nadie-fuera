import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/data/services/text_to_speech_service.dart';

/// Provider for the text-to-speech service.
final ttsProvider = Provider<TextToSpeechService>(
  (ref) => TextToSpeechService(),
);
