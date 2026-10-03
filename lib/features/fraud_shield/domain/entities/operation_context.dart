import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:meta/meta.dart';

/// Context of the operation being evaluated by the risk engine.
@immutable
class OperationContext {
  /// Creates an operation context for risk evaluation.
  const OperationContext({
    required this.type,
    required this.amount,
    required this.recipientId,
    required this.recipientName,
    required this.timestamp,
  });

  /// Payment or transfer.
  final OperationType type;

  /// Amount of the operation.
  final double amount;

  /// Unique identifier of the recipient.
  final String recipientId;

  /// Display name of the recipient.
  final String recipientName;

  /// When the operation is being attempted.
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationContext &&
          type == other.type &&
          amount == other.amount &&
          recipientId == other.recipientId &&
          recipientName == other.recipientName &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      Object.hash(type, amount, recipientId, recipientName, timestamp);
}
