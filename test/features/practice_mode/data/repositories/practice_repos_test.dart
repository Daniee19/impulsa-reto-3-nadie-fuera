import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/repositories/practice_account_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/repositories/practice_bill_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/repositories/practice_contact_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/repositories/practice_operation_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/services/practice_risk_engine.dart';

void main() {
  group('PracticeAccountRepository', () {
    late PracticeAccountRepository repo;
    setUp(() => repo = PracticeAccountRepository());

    test('initial balance is 5000', () async {
      final account = await repo.getAccount();
      expect(account.availableBalance, 5000.0);
      expect(account.id, 'practice-account');
    });

    test('updateBalance changes balance', () async {
      await repo.updateBalance('practice-account', 4500);
      final account = await repo.getAccount();
      expect(account.availableBalance, 4500);
    });

    test('updateBalance throws on negative', () async {
      expect(
        () => repo.updateBalance('practice-account', -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('reset restores initial balance', () async {
      await repo.updateBalance('practice-account', 100);
      repo.reset();
      final account = await repo.getAccount();
      expect(account.availableBalance, 5000.0);
    });
  });

  group('PracticeBillRepository', () {
    late PracticeBillRepository repo;
    setUp(() => repo = PracticeBillRepository());

    test('has 3 pending bills initially', () async {
      final bills = await repo.getBills(status: BillStatus.pending);
      expect(bills.length, 3);
    });

    test('payBill marks bill as paid', () async {
      await repo.payBill('p-bill-1');
      final paid = await repo.getBillById('p-bill-1');
      expect(paid.status, BillStatus.paid);
    });

    test('payBill throws on already paid', () async {
      await repo.payBill('p-bill-1');
      expect(() => repo.payBill('p-bill-1'), throwsA(isA<StateError>()));
    });

    test('reset restores all bills', () async {
      await repo.payBill('p-bill-1');
      await repo.payBill('p-bill-2');
      repo.reset();
      final bills = await repo.getBills(status: BillStatus.pending);
      expect(bills.length, 3);
    });
  });

  group('PracticeContactRepository', () {
    test('has 3 contacts', () async {
      final repo = PracticeContactRepository();
      final contacts = await repo.getContacts();
      expect(contacts.length, 3);
      expect(contacts[0].name, 'Ana García');
    });

    test('getContactById finds contact', () async {
      final repo = PracticeContactRepository();
      final contact = await repo.getContactById('p-contact-2');
      expect(contact.name, 'Pedro Ruiz');
    });
  });

  group('PracticeOperationRepository', () {
    late PracticeOperationRepository repo;
    setUp(() => repo = PracticeOperationRepository());

    test('starts empty', () async {
      final ops = await repo.getOperations();
      expect(ops, isEmpty);
    });

    test('createOperation adds to list', () async {
      final op = await repo.createOperation(
        type: OperationType.payment,
        recipientName: 'Enel',
        amount: 95,
        description: 'Pago Luz',
      );
      expect(op.id, 'p-op-1');
      expect(op.status, OperationStatus.success);
      final ops = await repo.getOperations();
      expect(ops.length, 1);
    });

    test('reset clears operations', () async {
      await repo.createOperation(
        type: OperationType.transfer,
        recipientName: 'Ana',
        amount: 50,
        description: 'Test',
      );
      repo.reset();
      final ops = await repo.getOperations();
      expect(ops, isEmpty);
    });
  });

  group('PracticeRiskEngine', () {
    late PracticeRiskEngine engine;
    setUp(() => engine = PracticeRiskEngine());

    test('triggers alert for amount > 500', () {
      final alert = engine.evaluate(
        operation: OperationContext(
          type: OperationType.transfer,
          amount: 600,
          recipientId: 'c1',
          recipientName: 'Ana',
          timestamp: DateTime.now(),
        ),
        history: [],
      );
      expect(alert, isNotNull);
      expect(alert!.triggeredRules, contains(RiskRule.unusualAmount));
    });

    test('no alert for amount <= 500', () {
      final alert = engine.evaluate(
        operation: OperationContext(
          type: OperationType.transfer,
          amount: 500,
          recipientId: 'c1',
          recipientName: 'Ana',
          timestamp: DateTime.now(),
        ),
        history: [],
      );
      expect(alert, isNull);
    });
  });
}
