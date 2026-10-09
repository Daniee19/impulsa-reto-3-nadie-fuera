import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/config_suggestion.dart';

ConfigSuggestion _suggestion({
  ConfigSuggestionStatus status = ConfigSuggestionStatus.pending,
  DateTime? resolvedAt,
}) => ConfigSuggestion(
  id: 'cs-1',
  type: ConfigSuggestionType.fontSize,
  description: 'Hacer la letra más grande',
  suggestedValue: 'large',
  status: status,
  createdAt: DateTime(2026, 10),
  resolvedAt: resolvedAt,
);

void main() {
  group('ConfigSuggestion', () {
    test('construction with valid fields', () {
      final s = _suggestion();
      expect(s.id, 'cs-1');
      expect(s.type, ConfigSuggestionType.fontSize);
      expect(s.status, ConfigSuggestionStatus.pending);
      expect(s.resolvedAt, isNull);
    });

    test('pending to accepted via copyWith', () {
      final now = DateTime(2026, 10, 2);
      final accepted = _suggestion().copyWith(
        status: ConfigSuggestionStatus.accepted,
        resolvedAt: now,
      );
      expect(accepted.status, ConfigSuggestionStatus.accepted);
      expect(accepted.resolvedAt, now);
    });

    test('pending to rejected via copyWith', () {
      final now = DateTime(2026, 10, 2);
      final rejected = _suggestion().copyWith(
        status: ConfigSuggestionStatus.rejected,
        resolvedAt: now,
      );
      expect(rejected.status, ConfigSuggestionStatus.rejected);
      expect(rejected.resolvedAt, now);
    });

    test('resolvedAt is null when pending', () {
      expect(_suggestion().resolvedAt, isNull);
    });

    test('equality', () {
      final a = _suggestion();
      final b = _suggestion();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toJson and fromJson roundtrip', () {
      final s = _suggestion();
      final restored = ConfigSuggestion.fromJson(s.toJson());
      expect(restored, equals(s));
    });
  });
}
