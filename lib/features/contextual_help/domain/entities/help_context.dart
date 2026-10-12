import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:meta/meta.dart';

/// Context captured when the user requests help (FR-005).
@immutable
class HelpContext {
  /// Creates a help context package.
  const HelpContext({
    required this.screenName,
    required this.screenRoute,
    required this.timestamp,
    this.flowStep,
    this.operationType,
    this.operationAmount,
    this.operationRecipient,
    this.frictionDetail,
  });

  /// Human-readable screen name in Spanish.
  final String screenName;

  /// Technical route path.
  final String screenRoute;

  /// Step within a flow (e.g. "Paso 2 de 2"), null if not in a flow.
  final String? flowStep;

  /// Type of in-progress operation, null if none.
  final OperationType? operationType;

  /// Amount of in-progress operation, null if none.
  final double? operationAmount;

  /// Recipient name of in-progress operation, null if none.
  final String? operationRecipient;

  /// Human-readable friction detail, null if no friction detected.
  final String? frictionDetail;

  /// When the help was requested.
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HelpContext &&
          screenName == other.screenName &&
          screenRoute == other.screenRoute &&
          flowStep == other.flowStep &&
          operationType == other.operationType &&
          operationAmount == other.operationAmount &&
          operationRecipient == other.operationRecipient &&
          frictionDetail == other.frictionDetail &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(
    screenName,
    screenRoute,
    flowStep,
    operationType,
    operationAmount,
    operationRecipient,
    frictionDetail,
    timestamp,
  );
}
