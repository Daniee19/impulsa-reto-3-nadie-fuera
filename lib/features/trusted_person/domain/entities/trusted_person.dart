import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/consent_record.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:meta/meta.dart';

/// A trusted person registered by the user.
@immutable
class TrustedPerson {
  /// Creates a trusted person.
  const TrustedPerson({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.permissions,
    required this.consentHistory,
    required this.registeredAt,
  });

  /// Creates from JSON map.
  factory TrustedPerson.fromJson(Map<String, dynamic> json) {
    return TrustedPerson(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      relationship: json['relationship'] as String,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => TrustedPermission.values.byName(e as String))
          .toSet(),
      consentHistory: (json['consentHistory'] as List<dynamic>)
          .map((e) => ConsentRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      registeredAt: DateTime.parse(json['registeredAt'] as String),
    );
  }

  /// Unique identifier (UUID).
  final String id;

  /// Full name (≤100 chars).
  final String name;

  /// Phone number (9 digits, starts with 9).
  final String phone;

  /// Relationship to the user (e.g. "Hija").
  final String relationship;

  /// Active permissions.
  final Set<TrustedPermission> permissions;

  /// Append-only history of consent grants and revocations.
  final List<ConsentRecord> consentHistory;

  /// When this person was registered.
  final DateTime registeredAt;

  /// Whether this person has the given [permission] active.
  bool hasPermission(TrustedPermission permission) =>
      permissions.contains(permission);

  /// Returns a copy with the given fields replaced.
  TrustedPerson copyWith({
    Set<TrustedPermission>? permissions,
    List<ConsentRecord>? consentHistory,
  }) {
    return TrustedPerson(
      id: id,
      name: name,
      phone: phone,
      relationship: relationship,
      permissions: permissions ?? this.permissions,
      consentHistory: consentHistory ?? this.consentHistory,
      registeredAt: registeredAt,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'relationship': relationship,
    'permissions': permissions.map((p) => p.name).toList(),
    'consentHistory': consentHistory.map((c) => c.toJson()).toList(),
    'registeredAt': registeredAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrustedPerson &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          relationship == other.relationship;

  @override
  int get hashCode => Object.hash(id, name, phone, relationship);
}
