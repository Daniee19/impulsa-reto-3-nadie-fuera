import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/account.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/account_repository.dart';

/// In-memory mock of [AccountRepository] with simulated latency.
class MockAccountRepository implements AccountRepository {
  Account _account = const Account(
    id: 'acc-001',
    holderName: 'Rosa Martínez',
    maskedNumber: '****5678',
    availableBalance: 2450,
  );

  @override
  Future<Account> getAccount() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _account;
  }

  @override
  Future<Account> updateBalance(String accountId, double newBalance) async {
    if (newBalance < 0) {
      throw ArgumentError.value(newBalance, 'newBalance', 'must be >= 0');
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _account = _account.copyWith(availableBalance: newBalance);
  }
}
