import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/account.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/account_repository.dart';

class PracticeAccountRepository implements AccountRepository {
  Account _account = const Account(
    id: 'practice-account',
    holderName: 'Cuenta de práctica',
    maskedNumber: '****0000',
    availableBalance: 5000.0,
  );

  @override
  Future<Account> getAccount() async => _account;

  @override
  Future<Account> updateBalance(String accountId, double newBalance) async {
    if (newBalance < 0) throw ArgumentError('Balance cannot be negative');
    _account = _account.copyWith(availableBalance: newBalance);
    return _account;
  }

  void reset() {
    _account = const Account(
      id: 'practice-account',
      holderName: 'Cuenta de práctica',
      maskedNumber: '****0000',
      availableBalance: 5000.0,
    );
  }
}
