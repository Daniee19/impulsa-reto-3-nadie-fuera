import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/assistant_intent.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/voice_session.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/microphone_consent_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/voice_assistant_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/widgets/assistant_message.dart'
    as widgets;
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/widgets/intent_options.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/widgets/text_input_field.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/widgets/voice_input_button.dart';

/// Main voice/text assistant screen.
class VoiceAssistantScreen extends ConsumerStatefulWidget {
  /// Creates the voice assistant screen.
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() =>
      _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.assistant_title);
      final notifier = ref.read(voiceAssistantProvider.notifier);
      notifier.setNavigate(
        (route, {extra}) => context.push(route, extra: extra),
      );
      notifier.startSession();
    });
  }

  void _onIntentSelected(AssistantIntentType type) {
    final text = switch (type) {
      AssistantIntentType.checkBalance => 'ver saldo',
      AssistantIntentType.payBill => 'pagar recibo',
      AssistantIntentType.sendMoney => 'enviar dinero',
      AssistantIntentType.requestHelp => 'pedir ayuda',
      AssistantIntentType.unknown => '',
    };
    ref
        .read(voiceAssistantProvider.notifier)
        .processInput(text, InputSource.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(voiceAssistantProvider);
    final hasConsent = ref.watch(microphoneConsentProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.assistant_title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!hasConsent)
                      widgets.AssistantMessage(
                        message: l10n.microphoneConsent_denied,
                      ),
                    if (session?.status == VoiceSessionStatus.listening)
                      widgets.AssistantMessage(
                        message: l10n.assistant_listening,
                      ),
                    if (session?.status == VoiceSessionStatus.processing)
                      const Center(child: CircularProgressIndicator()),
                    if (session?.assistantMessage != null)
                      widgets.AssistantMessage(
                        message: session!.assistantMessage!,
                      ),
                    if (_showOptions(session))
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: IntentOptions(onSelect: _onIntentSelected),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextInputField(
                      onSubmit: (text) => ref
                          .read(voiceAssistantProvider.notifier)
                          .processInput(text, InputSource.text),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const VoiceInputButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _showOptions(VoiceSession? session) {
    if (session == null) return false;
    if (session.status != VoiceSessionStatus.idle) return false;
    return session.parsedIntent?.type == AssistantIntentType.unknown;
  }
}
