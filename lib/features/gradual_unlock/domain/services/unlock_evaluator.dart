import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/confidence_metrics.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/extra_feature.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/unlock_proposal.dart';

class UnlockEvaluator {
  UnlockProposal? evaluate({
    required ConfidenceMetrics metrics,
    required Map<ExtraFeature, FeatureState> states,
    required Map<ExtraFeature, int> rejections,
    UnlockThresholds thresholds = const UnlockThresholds(),
  }) {
    final meetsThreshold =
        metrics.successfulOpsWithoutHelp >= thresholds.opsWithoutHelp ||
        metrics.practiceSessionsCompleted >= thresholds.practiceSessions;

    if (!meetsThreshold) return null;

    for (final feature in ExtraFeature.values) {
      final state = states[feature] ?? FeatureState.locked;
      if (state != FeatureState.locked) continue;

      final rejCount = rejections[feature] ?? 0;
      if (rejCount >= thresholds.maxRejections) continue;

      return UnlockProposal(feature: feature);
    }

    return null;
  }
}
