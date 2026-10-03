import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_alert.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_thresholds.dart';

/// Pure-Dart risk engine that evaluates operations against configurable rules.
class RiskEngine {
  /// Evaluates an operation against risk rules.
  ///
  /// Returns null if no risk is detected, or a [RiskAlert] with all
  /// triggered rules if at least one rule fires.
  RiskAlert? evaluate({
    required OperationContext operation,
    required List<Operation> history,
    RiskThresholds thresholds = const RiskThresholds(),
  }) {
    final triggered = <RiskRule>{};

    if (_isUnusualAmount(operation, history, thresholds)) {
      triggered.add(RiskRule.unusualAmount);
    }
    if (_isNewRecipient(operation, history)) {
      triggered.add(RiskRule.newRecipient);
    }
    if (_isHighFrequency(operation, history, thresholds)) {
      triggered.add(RiskRule.highFrequency);
    }
    if (_isUnusualTime(operation, thresholds)) {
      triggered.add(RiskRule.unusualTime);
    }

    if (triggered.isEmpty) return null;

    return RiskAlert(triggeredRules: triggered, operation: operation);
  }

  bool _isUnusualAmount(
    OperationContext operation,
    List<Operation> history,
    RiskThresholds thresholds,
  ) {
    final sameType = history.where((op) => op.type == operation.type).toList();
    if (sameType.isEmpty) return false;

    final window = sameType.length > thresholds.historyWindow
        ? sameType.sublist(0, thresholds.historyWindow)
        : sameType;
    final average =
        window.fold<double>(0, (sum, op) => sum + op.amount) / window.length;

    return operation.amount > average * thresholds.amountMultiplier;
  }

  bool _isNewRecipient(OperationContext operation, List<Operation> history) {
    if (operation.type != OperationType.transfer) return false;
    return !history.any((op) => op.recipientName == operation.recipientName);
  }

  bool _isHighFrequency(
    OperationContext operation,
    List<Operation> history,
    RiskThresholds thresholds,
  ) {
    final windowStart = operation.timestamp.subtract(
      Duration(minutes: thresholds.windowMinutes),
    );
    final recentCount = history
        .where((op) => op.date.isAfter(windowStart))
        .length;
    return recentCount >= thresholds.maxOpsInWindow;
  }

  bool _isUnusualTime(OperationContext operation, RiskThresholds thresholds) {
    final hour = operation.timestamp.hour;
    return hour < thresholds.safeHourStart || hour >= thresholds.safeHourEnd;
  }
}
