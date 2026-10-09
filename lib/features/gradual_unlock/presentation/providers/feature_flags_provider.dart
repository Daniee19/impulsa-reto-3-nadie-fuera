import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/data/repositories/feature_flag_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/confidence_metrics.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/extra_feature.dart';

final featureFlagRepositoryProvider = Provider<FeatureFlagRepository>(
  (ref) => FeatureFlagRepository(),
);

final featureStatesProvider = FutureProvider<Map<ExtraFeature, FeatureState>>((
  ref,
) {
  return ref.watch(featureFlagRepositoryProvider).getStates();
});

final activeExtraFeaturesProvider = Provider<List<ExtraFeature>>((ref) {
  final statesAsync = ref.watch(featureStatesProvider);
  return statesAsync.maybeWhen(
    data: (states) => ExtraFeature.values
        .where((f) => states[f] == FeatureState.active)
        .toList(),
    orElse: () => [],
  );
});

final confidenceMetricsProvider = FutureProvider<ConfidenceMetrics>((ref) {
  return ref.watch(featureFlagRepositoryProvider).getMetrics();
});
