import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/extra_feature.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/providers/feature_flags_provider.dart';

/// Settings screen for managing extra features.
class FeatureManagementScreen extends ConsumerWidget {
  /// Creates the feature management screen.
  const FeatureManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statesAsync = ref.watch(featureStatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.unlock_moreFeatures)),
      body: SafeArea(
        child: statesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (states) {
            final hasActive = states.values.any(
              (s) => s == FeatureState.active,
            );
            final hiddenFeatures = ExtraFeature.values
                .where((f) => states[f] == FeatureState.unlockedHidden)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (hasActive) ...[
                  AccessibleButton(
                    text: l10n.unlock_resetToBasic,
                    icon: Icons.replay,
                    onPressed: () => _confirmReset(context, ref, l10n),
                  ),
                  const SizedBox(height: 24),
                ],
                if (hiddenFeatures.isNotEmpty) ...[
                  Text(
                    l10n.unlock_reactivate,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  for (final feature in hiddenFeatures)
                    _FeatureToggleTile(feature: feature),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmReset(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.unlock_resetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.unlock_reject),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(featureFlagRepositoryProvider).resetToBasicView();
              ref.invalidate(featureStatesProvider);
            },
            child: Text(l10n.unlock_accept),
          ),
        ],
      ),
    );
  }
}

class _FeatureToggleTile extends ConsumerWidget {
  const _FeatureToggleTile({required this.feature});

  final ExtraFeature feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ExtraFeatureConfig.forFeature(feature);
    final l10n = AppLocalizations.of(context)!;
    final name = _resolveName(config, l10n);

    return Semantics(
      label: '$name, ${l10n.unlock_reactivate}',
      child: ListTile(
        leading: Icon(config.iconData, size: 32),
        title: Text(name),
        contentPadding: EdgeInsets.zero,
        trailing: SizedBox(
          height: A11yHelpers.minTapTarget,
          width: A11yHelpers.minTapTarget,
          child: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: l10n.unlock_reactivate,
            onPressed: () async {
              await ref
                  .read(featureFlagRepositoryProvider)
                  .setState(feature, FeatureState.active);
              ref.invalidate(featureStatesProvider);
            },
          ),
        ),
      ),
    );
  }

  String _resolveName(ExtraFeatureConfig config, AppLocalizations l10n) {
    switch (config.feature) {
      case ExtraFeature.transactionHistory:
        return l10n.unlock_feature_transactions;
      case ExtraFeature.mobileRecharge:
        return l10n.unlock_feature_recharge;
      case ExtraFeature.qrPayment:
        return l10n.unlock_feature_qr;
    }
  }
}
