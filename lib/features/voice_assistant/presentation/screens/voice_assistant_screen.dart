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
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/widgets/text_input_field.dart';

/// Main voice/text assistant screen.
class VoiceAssistantScreen extends ConsumerStatefulWidget {
  /// Creates the voice assistant screen.
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() =>
      _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

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

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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

  void _onMicTap() {
    final hasConsent = ref.read(microphoneConsentProvider);
    if (!hasConsent) {
      context.push('/easy-mode/assistant/consent');
      return;
    }
    final notifier = ref.read(voiceAssistantProvider.notifier);
    final session = ref.read(voiceAssistantProvider);
    if (session?.status == VoiceSessionStatus.listening) {
      notifier.stopListening();
    } else {
      notifier.startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(voiceAssistantProvider);
    final hasConsent = ref.watch(microphoneConsentProvider);
    final theme = Theme.of(context);
    final isListening =
        session?.status == VoiceSessionStatus.listening;
    final isIdle = session == null ||
        session.status == VoiceSessionStatus.idle;
    final hasMessage = session?.assistantMessage != null;

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
                    if (!hasConsent && isIdle)
                      widgets.AssistantMessage(
                        message: l10n.microphoneConsent_denied,
                      ),
                    if (isListening)
                      widgets.AssistantMessage(
                        message: l10n.assistant_listening,
                      ),
                    if (session?.status ==
                        VoiceSessionStatus.processing)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    if (hasMessage)
                      widgets.AssistantMessage(
                        message: session!.assistantMessage!,
                      ),
                    if (isIdle && !hasMessage) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.assistant_greeting,
                        style:
                            theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _QuickChip(
                    icon: Icons.account_balance_wallet,
                    label: l10n.easyMode_home_checkBalance,
                    onTap: () => _onIntentSelected(
                      AssistantIntentType.checkBalance,
                    ),
                  ),
                  _QuickChip(
                    icon: Icons.receipt_long,
                    label: l10n.easyMode_home_payBill,
                    onTap: () => _onIntentSelected(
                      AssistantIntentType.payBill,
                    ),
                  ),
                  _QuickChip(
                    icon: Icons.send,
                    label: l10n.easyMode_home_sendMoney,
                    onTap: () => _onIntentSelected(
                      AssistantIntentType.sendMoney,
                    ),
                  ),
                  _QuickChip(
                    icon: Icons.help,
                    label: l10n.easyMode_home_getHelp,
                    onTap: () => _onIntentSelected(
                      AssistantIntentType.requestHelp,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: l10n.assistant_mic_label,
              button: true,
              child: GestureDetector(
                onTap: _onMicTap,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final scale = isListening
                        ? _pulseAnimation.value
                        : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening
                          ? Colors.red
                          : theme.colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: (isListening
                                  ? Colors.red
                                  : theme.colorScheme.primary)
                              .withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isListening
                          ? Icons.stop
                          : hasConsent
                              ? Icons.mic
                              : Icons.mic_off,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: TextInputField(
                onSubmit: (text) => ref
                    .read(voiceAssistantProvider.notifier)
                    .processInput(text, InputSource.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
