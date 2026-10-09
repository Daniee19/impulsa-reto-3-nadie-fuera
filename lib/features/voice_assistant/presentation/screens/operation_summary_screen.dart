import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/voice_assistant_provider.dart';

/// Shows the operation summary and biometric confirm button.
class OperationSummaryScreen extends ConsumerStatefulWidget {
  /// Creates the operation summary screen.
  const OperationSummaryScreen({super.key});

  @override
  ConsumerState<OperationSummaryScreen> createState() =>
      _OperationSummaryScreenState();
}

class _OperationSummaryScreenState
    extends ConsumerState<OperationSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final summary = ref.read(voiceAssistantProvider)?.operationSummary;
      if (summary != null) {
        A11yHelpers.screenAnnounce(View.of(context), summary.spokenSummary);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final session = ref.watch(voiceAssistantProvider);
    final summary = session?.operationSummary;

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.assistant_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        summary.recipientName,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: summary.spokenSummary,
                        excludeSemantics: true,
                        child: Text(
                          'S/ ${summary.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.displayMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AccessibleButton(
                text: l10n.assistant_confirmButton,
                icon: Icons.fingerprint,
                onPressed: () async {
                  await ref
                      .read(voiceAssistantProvider.notifier)
                      .confirmWithBiometric(l10n.assistant_biometricReason);
                  if (context.mounted) context.go('/easy-mode');
                },
              ),
              const SizedBox(height: A11yHelpers.minSeparation),
              AccessibleButton(
                text: l10n.assistant_cancelButton,
                icon: Icons.close,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
