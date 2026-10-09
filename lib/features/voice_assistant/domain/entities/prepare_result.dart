import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/saved_contact.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/operation_summary.dart';

/// Result of preparing an operation from a parsed intent.
sealed class PrepareResult {
  /// Base constructor.
  const PrepareResult();
}

/// Operation fully resolved, ready for confirmation.
class PrepareSuccess extends PrepareResult {
  /// Creates a success result.
  const PrepareSuccess(this.summary);

  /// The prepared operation summary with real data.
  final OperationSummary summary;
}

/// Need user to pick which service/bill to pay.
class PrepareNeedsService extends PrepareResult {
  /// Creates a needs-service result.
  const PrepareNeedsService(this.pendingBills);

  /// Available pending bills.
  final List<Bill> pendingBills;
}

/// Need user to pick which contact to send to.
class PrepareNeedsContact extends PrepareResult {
  /// Creates a needs-contact result.
  const PrepareNeedsContact(this.contacts);

  /// Available contacts.
  final List<SavedContact> contacts;
}

/// Need user to provide the amount.
class PrepareNeedsAmount extends PrepareResult {
  /// Creates a needs-amount result.
  const PrepareNeedsAmount(this.contactName);

  /// Resolved contact name.
  final String contactName;
}

/// Bill not found for the mentioned service.
class PrepareBillNotFound extends PrepareResult {
  /// Creates a bill-not-found result.
  const PrepareBillNotFound(this.serviceName);

  /// Service name that was searched.
  final String serviceName;
}

/// Balance query result (non-monetary, no confirmation needed).
class PrepareBalanceResult extends PrepareResult {
  /// Creates a balance result.
  const PrepareBalanceResult(this.balance);

  /// Account available balance from repository.
  final double balance;
}
