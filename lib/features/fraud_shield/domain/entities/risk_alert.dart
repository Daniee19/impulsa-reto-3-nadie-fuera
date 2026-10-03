import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:meta/meta.dart';

/// Severity level of a risk alert.
enum RiskLevel {
  /// Single rule triggered.
  medium,

  /// Multiple rules triggered.
  high,
}

/// Result of a risk evaluation when one or more rules are triggered.
@immutable
class RiskAlert {
  /// Creates a risk alert with the triggered rules and operation context.
  const RiskAlert({required this.triggeredRules, required this.operation});

  /// The set of risk rules that were triggered.
  final Set<RiskRule> triggeredRules;

  /// The operation that was evaluated.
  final OperationContext operation;

  /// High if more than one rule triggered, medium otherwise.
  RiskLevel get riskLevel =>
      triggeredRules.length > 1 ? RiskLevel.high : RiskLevel.medium;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskAlert &&
          triggeredRules.length == other.triggeredRules.length &&
          triggeredRules.containsAll(other.triggeredRules) &&
          operation == other.operation;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(triggeredRules.toList()..sort((a, b) => a.index - b.index)),
    operation,
  );
}
