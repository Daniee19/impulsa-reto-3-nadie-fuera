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
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/presentation/providers/reminder_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/presentation/widgets/reminder_card.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/providers/practice_session_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/providers/lesson_suggestion_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/widgets/lesson_suggestion_card.dart';

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
      if (!ref.read(practiceSessionProvider).active) {
        ref.read(unlockProposalProvider.notifier).evaluate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPractice = ref.watch(practiceSessionProvider).active;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.easyMode_home_title),
        actions: [
          if (!isPractice) ..._buildAppBarActions(context, l10n),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (!isPractice) ..._buildExtras(l10n),
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
              if (!isPractice) ...[
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
                ActionCard(
                  label: l10n.lesson_listTitle,
                  icon: Icons.shield,
                  onTap: () => context.push('/easy-mode/lessons'),
                ),
                ExtraFeaturesSection(
                  features: ref.watch(activeExtraFeaturesProvider),
                  onFeatureTap: (route) => context.go(route),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, AppLocalizations l10n) {
    final statesAsync = ref.watch(featureStatesProvider);
    final hasUnlockedFeatures = statesAsync.maybeWhen(
      data: (states) => states.values.any(
        (s) => s == FeatureState.active || s == FeatureState.unlockedHidden,
      ),
      orElse: () => false,
    );
    return [
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
    ];
  }

  List<Widget> _buildExtras(AppLocalizations l10n) {
    final proposal = ref.watch(unlockProposalProvider);
    final lessonSuggestion = ref.watch(lessonSuggestionProvider);

    return [
      ...ref.watch(activeRemindersProvider).maybeWhen(
        data: (reminders) => reminders
            .take(3)
            .map((r) => ReminderCard(reminder: r))
            .toList(),
        orElse: () => <Widget>[],
      ),
      if (lessonSuggestion != null)
        LessonSuggestionCard(suggestion: lessonSuggestion),
      if (proposal != null)
        UnlockProposalCard(
          config: ExtraFeatureConfig.forFeature(proposal.feature),
          onAccept: () => ref
              .read(unlockProposalProvider.notifier)
              .accept(proposal.feature),
          onPractice: () {
            ref.read(unlockProposalProvider.notifier).dismiss();
          },
          onReject: () => ref
              .read(unlockProposalProvider.notifier)
              .reject(proposal.feature),
        ),
    ];
  }
}
