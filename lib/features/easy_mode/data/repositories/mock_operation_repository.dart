import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/operation_repository.dart';

/// In-memory mock of [OperationRepository] with simulated latency.
class MockOperationRepository implements OperationRepository {
  final List<Operation> _operations = [
    // Historical payments (last 30 days) for risk engine baseline
    Operation(
      id: 'hist-001',
      type: OperationType.payment,
      recipientName: 'Luz - Enel',
      amount: 95.50,
      date: DateTime.now().subtract(const Duration(days: 28)),
      status: OperationStatus.success,
      description: 'Pago de Luz',
    ),
    Operation(
      id: 'hist-002',
      type: OperationType.payment,
      recipientName: 'Agua - Sedapal',
      amount: 42,
      date: DateTime.now().subtract(const Duration(days: 25)),
      status: OperationStatus.success,
      description: 'Pago de Agua',
    ),
    Operation(
      id: 'hist-003',
      type: OperationType.payment,
      recipientName: 'Gas - Cálidda',
      amount: 63.20,
      date: DateTime.now().subtract(const Duration(days: 22)),
      status: OperationStatus.success,
      description: 'Pago de Gas',
    ),
    Operation(
      id: 'hist-004',
      type: OperationType.payment,
      recipientName: 'Luz - Enel',
      amount: 102.30,
      date: DateTime.now().subtract(const Duration(days: 18)),
      status: OperationStatus.success,
      description: 'Pago de Luz',
    ),
    Operation(
      id: 'hist-005',
      type: OperationType.payment,
      recipientName: 'Agua - Sedapal',
      amount: 45,
      date: DateTime.now().subtract(const Duration(days: 15)),
      status: OperationStatus.success,
      description: 'Pago de Agua',
    ),
    Operation(
      id: 'hist-006',
      type: OperationType.payment,
      recipientName: 'Gas - Cálidda',
      amount: 58.90,
      date: DateTime.now().subtract(const Duration(days: 12)),
      status: OperationStatus.success,
      description: 'Pago de Gas',
    ),
    Operation(
      id: 'hist-007',
      type: OperationType.payment,
      recipientName: 'Luz - Enel',
      amount: 88.70,
      date: DateTime.now().subtract(const Duration(days: 9)),
      status: OperationStatus.success,
      description: 'Pago de Luz',
    ),
    Operation(
      id: 'hist-008',
      type: OperationType.payment,
      recipientName: 'Agua - Sedapal',
      amount: 40.50,
      date: DateTime.now().subtract(const Duration(days: 7)),
      status: OperationStatus.success,
      description: 'Pago de Agua',
    ),
    Operation(
      id: 'hist-009',
      type: OperationType.payment,
      recipientName: 'Gas - Cálidda',
      amount: 130,
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: OperationStatus.success,
      description: 'Pago de Gas',
    ),
    Operation(
      id: 'hist-010',
      type: OperationType.payment,
      recipientName: 'Luz - Enel',
      amount: 110.20,
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: OperationStatus.success,
      description: 'Pago de Luz',
    ),
    // Historical transfers to known contacts
    Operation(
      id: 'hist-011',
      type: OperationType.transfer,
      recipientName: 'Valeria Martínez',
      amount: 150,
      date: DateTime.now().subtract(const Duration(days: 20)),
      status: OperationStatus.success,
      description: 'Envío a Valeria Martínez',
    ),
    Operation(
      id: 'hist-012',
      type: OperationType.transfer,
      recipientName: 'Carlos López',
      amount: 80,
      date: DateTime.now().subtract(const Duration(days: 16)),
      status: OperationStatus.success,
      description: 'Envío a Carlos López',
    ),
    Operation(
      id: 'hist-013',
      type: OperationType.transfer,
      recipientName: 'María Sánchez',
      amount: 200,
      date: DateTime.now().subtract(const Duration(days: 11)),
      status: OperationStatus.success,
      description: 'Envío a María Sánchez',
    ),
    Operation(
      id: 'hist-014',
      type: OperationType.transfer,
      recipientName: 'Valeria Martínez',
      amount: 50,
      date: DateTime.now().subtract(const Duration(days: 6)),
      status: OperationStatus.success,
      description: 'Envío a Valeria Martínez',
    ),
    Operation(
      id: 'hist-015',
      type: OperationType.transfer,
      recipientName: 'Carlos López',
      amount: 120,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: OperationStatus.success,
      description: 'Envío a Carlos López',
    ),
  ];

  @override
  Future<Operation> createOperation({
    required OperationType type,
    required String recipientName,
    required double amount,
    required String description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final op = Operation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      recipientName: recipientName,
      amount: amount,
      date: DateTime.now(),
      status: OperationStatus.success,
      description: description,
    );
    _operations.add(op);
    return op;
  }

  @override
  Future<List<Operation>> getOperations() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _operations.toList()..sort((a, b) => b.date.compareTo(a.date));
  }
}
