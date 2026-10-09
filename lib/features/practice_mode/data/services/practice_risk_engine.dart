import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_alert.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_thresholds.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/services/risk_engine.dart';

class PracticeRiskEngine extends RiskEngine {
  @override
  RiskAlert? evaluate({
    required OperationContext operation,
    required List<Operation> history,
    RiskThresholds thresholds = const RiskThresholds(),
  }) {
    if (operation.amount > 500) {
      return RiskAlert(
        triggeredRules: const {RiskRule.unusualAmount},
        operation: operation,
      );
    }
    return null;
  }
}
