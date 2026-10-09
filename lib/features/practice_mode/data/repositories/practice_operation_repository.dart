import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/operation_repository.dart';

class PracticeOperationRepository implements OperationRepository {
  final List<Operation> _ops = [];
  int _counter = 0;

  @override
  Future<Operation> createOperation({
    required OperationType type,
    required String recipientName,
    required double amount,
    required String description,
  }) async {
    _counter++;
    final op = Operation(
      id: 'p-op-$_counter',
      type: type,
      recipientName: recipientName,
      amount: amount,
      date: DateTime.now(),
      status: OperationStatus.success,
      description: description,
    );
    _ops.insert(0, op);
    return op;
  }

  @override
  Future<List<Operation>> getOperations() async => List.unmodifiable(_ops);

  void reset() {
    _ops.clear();
    _counter = 0;
  }
}
