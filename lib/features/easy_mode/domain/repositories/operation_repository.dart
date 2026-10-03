import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';

/// Contract for operation (payment/transfer) records.
abstract class OperationRepository {
  /// Creates a new operation record. Generates id and date automatically.
  Future<Operation> createOperation({
    required OperationType type,
    required String recipientName,
    required double amount,
    required String description,
  });

  /// Returns all operations, newest first.
  Future<List<Operation>> getOperations();
}
