import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/account.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/saved_contact.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/account_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/bill_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/contact_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/assistant_intent.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/prepare_result.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/services/operation_preparer.dart';

class _FakeAccountRepo implements AccountRepository {
  @override
  Future<Account> getAccount() async => const Account(
    id: 'acc-1',
    holderName: 'Rosa',
    maskedNumber: '****1234',
    availableBalance: 1500.0,
  );

  @override
  Future<Account> updateBalance(String accountId, double newBalance) =>
      throw UnimplementedError();
}

class _FakeBillRepo implements BillRepository {
  @override
  Future<List<Bill>> getBills({BillStatus? status}) async => [
    Bill(
      id: 'b-1',
      serviceName: 'Luz',
      providerName: 'Enel',
      amount: 85.50,
      dueDate: DateTime(2026, 10, 15),
      status: BillStatus.pending,
    ),
    Bill(
      id: 'b-2',
      serviceName: 'Agua',
      providerName: 'Sedapal',
      amount: 42.00,
      dueDate: DateTime(2026, 10, 20),
      status: BillStatus.pending,
    ),
  ];

  @override
  Future<Bill> getBillById(String billId) => throw UnimplementedError();
  @override
  Future<Bill> payBill(String billId) => throw UnimplementedError();
}

class _FakeContactRepo implements ContactRepository {
  @override
  Future<List<SavedContact>> getContacts() async => const [
    SavedContact(
      id: 'c-1',
      name: 'Valeria',
      initial: 'V',
      maskedAccount: '****5678',
    ),
    SavedContact(
      id: 'c-2',
      name: 'Carlos',
      initial: 'C',
      maskedAccount: '****9012',
    ),
  ];

  @override
  Future<SavedContact> getContactById(String contactId) =>
      throw UnimplementedError();
}

void main() {
  late OperationPreparer preparer;

  setUp(() {
    preparer = OperationPreparer(
      accountRepo: _FakeAccountRepo(),
      billRepo: _FakeBillRepo(),
      contactRepo: _FakeContactRepo(),
    );
  });

  test('payBill + serviceName luz + bill exists → PrepareSuccess', () async {
    final result = await preparer.prepare(
      const ParsedIntent(
        type: AssistantIntentType.payBill,
        parameters: IntentParameters(serviceName: 'luz'),
      ),
    );
    expect(result, isA<PrepareSuccess>());
    final success = result as PrepareSuccess;
    expect(success.summary.amount, 85.50);
    expect(success.summary.recipientName, 'Luz');
  });

  test(
    'payBill + serviceName cable + not found → PrepareBillNotFound',
    () async {
      final result = await preparer.prepare(
        const ParsedIntent(
          type: AssistantIntentType.payBill,
          parameters: IntentParameters(serviceName: 'cable'),
        ),
      );
      expect(result, isA<PrepareBillNotFound>());
      expect((result as PrepareBillNotFound).serviceName, 'cable');
    },
  );

  test('payBill + serviceName null → PrepareNeedsService', () async {
    final result = await preparer.prepare(
      const ParsedIntent(type: AssistantIntentType.payBill),
    );
    expect(result, isA<PrepareNeedsService>());
    final needs = result as PrepareNeedsService;
    expect(needs.pendingBills.length, 2);
  });

  test('sendMoney + Valeria + amount 50 → PrepareSuccess', () async {
    final result = await preparer.prepare(
      const ParsedIntent(
        type: AssistantIntentType.sendMoney,
        parameters: IntentParameters(contactName: 'valeria', amount: 50),
      ),
    );
    expect(result, isA<PrepareSuccess>());
    final success = result as PrepareSuccess;
    expect(success.summary.recipientName, 'Valeria');
    expect(success.summary.amount, 50);
    expect(success.summary.type, OperationType.transfer);
  });

  test('sendMoney + contactName null → PrepareNeedsContact', () async {
    final result = await preparer.prepare(
      const ParsedIntent(type: AssistantIntentType.sendMoney),
    );
    expect(result, isA<PrepareNeedsContact>());
  });

  test('sendMoney + Valeria + amount null → PrepareNeedsAmount', () async {
    final result = await preparer.prepare(
      const ParsedIntent(
        type: AssistantIntentType.sendMoney,
        parameters: IntentParameters(contactName: 'valeria'),
      ),
    );
    expect(result, isA<PrepareNeedsAmount>());
    expect((result as PrepareNeedsAmount).contactName, 'Valeria');
  });

  test('checkBalance → PrepareBalanceResult', () async {
    final result = await preparer.prepare(
      const ParsedIntent(type: AssistantIntentType.checkBalance),
    );
    expect(result, isA<PrepareBalanceResult>());
    expect((result as PrepareBalanceResult).balance, 1500.0);
  });

  test('amount in PrepareSuccess comes from repo, not parser', () async {
    final result = await preparer.prepare(
      const ParsedIntent(
        type: AssistantIntentType.payBill,
        parameters: IntentParameters(serviceName: 'luz'),
      ),
    );
    final success = result as PrepareSuccess;
    expect(success.summary.amount, 85.50);
  });
}
