import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/account.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/account_repository.dart';

/// Provider for the account repository implementation.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => throw UnimplementedError('Override with mock or real repo'),
);

/// Provider that fetches the current user account.
final accountProvider = FutureProvider<Account>((ref) {
  return ref.watch(accountRepositoryProvider).getAccount();
});
