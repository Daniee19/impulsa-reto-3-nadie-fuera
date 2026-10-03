import 'package:meta/meta.dart';

/// Permissions that a trusted person can have.
enum TrustedPermission {
  /// Can receive security alert notifications.
  securityAlerts,
}

/// Stub entity for the trusted person (006-trusted-person dependency).
@immutable
class TrustedPerson {
  /// Creates a trusted person.
  const TrustedPerson({required this.name, required this.relationship});

  /// Display name of the trusted person.
  final String name;

  /// Relationship to the user (e.g. "Hija", "Hijo").
  final String relationship;

  /// Returns whether this person has the given permission.
  bool hasPermission(TrustedPermission permission) => true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrustedPerson &&
          name == other.name &&
          relationship == other.relationship;

  @override
  int get hashCode => Object.hash(name, relationship);
}
