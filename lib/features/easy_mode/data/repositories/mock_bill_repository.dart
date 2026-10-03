import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/bill_repository.dart';

/// In-memory mock of [BillRepository] with simulated latency.
class MockBillRepository implements BillRepository {
  final List<Bill> _bills = [
    Bill(
      id: 'bill-001',
      serviceName: 'Luz',
      providerName: 'Enel',
      amount: 85.5,
      dueDate: DateTime(2026, 10, 15),
      status: BillStatus.pending,
    ),
    Bill(
      id: 'bill-002',
      serviceName: 'Agua',
      providerName: 'Sedapal',
      amount: 42,
      dueDate: DateTime(2026, 10, 20),
      status: BillStatus.pending,
    ),
    Bill(
      id: 'bill-003',
      serviceName: 'Gas',
      providerName: 'Cálidda',
      amount: 63.2,
      dueDate: DateTime(2026, 10, 25),
      status: BillStatus.pending,
    ),
  ];

  @override
  Future<List<Bill>> getBills({BillStatus? status}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (status == null) return List.unmodifiable(_bills);
    return _bills.where((b) => b.status == status).toList();
  }

  @override
  Future<Bill> getBillById(String billId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _bills.firstWhere(
      (b) => b.id == billId,
      orElse: () => throw StateError('Bill $billId not found'),
    );
  }

  @override
  Future<Bill> payBill(String billId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _bills.indexWhere((b) => b.id == billId);
    if (index == -1) throw StateError('Bill $billId not found');
    if (_bills[index].status == BillStatus.paid) {
      throw StateError('Bill $billId is already paid');
    }
    _bills[index] = _bills[index].copyWith(status: BillStatus.paid);
    return _bills[index];
  }
}
