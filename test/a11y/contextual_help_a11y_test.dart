import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/screens/help_contact_picker_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/widgets/help_fab.dart';
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

Widget _wrap(Widget child, {TrustedPerson? trustedPerson}) {
  final person = trustedPerson ?? _testPerson();
  return ProviderScope(
    overrides: [
      trustedPersonProvider.overrideWith((ref) => Stream.value(person)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: child,
    ),
  );
}

void main() {
  group('Contextual Help A11y', () {
    testWidgets('contact picker meets a11y guidelines', (tester) async {
      await tester.pumpWidget(_wrap(const HelpContactPickerScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('help fab has descriptive label', (tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(floatingActionButton: HelpFab())),
      );
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(HelpFab));
      expect(semantics.label, contains('ayuda'));
    });
  });
}
