import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/voice_session.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/microphone_consent_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/voice_assistant_provider.dart';

/// Mic button that toggles speech recognition.
class VoiceInputButton extends ConsumerWidget {
  /// Creates the voice input button.
  const VoiceInputButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final hasConsent = ref.watch(microphoneConsentProvider);
    final session = ref.watch(voiceAssistantProvider);
    final isListening = session?.status == VoiceSessionStatus.listening;

    return SizedBox(
      height: A11yHelpers.minTapTarget,
      width: A11yHelpers.minTapTarget,
      child: Semantics(
        label: l10n.assistant_mic_label,
        button: true,
        child: FloatingActionButton(
          heroTag: 'voice_input',
          onPressed: () {
            if (!hasConsent) {
              context.push('/easy-mode/assistant/consent');
              return;
            }
            final notifier = ref.read(voiceAssistantProvider.notifier);
            if (isListening) {
              notifier.stopListening();
            } else {
              notifier.startListening();
            }
          },
          child: Icon(
            isListening
                ? Icons.stop
                : hasConsent
                ? Icons.mic
                : Icons.mic_off,
          ),
        ),
      ),
    );
  }
}
