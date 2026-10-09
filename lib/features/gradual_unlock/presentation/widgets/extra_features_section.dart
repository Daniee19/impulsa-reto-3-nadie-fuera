import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/widgets/action_card.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/extra_feature.dart';

/// Section showing activated extra features below the 4 main actions.
class ExtraFeaturesSection extends StatelessWidget {
  /// Creates the extra features section.
  const ExtraFeaturesSection({
    required this.features,
    required this.onFeatureTap,
    super.key,
  });

  /// Active extra features to display.
  final List<ExtraFeature> features;

  /// Called with the route when a feature is tapped.
  final ValueChanged<String> onFeatureTap;

  String _featureName(AppLocalizations l10n, ExtraFeature feature) {
    switch (feature) {
      case ExtraFeature.transactionHistory:
        return l10n.unlock_feature_transactions;
      case ExtraFeature.mobileRecharge:
        return l10n.unlock_feature_recharge;
      case ExtraFeature.qrPayment:
        return l10n.unlock_feature_qr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            l10n.unlock_moreFeatures,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 4),
        for (final feature in features)
          ActionCard(
            label: _featureName(l10n, feature),
            icon: ExtraFeatureConfig.forFeature(feature).iconData,
            onTap: () =>
                onFeatureTap(ExtraFeatureConfig.forFeature(feature).route),
          ),
      ],
    );
  }
}
