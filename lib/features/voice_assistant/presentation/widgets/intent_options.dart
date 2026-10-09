import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/assistant_intent.dart';

/// Shows the 4 available assistant options as accessible buttons.
class IntentOptions extends StatelessWidget {
  /// Creates intent options.
  const IntentOptions({required this.onSelect, super.key});

  /// Called when the user taps an option.
  final void Function(AssistantIntentType) onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccessibleButton(
          text: l10n.easyMode_home_checkBalance,
          icon: Icons.account_balance_wallet,
          onPressed: () => onSelect(AssistantIntentType.checkBalance),
        ),
        const SizedBox(height: A11yHelpers.minSeparation),
        AccessibleButton(
          text: l10n.easyMode_home_payBill,
          icon: Icons.receipt_long,
          onPressed: () => onSelect(AssistantIntentType.payBill),
        ),
        const SizedBox(height: A11yHelpers.minSeparation),
        AccessibleButton(
          text: l10n.easyMode_home_sendMoney,
          icon: Icons.send,
          onPressed: () => onSelect(AssistantIntentType.sendMoney),
        ),
        const SizedBox(height: A11yHelpers.minSeparation),
        AccessibleButton(
          text: l10n.easyMode_home_getHelp,
          icon: Icons.help,
          onPressed: () => onSelect(AssistantIntentType.requestHelp),
        ),
      ],
    );
  }
}
