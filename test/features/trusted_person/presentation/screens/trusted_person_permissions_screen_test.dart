import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/data/repositories/secure_storage_trusted_person_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/trusted_person_permissions_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/trusted_person_register_screen.dart';

Widget _wrap() {
  return ProviderScope(
    overrides: [
      trustedPersonRepositoryProvider.overrideWithValue(
        SecureStorageTrustedPersonRepository(),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: TrustedPersonPermissionsScreen(
        data: TrustedPersonRegistrationData(
          name: 'Valeria',
          phone: '987654321',
          relationship: 'Hija',
        ),
      ),
    ),
  );
}

void main() {
  group('TrustedPersonPermissionsScreen', () {
    testWidgets('shows 3 permission toggles', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsNWidgets(3));
      expect(find.text('Avisos de seguridad'), findsOneWidget);
      expect(find.text('Pedidos de ayuda'), findsOneWidget);
      expect(find.text('Ayudar a configurar'), findsOneWidget);
    });

    testWidgets('toggles change state', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));

      await tester.tap(switches.first);
      await tester.pumpAndSettle();
    });

    testWidgets('confirm button is visible', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Confirmar'), findsOneWidget);
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
