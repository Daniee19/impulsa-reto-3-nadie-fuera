import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/entities/reminder_config.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/services/reminder_generator.dart';

void main() {
  late ReminderGenerator generator;

  setUp(() => generator = ReminderGenerator());

  Bill makeBill(
    String id, {
    required DateTime dueDate,
    BillStatus status = BillStatus.pending,
    String service = 'Luz',
    double amount = 85,
  }) {
    return Bill(
      id: id,
      serviceName: service,
      providerName: 'Enel',
      amount: amount,
      dueDate: dueDate,
      status: status,
    );
  }

  ReminderConfig makeConfig({
    Set<String> enabled = const {'b1'},
    AnticipationDays anticipation = AnticipationDays.three,
  }) {
    return ReminderConfig(
      enabledBillIds: enabled,
      anticipationDays: anticipation,
    );
  }

  final now = DateTime(2026, 10, 9);

  test('bill due in 2 days with anticipation=3 generates', () {
    final bill = makeBill('b1', dueDate: DateTime(2026, 10, 11));
    final result = generator.generate(
      bills: [bill],
      config: makeConfig(),
      now: now,
      dismissedBillIds: {},
    );
    expect(result, hasLength(1));
    expect(result.first.isOverdue, isFalse);
    expect(result.first.message, contains('Luz'));
  });

  test('bill due in 4 days with anticipation=3 → no reminder', () {
    final bill = makeBill('b1', dueDate: DateTime(2026, 10, 13));
    final result = generator.generate(
      bills: [bill],
      config: makeConfig(),
      now: now,
      dismissedBillIds: {},
    );
    expect(result, isEmpty);
  });

  test('bill due yesterday → isOverdue true', () {
    final bill = makeBill('b1', dueDate: DateTime(2026, 10, 8));
    final result = generator.generate(
      bills: [bill],
      config: makeConfig(),
      now: now,
      dismissedBillIds: {},
    );
    expect(result, hasLength(1));
    expect(result.first.isOverdue, isTrue);
    expect(result.first.message, contains('venció ayer'));
  });

  test('bill due 4 days ago → no reminder (outside window)', () {
    final bill = makeBill('b1', dueDate: DateTime(2026, 10, 5));
    final result = generator.generate(
      bills: [bill],
      config: makeConfig(),
      now: now,
      dismissedBillIds: {},
    );
    expect(result, isEmpty);
  });

  test('disabled bill → no reminder', () {
    final bill = makeBill('b1', dueDate: DateTime(2026, 10, 10));
    final result = generator.generate(
      bills: [bill],
      config: makeConfig(enabled: {'other'}),
      now: now,
      dismissedBillIds: {},
    );
    expect(result, isEmpty);
  });

  test('dismissed bill → no reminder', () {
    final bill = makeBill('b1', dueDate: DateTime(2026, 10, 10));
    final result = generator.generate(
      bills: [bill],
      config: makeConfig(),
      now: now,
      dismissedBillIds: {'b1'},
    );
    expect(result, isEmpty);
  });

  test('paid bill → no reminder', () {
    final bill = makeBill(
      'b1',
      dueDate: DateTime(2026, 10, 10),
      status: BillStatus.paid,
    );
    final result = generator.generate(
      bills: [bill],
      config: makeConfig(),
      now: now,
      dismissedBillIds: {},
    );
    expect(result, isEmpty);
  });

  test('multiple bills sorted by dueDate', () {
    final bills = [
      makeBill('b1', dueDate: DateTime(2026, 10, 11)),
      makeBill('b2', dueDate: DateTime(2026, 10, 9), service: 'Agua'),
      makeBill('b3', dueDate: DateTime(2026, 10, 10), service: 'Gas'),
    ];
    final result = generator.generate(
      bills: bills,
      config: makeConfig(enabled: {'b1', 'b2', 'b3'}),
      now: now,
      dismissedBillIds: {},
    );
    expect(result, hasLength(3));
    expect(result[0].billId, 'b2');
    expect(result[1].billId, 'b3');
    expect(result[2].billId, 'b1');
  });

  test('natural language: hoy, mañana, weekday', () {
    final today = makeBill('b1', dueDate: DateTime(2026, 10, 9));
    final tomorrow = makeBill(
      'b2',
      dueDate: DateTime(2026, 10, 10),
      service: 'Agua',
    );
    // Oct 12 2026 is a Monday
    final weekday = makeBill(
      'b3',
      dueDate: DateTime(2026, 10, 12),
      service: 'Gas',
    );
    final result = generator.generate(
      bills: [today, tomorrow, weekday],
      config: makeConfig(enabled: {'b1', 'b2', 'b3'}),
      now: now,
      dismissedBillIds: {},
    );
    expect(result[0].message, contains('vence hoy'));
    expect(result[1].message, contains('vence mañana'));
    expect(result[2].message, contains('vence el lunes'));
  });

  test('overdue uses past tense', () {
    // Oct 7 2026 is a Wednesday
    final bill = makeBill('b1', dueDate: DateTime(2026, 10, 7));
    final result = generator.generate(
      bills: [bill],
      config: makeConfig(),
      now: now,
      dismissedBillIds: {},
    );
    expect(result.first.isOverdue, isTrue);
    expect(result.first.message, contains('venció el miércoles'));
  });
}
