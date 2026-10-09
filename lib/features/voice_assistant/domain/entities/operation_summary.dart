import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:meta/meta.dart';

/// Summary built from real repository data, ready for TTS and confirmation.
@immutable
class OperationSummary {
  /// Creates an operation summary.
  const OperationSummary({
    required this.type,
    required this.amount,
    required this.recipientName,
    required this.recipientId,
    required this.spokenSummary,
  });

  /// Payment or transfer.
  final OperationType type;

  /// Real amount from repository (NEVER from parser).
  final double amount;

  /// Real recipient name from repository (NEVER from parser).
  final String recipientName;

  /// ID of the bill or contact.
  final String recipientId;

  /// Text to read aloud via TTS (from ARB, ≤15 words).
  final String spokenSummary;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationSummary &&
          type == other.type &&
          amount == other.amount &&
          recipientName == other.recipientName &&
          recipientId == other.recipientId;

  @override
  int get hashCode => Object.hash(type, amount, recipientName, recipientId);
}
