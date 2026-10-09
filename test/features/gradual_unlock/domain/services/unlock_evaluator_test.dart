import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/confidence_metrics.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/extra_feature.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/services/unlock_evaluator.dart';

void main() {
  final evaluator = UnlockEvaluator();
  final allLocked = {
    for (final f in ExtraFeature.values) f: FeatureState.locked,
  };
  final noRejections = {for (final f in ExtraFeature.values) f: 0};

  test('no metrics met returns null', () {
    final result = evaluator.evaluate(
      metrics: const ConfidenceMetrics(),
      states: allLocked,
      rejections: noRejections,
    );
    expect(result, isNull);
  });

  test('5 ops without help proposes first locked feature', () {
    final result = evaluator.evaluate(
      metrics: const ConfidenceMetrics(successfulOpsWithoutHelp: 5),
      states: allLocked,
      rejections: noRejections,
    );
    expect(result, isNotNull);
    expect(result!.feature, ExtraFeature.transactionHistory);
  });

  test('3 practice sessions proposes first locked feature', () {
    final result = evaluator.evaluate(
      metrics: const ConfidenceMetrics(practiceSessionsCompleted: 3),
      states: allLocked,
      rejections: noRejections,
    );
    expect(result, isNotNull);
    expect(result!.feature, ExtraFeature.transactionHistory);
  });

  test('active feature is skipped, proposes next locked', () {
    final states = Map.of(allLocked)
      ..[ExtraFeature.transactionHistory] = FeatureState.active;
    final result = evaluator.evaluate(
      metrics: const ConfidenceMetrics(successfulOpsWithoutHelp: 5),
      states: states,
      rejections: noRejections,
    );
    expect(result!.feature, ExtraFeature.mobileRecharge);
  });

  test('feature with 3 rejections is skipped', () {
    final rejections = Map.of(noRejections)
      ..[ExtraFeature.transactionHistory] = 3;
    final result = evaluator.evaluate(
      metrics: const ConfidenceMetrics(successfulOpsWithoutHelp: 5),
      states: allLocked,
      rejections: rejections,
    );
    expect(result!.feature, ExtraFeature.mobileRecharge);
  });

  test('all features active returns null', () {
    final allActive = {
      for (final f in ExtraFeature.values) f: FeatureState.active,
    };
    final result = evaluator.evaluate(
      metrics: const ConfidenceMetrics(successfulOpsWithoutHelp: 10),
      states: allActive,
      rejections: noRejections,
    );
    expect(result, isNull);
  });

  test('priority order: transactionHistory before mobileRecharge', () {
    final result = evaluator.evaluate(
      metrics: const ConfidenceMetrics(successfulOpsWithoutHelp: 5),
      states: allLocked,
      rejections: noRejections,
    );
    expect(result!.feature, ExtraFeature.transactionHistory);
  });

  test('custom thresholds are respected', () {
    final result = evaluator.evaluate(
      metrics: const ConfidenceMetrics(successfulOpsWithoutHelp: 2),
      states: allLocked,
      rejections: noRejections,
      thresholds: const UnlockThresholds(opsWithoutHelp: 2),
    );
    expect(result, isNotNull);
    expect(result!.feature, ExtraFeature.transactionHistory);
  });

  test('unlockedHidden is skipped like active', () {
    final states = Map.of(allLocked)
      ..[ExtraFeature.transactionHistory] = FeatureState.unlockedHidden;
    final result = evaluator.evaluate(
      metrics: const ConfidenceMetrics(successfulOpsWithoutHelp: 5),
      states: states,
      rejections: noRejections,
    );
    expect(result!.feature, ExtraFeature.mobileRecharge);
  });
}
