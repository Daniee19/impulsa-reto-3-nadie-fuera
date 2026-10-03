import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';

/// Displays a combined risk message for the triggered rules.
class RiskMessageCard extends StatelessWidget {
  /// Creates a risk message card.
  const RiskMessageCard({required this.triggeredRules, super.key});

  /// The rules that were triggered.
  final Set<RiskRule> triggeredRules;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final message = _buildMessage(l10n);

    return Semantics(
      label: message,
      child: Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              ExcludeSemantics(
                child: Text(
                  message,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildMessage(AppLocalizations l10n) {
    final parts = <String>[];

    for (final rule in RiskRule.values) {
      if (!triggeredRules.contains(rule)) continue;
      switch (rule) {
        case RiskRule.unusualAmount:
          parts.add(l10n.fraudShield_alert_unusualAmount);
        case RiskRule.newRecipient:
          parts.add(l10n.fraudShield_alert_newRecipient);
        case RiskRule.highFrequency:
          parts.add(l10n.fraudShield_alert_highFrequency);
        case RiskRule.unusualTime:
          parts.add(l10n.fraudShield_alert_unusualTime);
      }
    }

    final combined = parts.join(' ');
    return '$combined ${l10n.fraudShield_alert_closing}';
  }
}
