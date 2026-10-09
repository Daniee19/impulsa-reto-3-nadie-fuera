import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/data/repositories/secure_storage_trusted_person_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_person.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/repositories/trusted_person_repository.dart';

/// Provides the TrustedPersonRepository implementation.
final trustedPersonRepositoryProvider = Provider<TrustedPersonRepository>(
  (ref) => SecureStorageTrustedPersonRepository(),
);

/// Reactive stream of the current trusted person (null if none registered).
final trustedPersonProvider = StreamProvider<TrustedPerson?>((ref) {
  final repo = ref.watch(trustedPersonRepositoryProvider);
  return repo.watchTrustedPerson();
});
