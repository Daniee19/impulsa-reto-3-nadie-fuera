import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/entities/friction_signal.dart';

/// Pure Dart friction detector. No Flutter imports.
class FrictionDetector {
  /// Creates the detector with configurable thresholds.
  FrictionDetector({this.thresholds = const FrictionThresholds()});

  /// Detection thresholds.
  final FrictionThresholds thresholds;

  final _backCounts = <String, int>{};
  final _errorCounts = <String, int>{};
  final _dismissed = <String>{};

  /// Records a back navigation. Returns signal at threshold.
  FrictionSignal? onBackNavigation({
    required String flowId,
    required String stepRoute,
    required String stepName,
  }) {
    final key = '$flowId:back';
    _backCounts[key] = (_backCounts[key] ?? 0) + 1;
    final count = _backCounts[key]!;

    if (count >= thresholds.backNavigationCount) {
      return FrictionSignal(
        type: FrictionType.repeatedBackNavigation,
        flowId: flowId,
        stepRoute: stepRoute,
        stepName: stepName,
        occurrences: count,
        detectedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// Records an inactivity timeout. Always returns a signal.
  FrictionSignal? onInactivityTimeout({
    required String flowId,
    required String stepRoute,
    required String stepName,
  }) {
    return FrictionSignal(
      type: FrictionType.prolongedInactivity,
      flowId: flowId,
      stepRoute: stepRoute,
      stepName: stepName,
      occurrences: 1,
      detectedAt: DateTime.now(),
    );
  }

  /// Records a validation error. Returns signal at threshold.
  FrictionSignal? onValidationError({
    required String flowId,
    required String stepRoute,
    required String stepName,
    required String fieldId,
    required String errorType,
  }) {
    final key = '$flowId:$stepRoute:$fieldId:$errorType';
    _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;
    final count = _errorCounts[key]!;

    if (count >= thresholds.repeatedErrorCount) {
      return FrictionSignal(
        type: FrictionType.repeatedError,
        flowId: flowId,
        stepRoute: stepRoute,
        stepName: stepName,
        occurrences: count,
        detectedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// Whether the route should be excluded from detection.
  bool isExcludedScreen(String route) {
    if (route.endsWith('/confirm')) return true;
    if (route.contains('fraud-alert')) return true;
    if (route.contains('assistant/consent')) return true;
    if (route.contains('trusted-person/consent')) return true;
    if (route.contains('/help/')) return true;
    return false;
  }

  /// Whether the route is part of an active flow.
  bool isActiveFlow(String route) {
    return route.startsWith('/easy-mode/pay-bill') ||
        route.startsWith('/easy-mode/send-money');
  }

  /// Clears all counters and dismissals.
  void resetForNewFlow() {
    _backCounts.clear();
    _errorCounts.clear();
    _dismissed.clear();
  }

  /// Marks a signal type as dismissed for a flow.
  void dismissSignal(FrictionType type, String flowId) {
    _dismissed.add('$flowId:${type.name}');
  }

  /// Whether this signal type was dismissed for the flow.
  bool isDismissed(FrictionType type, String flowId) {
    return _dismissed.contains('$flowId:${type.name}');
  }
}
