import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/providers/practice_guide_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/providers/practice_session_provider.dart';

/// Bottom overlay showing the current guide step instruction.
class PracticeGuideOverlay extends ConsumerWidget {
  /// Creates the guide overlay.
  const PracticeGuideOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(practiceSessionProvider);
    final step = ref.watch(practiceGuideProvider);

    if (!session.guideEnabled || step == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final instruction = _resolveInstruction(step.instruction, l10n);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      A11yHelpers.screenAnnounce(View.of(context), instruction);
    });

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Card(
          margin: const EdgeInsets.all(12),
          color: const Color(0xFFC8E6C9),
          child: Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.practice_guide_step(
                  step.stepNumber,
                  step.totalSteps,
                  instruction,
                ),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _resolveInstruction(String key, AppLocalizations l10n) {
    switch (key) {
      case 'practice_guide_balance':
        return l10n.practice_guide_balance;
      case 'practice_guide_payBill':
        return l10n.practice_guide_payBill;
      case 'practice_guide_selectBill':
        return l10n.practice_guide_selectBill;
      case 'practice_guide_confirmPay':
        return l10n.practice_guide_confirmPay;
      case 'practice_guide_sendMoney':
        return l10n.practice_guide_sendMoney;
      case 'practice_guide_selectContact':
        return l10n.practice_guide_selectContact;
      case 'practice_guide_enterAmount':
        return l10n.practice_guide_enterAmount;
      case 'practice_guide_confirmSend':
        return l10n.practice_guide_confirmSend;
      case 'practice_guide_done':
        return l10n.practice_guide_done;
      case 'practice_guide_fraudAlert':
        return l10n.practice_guide_fraudAlert;
      default:
        return key;
    }
  }
}
