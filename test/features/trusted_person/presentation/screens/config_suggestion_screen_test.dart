import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/config_suggestion.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_person.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/config_suggestion_screen.dart';

final _suggestion = ConfigSuggestion(
  id: 'cs-1',
  type: ConfigSuggestionType.fontSize,
  description: 'Hacer la letra más grande',
  suggestedValue: 'large',
  status: ConfigSuggestionStatus.pending,
  createdAt: DateTime(2026, 10),
);

final _person = TrustedPerson(
  id: 'tp-1',
  name: 'Valeria',
  phone: '987654321',
  relationship: 'Hija',
  permissions: const {TrustedPermission.configHelp},
  consentHistory: const [],
  registeredAt: DateTime(2026, 10),
);

Widget _wrap() {
  return ProviderScope(
    overrides: [
      trustedPersonProvider.overrideWith((ref) => Stream.value(_person)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: ConfigSuggestionScreen(suggestion: _suggestion),
    ),
  );
}

void main() {
  group('ConfigSuggestionScreen', () {
    testWidgets('displays suggestion description', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Hacer la letra más grande'), findsOneWidget);
    });

    testWidgets('shows accept and reject buttons', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Aceptar'), findsOneWidget);
      expect(find.text('No, gracias'), findsOneWidget);
    });

    testWidgets('meets a11y tap target guidelines', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('meets labeled tap target guidelines', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
