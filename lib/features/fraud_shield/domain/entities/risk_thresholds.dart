import 'package:meta/meta.dart';

/// Configurable thresholds for risk rule evaluation.
@immutable
class RiskThresholds {
  /// Creates risk thresholds with sensible defaults for the prototype.
  const RiskThresholds({
    this.amountMultiplier = 2.0,
    this.historyWindow = 10,
    this.maxOpsInWindow = 3,
    this.windowMinutes = 10,
    this.safeHourStart = 7,
    this.safeHourEnd = 22,
  });

  /// Factor over average to consider an amount unusual.
  final double amountMultiplier;

  /// Number of recent operations to calculate the average.
  final int historyWindow;

  /// Maximum operations before triggering a frequency alert.
  final int maxOpsInWindow;

  /// Time window in minutes for frequency check.
  final int windowMinutes;

  /// Start of the safe hour range (inclusive).
  final int safeHourStart;

  /// End of the safe hour range (exclusive).
  final int safeHourEnd;

  /// Creates a copy with the given fields replaced.
  RiskThresholds copyWith({
    double? amountMultiplier,
    int? historyWindow,
    int? maxOpsInWindow,
    int? windowMinutes,
    int? safeHourStart,
    int? safeHourEnd,
  }) {
    return RiskThresholds(
      amountMultiplier: amountMultiplier ?? this.amountMultiplier,
      historyWindow: historyWindow ?? this.historyWindow,
      maxOpsInWindow: maxOpsInWindow ?? this.maxOpsInWindow,
      windowMinutes: windowMinutes ?? this.windowMinutes,
      safeHourStart: safeHourStart ?? this.safeHourStart,
      safeHourEnd: safeHourEnd ?? this.safeHourEnd,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskThresholds &&
          amountMultiplier == other.amountMultiplier &&
          historyWindow == other.historyWindow &&
          maxOpsInWindow == other.maxOpsInWindow &&
          windowMinutes == other.windowMinutes &&
          safeHourStart == other.safeHourStart &&
          safeHourEnd == other.safeHourEnd;

  @override
  int get hashCode => Object.hash(
    amountMultiplier,
    historyWindow,
    maxOpsInWindow,
    windowMinutes,
    safeHourStart,
    safeHourEnd,
  );
}
