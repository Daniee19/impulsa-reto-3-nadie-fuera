import 'package:meta/meta.dart';

/// Type of friction detected.
enum FrictionType {
  /// User navigated back multiple times.
  repeatedBackNavigation,

  /// User was inactive for too long.
  prolongedInactivity,

  /// User made the same validation error repeatedly.
  repeatedError,
}

/// Configurable thresholds for friction detection.
@immutable
class FrictionThresholds {
  /// Creates thresholds with defaults.
  const FrictionThresholds({
    this.backNavigationCount = 3,
    this.inactivitySeconds = 20,
    this.repeatedErrorCount = 3,
  });

  /// Back navigations before signal fires.
  final int backNavigationCount;

  /// Seconds of inactivity before signal fires.
  final int inactivitySeconds;

  /// Repeated errors before signal fires.
  final int repeatedErrorCount;
}

/// A detected friction event.
@immutable
class FrictionSignal {
  /// Creates a friction signal.
  const FrictionSignal({
    required this.type,
    required this.flowId,
    required this.stepRoute,
    required this.stepName,
    required this.occurrences,
    required this.detectedAt,
  });

  /// What kind of friction was detected.
  final FrictionType type;

  /// Identifies the user flow (e.g. "pay-bill").
  final String flowId;

  /// Route where friction was detected.
  final String stepRoute;

  /// Human-readable step name.
  final String stepName;

  /// How many times the friction occurred.
  final int occurrences;

  /// When the friction was detected.
  final DateTime detectedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrictionSignal &&
          type == other.type &&
          flowId == other.flowId &&
          stepRoute == other.stepRoute &&
          occurrences == other.occurrences;

  @override
  int get hashCode => Object.hash(type, flowId, stepRoute, occurrences);
}
