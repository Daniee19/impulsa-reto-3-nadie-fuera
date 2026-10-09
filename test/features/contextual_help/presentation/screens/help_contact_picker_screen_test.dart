import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/screens/help_contact_picker_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_person.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

TrustedPerson _testPerson() => TrustedPerson(
  id: 'tp-1',
  name: 'Valeria',
  phone: '987654321',
  relationship: 'Hija',
  permissions: const {
    TrustedPermission.securityAlerts,
    TrustedPermission.helpRequests,
  },
  consentHistory: const [],
  registeredAt: DateTime(2026, 10),
);

Widget buildTestWidget({TrustedPerson? trustedPerson}) {
  return ProviderScope(
    overrides: [
      trustedPersonProvider.overrideWith(
        (ref) => Stream.value(trustedPerson),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: HelpContactPickerScreen(),
    ),
  );
}

void main() {
  group('HelpContactPickerScreen', () {
    testWidgets('shows 2 options with trusted person who has helpRequests', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(trustedPerson: _testPerson()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Valeria'), findsOneWidget);
      expect(find.textContaining('banco'), findsOneWidget);
    });

    testWidgets('shows only bank option when trustedPerson is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Valeria'), findsNothing);
      expect(find.textContaining('banco'), findsOneWidget);
    });

    testWidgets('meets a11y tap target guidelines', (tester) async {
      await tester.pumpWidget(buildTestWidget(trustedPerson: _testPerson()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('meets labeled tap target guidelines', (tester) async {
      await tester.pumpWidget(buildTestWidget(trustedPerson: _testPerson()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
