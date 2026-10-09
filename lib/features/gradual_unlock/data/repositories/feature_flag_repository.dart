import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/confidence_metrics.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/extra_feature.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeatureFlagRepository {
  static const _prefix = 'gradual_unlock_';
  static const _statePrefix = '${_prefix}state_';
  static const _rejPrefix = '${_prefix}rej_';
  static const _opsKey = '${_prefix}ops_without_help';
  static const _practiceKey = '${_prefix}practice_sessions';

  Future<Map<ExtraFeature, FeatureState>> getStates() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final f in ExtraFeature.values)
        f: FeatureState.values[prefs.getInt('$_statePrefix${f.name}') ?? 0],
    };
  }

  Future<void> setState(ExtraFeature feature, FeatureState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_statePrefix${feature.name}', state.index);
  }

  Future<ConfidenceMetrics> getMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    return ConfidenceMetrics(
      successfulOpsWithoutHelp: prefs.getInt(_opsKey) ?? 0,
      practiceSessionsCompleted: prefs.getInt(_practiceKey) ?? 0,
    );
  }

  Future<void> incrementOpsWithoutHelp() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_opsKey) ?? 0;
    await prefs.setInt(_opsKey, current + 1);
  }

  Future<void> incrementPracticeSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_practiceKey) ?? 0;
    await prefs.setInt(_practiceKey, current + 1);
  }

  Future<Map<ExtraFeature, int>> getRejections() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final f in ExtraFeature.values)
        f: prefs.getInt('$_rejPrefix${f.name}') ?? 0,
    };
  }

  Future<void> incrementRejection(ExtraFeature feature) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_rejPrefix${feature.name}';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  Future<void> resetToBasicView() async {
    final states = await getStates();
    for (final entry in states.entries) {
      if (entry.value == FeatureState.active) {
        await setState(entry.key, FeatureState.unlockedHidden);
      }
    }
  }
}
