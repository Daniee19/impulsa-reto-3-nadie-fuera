import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:meta/meta.dart';

@immutable
class Reminder {
  const Reminder({
    required this.bill,
    required this.message,
    required this.isOverdue,
  });

  final Bill bill;
  final String message;
  final bool isOverdue;

  String get billId => bill.id;
  DateTime get dueDate => bill.dueDate;
  double get amount => bill.amount;
  String get serviceName => bill.serviceName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Reminder && billId == other.billId;

  @override
  int get hashCode => billId.hashCode;
}
