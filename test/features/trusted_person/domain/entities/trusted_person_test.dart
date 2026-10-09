import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/consent_record.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_person.dart';

TrustedPerson _person({
  Set<TrustedPermission> permissions = const {TrustedPermission.securityAlerts},
}) => TrustedPerson(
  id: 'tp-1',
  name: 'Valeria',
  phone: '987654321',
  relationship: 'Hija',
  permissions: permissions,
  consentHistory: const [],
  registeredAt: DateTime(2026, 10),
);

void main() {
  group('TrustedPerson', () {
    test('construction with valid fields', () {
      final p = _person();
      expect(p.id, 'tp-1');
      expect(p.name, 'Valeria');
      expect(p.phone, '987654321');
      expect(p.relationship, 'Hija');
    });

    test('hasPermission returns true for active', () {
      final p = _person(permissions: {TrustedPermission.securityAlerts});
      expect(p.hasPermission(TrustedPermission.securityAlerts), isTrue);
    });

    test('hasPermission returns false for inactive', () {
      final p = _person(permissions: {TrustedPermission.securityAlerts});
      expect(p.hasPermission(TrustedPermission.helpRequests), isFalse);
    });

    test('copyWith preserves other fields', () {
      final p = _person();
      final updated = p.copyWith(permissions: {TrustedPermission.configHelp});
      expect(updated.id, p.id);
      expect(updated.name, p.name);
      expect(updated.phone, p.phone);
      expect(updated.permissions, {TrustedPermission.configHelp});
    });

    test('equality and hashCode', () {
      final a = _person();
      final b = _person();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different id', () {
      final a = _person();
      final b = TrustedPerson(
        id: 'tp-2',
        name: 'Valeria',
        phone: '987654321',
        relationship: 'Hija',
        permissions: const {TrustedPermission.securityAlerts},
        consentHistory: const [],
        registeredAt: DateTime(2026, 10),
      );
      expect(a, isNot(equals(b)));
    });

    test('toJson and fromJson roundtrip', () {
      final consent = ConsentRecord(
        permission: TrustedPermission.securityAlerts,
        action: ConsentAction.granted,
        timestamp: DateTime.utc(2026, 10),
      );
      final p = TrustedPerson(
        id: 'tp-1',
        name: 'Rosa',
        phone: '912345678',
        relationship: 'Madre',
        permissions: const {
          TrustedPermission.securityAlerts,
          TrustedPermission.helpRequests,
        },
        consentHistory: [consent],
        registeredAt: DateTime.utc(2026, 10),
      );
      final json = p.toJson();
      final restored = TrustedPerson.fromJson(json);
      expect(restored.id, p.id);
      expect(restored.name, p.name);
      expect(restored.phone, p.phone);
      expect(restored.permissions, p.permissions);
      expect(restored.consentHistory.length, 1);
    });
  });
}
