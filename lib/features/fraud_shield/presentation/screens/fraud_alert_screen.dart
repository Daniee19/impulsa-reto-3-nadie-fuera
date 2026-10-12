import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/fraud_alert_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/widgets/risk_message_card.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/providers/lesson_suggestion_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

/// Pause screen shown when the risk engine detects a suspicious operation.
class FraudAlertScreen extends ConsumerStatefulWidget {
  /// Creates the fraud alert screen.
  const FraudAlertScreen({super.key});

  @override
  ConsumerState<FraudAlertScreen> createState() => _FraudAlertScreenState();
}

class _FraudAlertScreenState extends ConsumerState<FraudAlertScreen> {
  bool _consultSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final alertState = ref.read(fraudAlertProvider);
      final riskMessage = alertState != null
          ? _riskSummary(alertState.alert.triggeredRules, l10n)
          : l10n.fraudShield_alert_title;
      A11yHelpers.screenAnnounce(
        View.of(context),
        l10n.announceFraudAlert(riskMessage),
      );
    });
  }

  String _riskSummary(Set<RiskRule> rules, AppLocalizations l10n) {
    final parts = <String>[];
    for (final rule in rules) {
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
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final alertState = ref.watch(fraudAlertProvider);
    final theme = Theme.of(context);

    if (alertState == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.fraudShield_alert_title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final trustedPerson = ref.watch(trustedPersonProvider).valueOrNull;
    final showConsultOption =
        !_consultSent &&
        trustedPerson != null &&
        trustedPerson.hasPermission(TrustedPermission.securityAlerts);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fraudShield_alert_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RiskMessageCard(
                triggeredRules: alertState.alert.triggeredRules,
              ),
              const SizedBox(height: 32),
              // Continue — primary action
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Semantics(
                  button: true,
                  label: l10n.fraudShield_action_continue,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(lessonSuggestionProvider.notifier)
                          .triggerFromAlert(
                            alertState.alert.triggeredRules,
                          );
                      final route = alertState.continueRoute;
                      final extra = alertState.continueExtra;
                      ref.read(fraudAlertProvider.notifier).clear();
                      context.go(route, extra: extra);
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l10n.fraudShield_action_continue),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        A11yHelpers.minTapTarget,
                      ),
                    ),
                  ),
                ),
              ),
              if (showConsultOption)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Semantics(
                    button: true,
                    label: l10n.fraudShield_action_consultTrusted(
                      trustedPerson.name,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _consultSent = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.fraudShield_notification_sent(
                                trustedPerson.name,
                              ),
                            ),
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person),
                      label: Text(
                        l10n.fraudShield_action_consultTrusted(
                          trustedPerson.name,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        minimumSize: const Size(
                          double.infinity,
                          A11yHelpers.minTapTarget,
                        ),
                      ),
                    ),
                  ),
                ),
              // Cancel — secondary/text style
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Semantics(
                  button: true,
                  label: l10n.fraudShield_action_cancel,
                  child: TextButton.icon(
                    onPressed: () {
                      ref
                          .read(lessonSuggestionProvider.notifier)
                          .triggerFromAlert(
                            alertState.alert.triggeredRules,
                          );
                      context.pop();
                    },
                    icon: const Icon(Icons.close),
                    label: Text(l10n.fraudShield_action_cancel),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                      minimumSize: const Size(
                        double.infinity,
                        A11yHelpers.minTapTarget,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
