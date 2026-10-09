import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/widgets/action_card.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/extra_feature.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/providers/feature_flags_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/providers/unlock_proposal_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/widgets/extra_features_section.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/widgets/unlock_proposal_card.dart';

/// Main screen with 4 large action buttons for easy mode.
class EasyModeHomeScreen extends ConsumerStatefulWidget {
  /// Creates the easy mode home screen.
  const EasyModeHomeScreen({super.key});

  @override
  ConsumerState<EasyModeHomeScreen> createState() => _EasyModeHomeScreenState();
}

class _EasyModeHomeScreenState extends ConsumerState<EasyModeHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.announceHomeScreen);
      ref.read(unlockProposalProvider.notifier).evaluate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proposal = ref.watch(unlockProposalProvider);
    final extras = ref.watch(activeExtraFeaturesProvider);
    final statesAsync = ref.watch(featureStatesProvider);
    final hasUnlockedFeatures = statesAsync.maybeWhen(
      data: (states) => states.values.any(
        (s) => s == FeatureState.active || s == FeatureState.unlockedHidden,
      ),
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.easyMode_home_title),
        actions: [
          if (hasUnlockedFeatures)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: l10n.unlock_moreFeatures,
              onPressed: () => context.go('/easy-mode/settings/features'),
            ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: l10n.trustedPerson_title,
            onPressed: () => context.go('/easy-mode/settings/trusted-person'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (proposal != null)
                UnlockProposalCard(
                  config: ExtraFeatureConfig.forFeature(proposal.feature),
                  onAccept: () => ref
                      .read(unlockProposalProvider.notifier)
                      .accept(proposal.feature),
                  onPractice: () {
                    ref.read(unlockProposalProvider.notifier).dismiss();
                    // ponytail: navigate to 008 practice mode when implemented
                  },
                  onReject: () => ref
                      .read(unlockProposalProvider.notifier)
                      .reject(proposal.feature),
                ),
              ActionCard(
                label: l10n.easyMode_home_checkBalance,
                icon: Icons.account_balance_wallet,
                onTap: () => context.go('/easy-mode/balance'),
              ),
              ActionCard(
                label: l10n.easyMode_home_payBill,
                icon: Icons.receipt_long,
                onTap: () => context.go('/easy-mode/pay-bill'),
              ),
              ActionCard(
                label: l10n.easyMode_home_sendMoney,
                icon: Icons.send,
                onTap: () => context.go('/easy-mode/send-money'),
              ),
              ActionCard(
                label: l10n.easyMode_home_getHelp,
                icon: Icons.help,
                onTap: () => context.push('/easy-mode/help/contact-picker'),
              ),
              ActionCard(
                label: l10n.assistant_title,
                icon: Icons.record_voice_over,
                onTap: () => context.push('/easy-mode/assistant'),
              ),
              ActionCard(
                label: l10n.practice_title,
                icon: Icons.school,
                onTap: () => context.push('/easy-mode/practice'),
              ),
              ExtraFeaturesSection(
                features: extras,
                onFeatureTap: (route) => context.go(route),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
