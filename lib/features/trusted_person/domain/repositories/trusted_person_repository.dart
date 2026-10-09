import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_person.dart';

/// Repository for managing the trusted person and permissions.
abstract class TrustedPersonRepository {
  /// Returns the registered trusted person, or null if none.
  Future<TrustedPerson?> getTrustedPerson();

  /// Registers a new trusted person. Throws if one already exists.
  Future<TrustedPerson> register({
    required String name,
    required String phone,
    required String relationship,
    required Set<TrustedPermission> initialPermissions,
  });

  /// Updates the active permissions. Creates ConsentRecords for changes.
  Future<TrustedPerson> updatePermissions(Set<TrustedPermission> permissions);

  /// Removes the trusted person and revokes all permissions.
  Future<void> remove();

  /// Whether a specific permission is active. False if no person registered.
  Future<bool> hasPermission(TrustedPermission permission);

  /// Stream of changes to the trusted person.
  Stream<TrustedPerson?> watchTrustedPerson();
}
