import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';

/// Displays a warm, protective risk message for the triggered rules.
class RiskMessageCard extends StatelessWidget {
  /// Creates a risk message card.
  const RiskMessageCard({required this.triggeredRules, super.key});

  /// The rules that were triggered.
  final Set<RiskRule> triggeredRules;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final reasons = _reasons(l10n);
    final fullLabel = '${reasons.join(". ")}. ${l10n.fraudShield_alert_closing}';

    return Semantics(
      label: fullLabel,
      child: Card(
        color: Colors.amber.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber.shade300, width: 1.5),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.fraudShield_alert_title,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.amber.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...reasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 22,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reason,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.fraudShield_alert_closing,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _reasons(AppLocalizations l10n) {
    final out = <String>[];
    for (final rule in RiskRule.values) {
      if (!triggeredRules.contains(rule)) continue;
      switch (rule) {
        case RiskRule.unusualAmount:
          out.add(l10n.fraudShield_alert_unusualAmount);
        case RiskRule.newRecipient:
          out.add(l10n.fraudShield_alert_newRecipient);
        case RiskRule.highFrequency:
          out.add(l10n.fraudShield_alert_highFrequency);
        case RiskRule.unusualTime:
          out.add(l10n.fraudShield_alert_unusualTime);
      }
    }
    return out;
  }
}
