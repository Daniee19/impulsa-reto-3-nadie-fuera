import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/screens/help_channel_picker_screen.dart';
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

Widget buildTestWidget({
  required HelpTarget target,
  TrustedPerson? trustedPerson,
  bool usePerson = true,
}) {
  final person = usePerson ? (trustedPerson ?? _testPerson()) : null;
  return ProviderScope(
    overrides: [
      trustedPersonProvider.overrideWith(
        (ref) => Stream.value(person),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: HelpChannelPickerScreen(target: target),
    ),
  );
}

void main() {
  group('HelpChannelPickerScreen', () {
    testWidgets('shows 2 channels for trusted person', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(target: HelpTarget.trustedPerson),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsNothing);
    });

    testWidgets('shows 3 channels for bank advisor', (tester) async {
      await tester.pumpWidget(buildTestWidget(target: HelpTarget.bankAdvisor));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('video option text includes interpreter', (tester) async {
      await tester.pumpWidget(buildTestWidget(target: HelpTarget.bankAdvisor));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('intérprete de lengua de señas'),
        findsOneWidget,
      );
    });

    testWidgets('meets a11y tap target guidelines', (tester) async {
      await tester.pumpWidget(buildTestWidget(target: HelpTarget.bankAdvisor));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('meets labeled tap target guidelines', (tester) async {
      await tester.pumpWidget(buildTestWidget(target: HelpTarget.bankAdvisor));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
