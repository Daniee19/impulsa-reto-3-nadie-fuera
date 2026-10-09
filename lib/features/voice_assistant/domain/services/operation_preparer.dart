import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/account_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/bill_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/contact_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/assistant_intent.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/operation_summary.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/prepare_result.dart';

/// Resolves a parsed intent into a concrete operation using repository data.
class OperationPreparer {
  /// Creates the preparer with the required repositories.
  const OperationPreparer({
    required this.accountRepo,
    required this.billRepo,
    required this.contactRepo,
  });

  /// Account repository for balance queries.
  final AccountRepository accountRepo;

  /// Bill repository for pending bills.
  final BillRepository billRepo;

  /// Contact repository for send-money resolution.
  final ContactRepository contactRepo;

  /// Prepares an operation from a parsed intent. All amounts and names
  /// in [PrepareSuccess] come from repository data, never from parser text.
  Future<PrepareResult> prepare(ParsedIntent intent) async {
    switch (intent.type) {
      case AssistantIntentType.checkBalance:
        final account = await accountRepo.getAccount();
        return PrepareBalanceResult(account.availableBalance);

      case AssistantIntentType.payBill:
        return _prepareBill(intent.parameters?.serviceName);

      case AssistantIntentType.sendMoney:
        return _prepareSend(
          intent.parameters?.contactName,
          intent.parameters?.amount,
        );

      case AssistantIntentType.requestHelp:
      case AssistantIntentType.unknown:
        return const PrepareBalanceResult(0);
    }
  }

  Future<PrepareResult> _prepareBill(String? serviceName) async {
    final pending = await billRepo.getBills(status: BillStatus.pending);

    if (serviceName == null) {
      return PrepareNeedsService(pending);
    }

    final match = pending.where(
      (b) => b.serviceName.toLowerCase().contains(serviceName.toLowerCase()),
    );

    if (match.isEmpty) {
      return PrepareBillNotFound(serviceName);
    }

    final bill = match.first;
    return PrepareSuccess(
      OperationSummary(
        type: OperationType.payment,
        amount: bill.amount,
        recipientName: bill.serviceName,
        recipientId: bill.id,
        spokenSummary:
            'Recibo de ${bill.serviceName} por ${bill.amount.toStringAsFixed(2)} soles',
      ),
    );
  }

  Future<PrepareResult> _prepareSend(
    String? contactName,
    double? amount,
  ) async {
    final contacts = await contactRepo.getContacts();

    if (contactName == null) {
      return PrepareNeedsContact(contacts);
    }

    final matches = contacts.where(
      (c) => c.name.toLowerCase().contains(contactName.toLowerCase()),
    );

    if (matches.isEmpty || matches.length > 1) {
      return PrepareNeedsContact(matches.toList());
    }

    final contact = matches.first;

    if (amount == null) {
      return PrepareNeedsAmount(contact.name);
    }

    return PrepareSuccess(
      OperationSummary(
        type: OperationType.transfer,
        amount: amount,
        recipientName: contact.name,
        recipientId: contact.id,
        spokenSummary: '${amount.toStringAsFixed(2)} soles a ${contact.name}',
      ),
    );
  }
}
