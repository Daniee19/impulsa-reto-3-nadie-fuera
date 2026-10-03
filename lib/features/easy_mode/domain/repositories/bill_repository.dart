import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';

/// Contract for bill data access.
abstract class BillRepository {
  /// Lists bills, optionally filtered by [status].
  Future<List<Bill>> getBills({BillStatus? status});

  /// Returns a single bill by [billId].
  Future<Bill> getBillById(String billId);

  /// Marks a bill as paid. Throws if already paid.
  Future<Bill> payBill(String billId);
}
