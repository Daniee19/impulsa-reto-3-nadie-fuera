import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:meta/meta.dart';

/// Snapshot of the operation the user is currently performing.
@immutable
class OperationInProgress {
  /// Creates an operation snapshot.
  const OperationInProgress({
    required this.type,
    required this.amount,
    required this.recipientName,
    required this.recipientId,
  });

  /// Payment or transfer.
  final OperationType type;

  /// Amount in soles.
  final double amount;

  /// Display name of recipient.
  final String recipientName;

  /// ID of the bill or contact.
  final String recipientId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationInProgress &&
          type == other.type &&
          amount == other.amount &&
          recipientName == other.recipientName &&
          recipientId == other.recipientId;

  @override
  int get hashCode => Object.hash(type, amount, recipientName, recipientId);
}
