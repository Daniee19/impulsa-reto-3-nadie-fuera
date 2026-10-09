import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/presentation/providers/contract_review_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/tts_provider.dart';

/// Shows the full contract text with per-paragraph TTS.
class FullContractScreen extends ConsumerWidget {
  /// Creates a full contract screen.
  const FullContractScreen({required this.contractId, super.key});

  /// The contract to display.
  final String contractId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(contractRepositoryProvider);
    final contract = repo.getContractSummary(contractId);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(contract.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            for (final paragraph in contract.fullContractParagraphs) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Semantics(
                      label: paragraph,
                      child: Text(
                        paragraph,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: A11yHelpers.minTapTarget,
                    height: A11yHelpers.minTapTarget,
                    child: IconButton(
                      icon: const Icon(Icons.volume_up),
                      tooltip: l10n.contract_readThis,
                      onPressed: () => ref.read(ttsProvider).speak(paragraph),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
            AccessibleButton(
              text: l10n.contract_backToSummary,
              icon: Icons.arrow_back,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
