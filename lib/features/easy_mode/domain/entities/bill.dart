import 'package:meta/meta.dart';

/// Status of a service bill.
enum BillStatus {
  /// Not yet paid.
  pending,

  /// Already paid.
  paid,
}

/// Pending service bill (e.g. electricity, water).
@immutable
class Bill {
  /// Creates a bill.
  const Bill({
    required this.id,
    required this.serviceName,
    required this.providerName,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  /// Unique identifier.
  final String id;

  /// Service name (e.g. "Luz"), max 15 chars.
  final String serviceName;

  /// Provider name (e.g. "Enel").
  final String providerName;

  /// Amount to pay, must be > 0.
  final double amount;

  /// Due date.
  final DateTime dueDate;

  /// Payment status.
  final BillStatus status;

  /// Returns a copy with the given fields replaced.
  Bill copyWith({
    String? id,
    String? serviceName,
    String? providerName,
    double? amount,
    DateTime? dueDate,
    BillStatus? status,
  }) {
    return Bill(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      providerName: providerName ?? this.providerName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bill &&
          id == other.id &&
          serviceName == other.serviceName &&
          providerName == other.providerName &&
          amount == other.amount &&
          dueDate == other.dueDate &&
          status == other.status;

  @override
  int get hashCode =>
      Object.hash(id, serviceName, providerName, amount, dueDate, status);
}
