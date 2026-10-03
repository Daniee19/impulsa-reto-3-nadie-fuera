import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/account.dart';

/// Contract for account data access.
abstract class AccountRepository {
  /// Returns the current user's account.
  Future<Account> getAccount();

  /// Updates the available balance. Throws if [newBalance] < 0.
  Future<Account> updateBalance(String accountId, double newBalance);
}
