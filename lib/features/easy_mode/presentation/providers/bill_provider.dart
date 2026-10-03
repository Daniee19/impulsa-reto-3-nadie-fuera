import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/bill_repository.dart';

/// Provider for the bill repository implementation.
final billRepositoryProvider = Provider<BillRepository>(
  (ref) => throw UnimplementedError('Override with mock or real repo'),
);

/// Provider that fetches pending bills.
final pendingBillsProvider = FutureProvider<List<Bill>>((ref) {
  return ref.watch(billRepositoryProvider).getBills(
    status: BillStatus.pending,
  );
});
