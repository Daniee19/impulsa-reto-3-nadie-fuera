import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/extra_feature.dart';

/// Proposal card offering a new feature with 3 options.
class UnlockProposalCard extends StatefulWidget {
  /// Creates a proposal card for the given feature.
  const UnlockProposalCard({
    required this.config,
    required this.onAccept,
    required this.onPractice,
    required this.onReject,
    super.key,
  });

  /// Configuration of the proposed feature.
  final ExtraFeatureConfig config;

  /// Called when user taps "Sí, actívalo".
  final VoidCallback onAccept;

  /// Called when user taps "Primero quiero practicarlo".
  final VoidCallback onPractice;

  /// Called when user taps "No, por ahora no".
  final VoidCallback onReject;

  @override
  State<UnlockProposalCard> createState() => _UnlockProposalCardState();
}

class _UnlockProposalCardState extends State<UnlockProposalCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final message = _proposalMessage(l10n);
      A11yHelpers.screenAnnounce(
        View.of(context),
        l10n.announceUnlockProposal(message),
      );
    });
  }

  String _proposalMessage(AppLocalizations l10n) {
    switch (widget.config.feature) {
      case ExtraFeature.transactionHistory:
        return l10n.unlock_proposal_transactions;
      case ExtraFeature.mobileRecharge:
        return l10n.unlock_proposal_recharge;
      case ExtraFeature.qrPayment:
        return l10n.unlock_proposal_qr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final message = _proposalMessage(l10n);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.unlock_proposal_title,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(message, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 20),
            AccessibleButton(
              text: l10n.unlock_accept,
              icon: Icons.check,
              onPressed: widget.onAccept,
            ),
            const SizedBox(height: A11yHelpers.minSeparation),
            AccessibleButton(
              text: l10n.unlock_practice,
              icon: Icons.school,
              onPressed: widget.onPractice,
            ),
            const SizedBox(height: A11yHelpers.minSeparation),
            AccessibleButton(
              text: l10n.unlock_reject,
              icon: Icons.close,
              onPressed: widget.onReject,
            ),
          ],
        ),
      ),
    );
  }
}
