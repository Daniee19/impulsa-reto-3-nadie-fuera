import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/trusted_person_register_screen.dart';

Widget _wrap() {
  return const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale('es'),
    home: TrustedPersonRegisterScreen(),
  );
}

void main() {
  group('TrustedPersonRegisterScreen', () {
    testWidgets('rejects empty name', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '912345678');
      await tester.enterText(find.byType(TextFormField).at(2), 'Hija');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.textContaining('Nombre'), findsWidgets);
    });

    testWidgets('rejects invalid phone (too short)', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Val');
      await tester.enterText(find.byType(TextFormField).at(1), '9123');
      await tester.enterText(find.byType(TextFormField).at(2), 'Hija');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Ingresa 9 dígitos que empiecen con 9'), findsOneWidget);
    });

    testWidgets('rejects phone not starting with 9', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Val');
      await tester.enterText(find.byType(TextFormField).at(1), '112345678');
      await tester.enterText(find.byType(TextFormField).at(2), 'Hija');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Ingresa 9 dígitos que empiecen con 9'), findsOneWidget);
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
