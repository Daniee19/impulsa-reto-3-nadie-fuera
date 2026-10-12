import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/operation_in_progress.dart';

/// Builds a safe [HelpContext] from navigation and operation state.
class ContextCollector {
  /// Collects context, filtering sensitive data per FR-016.
  HelpContext collect({
    required String currentRoute,
    required String screenName,
    String? flowStep,
    OperationInProgress? operation,
    String? frictionDetail,
  }) {
    return HelpContext(
      screenName: screenName,
      screenRoute: currentRoute,
      flowStep: flowStep,
      operationType: operation?.type,
      operationAmount: operation?.amount,
      operationRecipient: operation?.recipientName,
      frictionDetail: frictionDetail,
      timestamp: DateTime.now(),
    );
  }
}
