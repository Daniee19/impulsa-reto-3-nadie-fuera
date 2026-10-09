import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/services/risk_engine.dart';

/// Provider for the risk engine, overridable for practice mode.
final riskEngineProvider = Provider<RiskEngine>((ref) => RiskEngine());
