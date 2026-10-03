import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_alert.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/trusted_person.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/fraud_alert_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/trusted_person_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/screens/fraud_alert_screen.dart';

Widget buildTestWidget({
  required FraudAlertState alertState,
  TrustedPerson? trustedPerson = const TrustedPerson(
    name: 'Valeria',
    relationship: 'Hija',
  ),
}) {
  return ProviderScope(
    overrides: [
      fraudAlertProvider.overrideWith((ref) {
        return FraudAlertNotifier()..setAlert(
          alertState.alert,
          alertState.continueRoute,
          alertState.continueExtra,
        );
      }),
      trustedPersonProvider.overrideWithValue(trustedPerson),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: FraudAlertScreen(),
    ),
  );
}

final testAlert = RiskAlert(
  triggeredRules: const {RiskRule.unusualAmount},
  operation: OperationContext(
    type: OperationType.payment,
    amount: 850,
    recipientId: 'svc-1',
    recipientName: 'Luz - Enel',
    timestamp: DateTime(2026, 10, 3, 14),
  ),
);

final testAlertState = FraudAlertState(
  alert: testAlert,
  continueRoute: '/easy-mode/pay-bill/1/confirm',
);

void main() {
  group('FraudAlertScreen', () {
    testWidgets('shows 3 options with trusted person', (tester) async {
      await tester.pumpWidget(buildTestWidget(alertState: testAlertState));
      await tester.pumpAndSettle();

      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Continuar de todos modos'), findsOneWidget);
      expect(find.text('Consultar a Valeria'), findsOneWidget);
    });

    testWidgets('shows 2 options without trusted person', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(alertState: testAlertState, trustedPerson: null),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Continuar de todos modos'), findsOneWidget);
      expect(find.text('Consultar a Valeria'), findsNothing);
    });

    testWidgets('shows risk message', (tester) async {
      await tester.pumpWidget(buildTestWidget(alertState: testAlertState));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('shows combined message for multiple rules', (tester) async {
      final combinedAlert = FraudAlertState(
        alert: RiskAlert(
          triggeredRules: const {RiskRule.unusualAmount, RiskRule.newRecipient},
          operation: testAlert.operation,
        ),
        continueRoute: '/easy-mode/send-money/confirm',
      );
      await tester.pumpWidget(buildTestWidget(alertState: combinedAlert));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Continuar de todos modos'), findsOneWidget);
    });

    testWidgets('meets a11y tap target guidelines', (tester) async {
      await tester.pumpWidget(buildTestWidget(alertState: testAlertState));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('meets labeled tap target guidelines', (tester) async {
      await tester.pumpWidget(buildTestWidget(alertState: testAlertState));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
