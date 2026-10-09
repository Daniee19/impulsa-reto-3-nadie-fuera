import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/microphone_consent_provider.dart';

/// Asks for microphone permission in simple language (Ley 29733).
class MicrophoneConsentScreen extends ConsumerStatefulWidget {
  /// Creates the consent screen.
  const MicrophoneConsentScreen({super.key});

  @override
  ConsumerState<MicrophoneConsentScreen> createState() =>
      _MicrophoneConsentScreenState();
}

class _MicrophoneConsentScreenState
    extends ConsumerState<MicrophoneConsentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(
        View.of(context),
        l10n.microphoneConsent_title,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.microphoneConsent_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.mic, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                l10n.microphoneConsent_body,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AccessibleButton(
                text: l10n.microphoneConsent_accept,
                icon: Icons.check,
                onPressed: () async {
                  await ref.read(microphoneConsentProvider.notifier).grant();
                  if (context.mounted) context.pop();
                },
              ),
              const SizedBox(height: A11yHelpers.minSeparation),
              AccessibleButton(
                text: l10n.microphoneConsent_decline,
                icon: Icons.close,
                onPressed: () async {
                  await ref.read(microphoneConsentProvider.notifier).deny();
                  if (context.mounted) context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
