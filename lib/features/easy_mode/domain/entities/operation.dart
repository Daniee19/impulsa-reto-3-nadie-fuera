import 'package:meta/meta.dart';

/// Type of monetary operation.
enum OperationType {
  /// Bill payment.
  payment,

  /// Money transfer to contact.
  transfer,
}

/// Final status of a completed operation.
enum OperationStatus {
  /// Completed successfully.
  success,

  /// Failed to complete.
  failed,
}

/// Record of a completed payment or transfer.
@immutable
class Operation {
  /// Creates an operation.
  const Operation({
    required this.id,
    required this.type,
    required this.recipientName,
    required this.amount,
    required this.date,
    required this.status,
    required this.description,
  });

  /// Unique identifier.
  final String id;

  /// Payment or transfer.
  final OperationType type;

  /// Recipient name.
  final String recipientName;

  /// Amount, must be > 0.
  final double amount;

  /// Date and time of the operation.
  final DateTime date;

  /// Final status (no transitions).
  final OperationStatus status;

  /// Human-readable description.
  final String description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Operation &&
          id == other.id &&
          type == other.type &&
          recipientName == other.recipientName &&
          amount == other.amount &&
          date == other.date &&
          status == other.status &&
          description == other.description;

  @override
  int get hashCode => Object.hash(
        id,
        type,
        recipientName,
        amount,
        date,
        status,
        description,
      );
}
