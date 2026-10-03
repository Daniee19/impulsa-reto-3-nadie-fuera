import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_alert.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_thresholds.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/services/risk_engine.dart';

void main() {
  late RiskEngine engine;
  final now = DateTime(2026, 10, 3, 14);

  setUp(() => engine = RiskEngine());

  List<Operation> paymentHistory({
    required List<double> amounts,
    Duration spacing = const Duration(days: 3),
  }) {
    return [
      for (var i = 0; i < amounts.length; i++)
        Operation(
          id: 'h-$i',
          type: OperationType.payment,
          recipientName: 'Servicio $i',
          amount: amounts[i],
          date: now.subtract(spacing * (i + 1)),
          status: OperationStatus.success,
          description: 'Pago $i',
        ),
    ];
  }

  List<Operation> transferHistory({
    required List<(String name, double amount)> entries,
    Duration spacing = const Duration(days: 3),
  }) {
    return [
      for (var i = 0; i < entries.length; i++)
        Operation(
          id: 't-$i',
          type: OperationType.transfer,
          recipientName: entries[i].$1,
          amount: entries[i].$2,
          date: now.subtract(spacing * (i + 1)),
          status: OperationStatus.success,
          description: 'Envío $i',
        ),
    ];
  }

  group('unusualAmount', () {
    test('normal amount returns null', () {
      final history = paymentHistory(amounts: [100, 90, 110, 95, 105]);
      final op = OperationContext(
        type: OperationType.payment,
        amount: 120,
        recipientId: 'svc-1',
        recipientName: 'Luz',
        timestamp: now,
      );
      expect(engine.evaluate(operation: op, history: history), isNull);
    });

    test('amount > 2x average triggers alert', () {
      final history = paymentHistory(amounts: [100, 90, 110, 95, 105]);
      final op = OperationContext(
        type: OperationType.payment,
        amount: 850,
        recipientId: 'svc-1',
        recipientName: 'Luz',
        timestamp: now,
      );
      final alert = engine.evaluate(operation: op, history: history)!;
      expect(alert.triggeredRules, contains(RiskRule.unusualAmount));
    });

    test('high amount but no history returns null (benefit of the doubt)', () {
      final op = OperationContext(
        type: OperationType.payment,
        amount: 5000,
        recipientId: 'svc-1',
        recipientName: 'Luz',
        timestamp: now,
      );
      expect(engine.evaluate(operation: op, history: []), isNull);
    });

    test('only compares same-type operations', () {
      final history = transferHistory(entries: [('Ana', 50), ('Ben', 60)]);
      final op = OperationContext(
        type: OperationType.payment,
        amount: 5000,
        recipientId: 'svc-1',
        recipientName: 'Luz',
        timestamp: now,
      );
      expect(engine.evaluate(operation: op, history: history), isNull);
    });
  });

  group('newRecipient', () {
    test('transfer to new recipient triggers alert', () {
      final history = transferHistory(entries: [('Ana', 100), ('Ben', 200)]);
      final op = OperationContext(
        type: OperationType.transfer,
        amount: 50,
        recipientId: 'new-1',
        recipientName: 'Desconocido',
        timestamp: now,
      );
      final alert = engine.evaluate(operation: op, history: history)!;
      expect(alert.triggeredRules, contains(RiskRule.newRecipient));
    });

    test('transfer to known recipient returns null', () {
      final history = transferHistory(entries: [('Ana', 100), ('Ben', 200)]);
      final op = OperationContext(
        type: OperationType.transfer,
        amount: 50,
        recipientId: 'ana-1',
        recipientName: 'Ana',
        timestamp: now,
      );
      expect(engine.evaluate(operation: op, history: history), isNull);
    });

    test('payment to new service does NOT trigger newRecipient', () {
      final history = paymentHistory(amounts: [100]);
      final op = OperationContext(
        type: OperationType.payment,
        amount: 100,
        recipientId: 'new-svc',
        recipientName: 'Nuevo Servicio',
        timestamp: now,
      );
      expect(engine.evaluate(operation: op, history: history), isNull);
    });
  });

  group('highFrequency', () {
    test('2 ops in 10 min returns null', () {
      final history = [
        Operation(
          id: 'r-1',
          type: OperationType.payment,
          recipientName: 'A',
          amount: 10,
          date: now.subtract(const Duration(minutes: 3)),
          status: OperationStatus.success,
          description: 'Op 1',
        ),
        Operation(
          id: 'r-2',
          type: OperationType.payment,
          recipientName: 'B',
          amount: 10,
          date: now.subtract(const Duration(minutes: 7)),
          status: OperationStatus.success,
          description: 'Op 2',
        ),
      ];
      final op = OperationContext(
        type: OperationType.payment,
        amount: 10,
        recipientId: 'c',
        recipientName: 'C',
        timestamp: now,
      );
      expect(engine.evaluate(operation: op, history: history), isNull);
    });

    test('3 ops in 10 min triggers alert on the 4th', () {
      final history = [
        Operation(
          id: 'r-1',
          type: OperationType.payment,
          recipientName: 'A',
          amount: 10,
          date: now.subtract(const Duration(minutes: 2)),
          status: OperationStatus.success,
          description: 'Op 1',
        ),
        Operation(
          id: 'r-2',
          type: OperationType.payment,
          recipientName: 'B',
          amount: 10,
          date: now.subtract(const Duration(minutes: 5)),
          status: OperationStatus.success,
          description: 'Op 2',
        ),
        Operation(
          id: 'r-3',
          type: OperationType.payment,
          recipientName: 'C',
          amount: 10,
          date: now.subtract(const Duration(minutes: 8)),
          status: OperationStatus.success,
          description: 'Op 3',
        ),
      ];
      final op = OperationContext(
        type: OperationType.payment,
        amount: 10,
        recipientId: 'd',
        recipientName: 'D',
        timestamp: now,
      );
      final alert = engine.evaluate(operation: op, history: history)!;
      expect(alert.triggeredRules, contains(RiskRule.highFrequency));
    });
  });

  group('unusualTime', () {
    test('operation at 3 AM triggers alert', () {
      final op = OperationContext(
        type: OperationType.payment,
        amount: 50,
        recipientId: 'svc-1',
        recipientName: 'Luz',
        timestamp: DateTime(2026, 10, 3, 3),
      );
      final alert = engine.evaluate(operation: op, history: [])!;
      expect(alert.triggeredRules, contains(RiskRule.unusualTime));
    });

    test('operation at 9 AM returns null', () {
      final op = OperationContext(
        type: OperationType.payment,
        amount: 50,
        recipientId: 'svc-1',
        recipientName: 'Luz',
        timestamp: DateTime(2026, 10, 3, 9),
      );
      expect(engine.evaluate(operation: op, history: []), isNull);
    });

    test('operation at 22:00 triggers alert (boundary)', () {
      final op = OperationContext(
        type: OperationType.payment,
        amount: 50,
        recipientId: 'svc-1',
        recipientName: 'Luz',
        timestamp: DateTime(2026, 10, 3, 22),
      );
      final alert = engine.evaluate(operation: op, history: [])!;
      expect(alert.triggeredRules, contains(RiskRule.unusualTime));
    });
  });

  group('combined rules', () {
    test('high amount + new recipient triggers both', () {
      final history = transferHistory(entries: [('Ana', 100), ('Ben', 100)]);
      final op = OperationContext(
        type: OperationType.transfer,
        amount: 500,
        recipientId: 'new-1',
        recipientName: 'Desconocido',
        timestamp: now,
      );
      final alert = engine.evaluate(operation: op, history: history)!;
      expect(
        alert.triggeredRules,
        containsAll([RiskRule.unusualAmount, RiskRule.newRecipient]),
      );
      expect(alert.riskLevel, RiskLevel.high);
    });

    test('all 4 rules can trigger simultaneously', () {
      final recentHistory = [
        for (var i = 0; i < 3; i++)
          Operation(
            id: 'r-$i',
            type: OperationType.transfer,
            recipientName: 'Known $i',
            amount: 50,
            date: now.subtract(Duration(minutes: i + 1)),
            status: OperationStatus.success,
            description: 'Op $i',
          ),
      ];
      final op = OperationContext(
        type: OperationType.transfer,
        amount: 5000,
        recipientId: 'new-1',
        recipientName: 'Stranger',
        timestamp: DateTime(2026, 10, 3, 3),
      );
      final alert = engine.evaluate(operation: op, history: recentHistory)!;
      expect(alert.triggeredRules, hasLength(4));
      expect(alert.riskLevel, RiskLevel.high);
    });
  });

  group('custom thresholds', () {
    test('respects overridden amountMultiplier', () {
      final history = paymentHistory(amounts: [100]);
      final op = OperationContext(
        type: OperationType.payment,
        amount: 140,
        recipientId: 'svc-1',
        recipientName: 'Luz',
        timestamp: now,
      );
      // Default 2x: 140 < 200 → no alert
      expect(engine.evaluate(operation: op, history: history), isNull);

      // Custom 1.3x: 140 > 130 → alert
      final alert = engine.evaluate(
        operation: op,
        history: history,
        thresholds: const RiskThresholds(amountMultiplier: 1.3),
      )!;
      expect(alert.triggeredRules, contains(RiskRule.unusualAmount));
    });

    test('respects overridden safe hours', () {
      final op = OperationContext(
        type: OperationType.payment,
        amount: 50,
        recipientId: 'svc-1',
        recipientName: 'Luz',
        timestamp: DateTime(2026, 10, 3, 20),
      );
      // Default 7-22: 20 is safe
      expect(engine.evaluate(operation: op, history: []), isNull);

      // Custom 9-18: 20 is outside
      final alert = engine.evaluate(
        operation: op,
        history: [],
        thresholds: const RiskThresholds(safeHourStart: 9, safeHourEnd: 18),
      )!;
      expect(alert.triggeredRules, contains(RiskRule.unusualTime));
    });
  });
}
