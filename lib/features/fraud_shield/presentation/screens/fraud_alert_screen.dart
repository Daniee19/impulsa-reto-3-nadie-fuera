import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/trusted_person.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/fraud_alert_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/trusted_person_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/widgets/risk_message_card.dart';

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
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.announceForAccessibility(
        View.of(context),
        l10n.fraudShield_alert_title,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final alertState = ref.watch(fraudAlertProvider);

    if (alertState == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.fraudShield_alert_title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final trustedPerson = ref.watch(trustedPersonProvider);
    final showConsultOption =
        !_consultSent &&
        trustedPerson != null &&
        trustedPerson.hasPermission(TrustedPermission.securityAlerts);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fraudShield_alert_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RiskMessageCard(triggeredRules: alertState.alert.triggeredRules),
              const Spacer(),
              AccessibleButton(
                text: l10n.fraudShield_action_cancel,
                icon: Icons.close,
                onPressed: () => context.pop(),
              ),
              AccessibleButton(
                text: l10n.fraudShield_action_continue,
                icon: Icons.arrow_forward,
                onPressed: () {
                  final route = alertState.continueRoute;
                  final extra = alertState.continueExtra;
                  ref.read(fraudAlertProvider.notifier).clear();
                  context.go(route, extra: extra);
                },
              ),
              if (showConsultOption)
                AccessibleButton(
                  text: l10n.fraudShield_action_consultTrusted(
                    trustedPerson.name,
                  ),
                  icon: Icons.person,
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
