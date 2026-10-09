import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/bill_repository.dart';

class PracticeBillRepository implements BillRepository {
  List<Bill> _bills = _initialBills();

  static List<Bill> _initialBills() => [
    Bill(
      id: 'p-bill-1',
      serviceName: 'Luz',
      providerName: 'Enel Práctica',
      amount: 95.0,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      status: BillStatus.pending,
    ),
    Bill(
      id: 'p-bill-2',
      serviceName: 'Agua',
      providerName: 'Sedapal Práctica',
      amount: 38.0,
      dueDate: DateTime.now().add(const Duration(days: 10)),
      status: BillStatus.pending,
    ),
    Bill(
      id: 'p-bill-3',
      serviceName: 'Teléfono',
      providerName: 'Movistar Práctica',
      amount: 55.0,
      dueDate: DateTime.now().add(const Duration(days: 15)),
      status: BillStatus.pending,
    ),
  ];

  @override
  Future<List<Bill>> getBills({BillStatus? status}) async {
    if (status == null) return List.unmodifiable(_bills);
    return _bills.where((b) => b.status == status).toList();
  }

  @override
  Future<Bill> getBillById(String billId) async {
    return _bills.firstWhere((b) => b.id == billId);
  }

  @override
  Future<Bill> payBill(String billId) async {
    final index = _bills.indexWhere((b) => b.id == billId);
    if (index == -1) throw StateError('Bill not found: $billId');
    if (_bills[index].status == BillStatus.paid) {
      throw StateError('Bill already paid: $billId');
    }
    final paid = _bills[index].copyWith(status: BillStatus.paid);
    _bills = List.of(_bills)..[index] = paid;
    return paid;
  }

  void reset() => _bills = _initialBills();
}
