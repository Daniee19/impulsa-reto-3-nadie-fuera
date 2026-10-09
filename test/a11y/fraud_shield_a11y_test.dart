import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_alert.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/fraud_alert_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/screens/fraud_alert_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_person.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

final _testAlert = RiskAlert(
  triggeredRules: const {RiskRule.unusualAmount},
  operation: OperationContext(
    type: OperationType.payment,
    amount: 850,
    recipientId: 'svc-1',
    recipientName: 'Luz - Enel',
    timestamp: DateTime(2026, 10, 3, 14),
  ),
);

final _testPerson = TrustedPerson(
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

Widget _wrap() {
  return ProviderScope(
    overrides: [
      fraudAlertProvider.overrideWith((ref) {
        return FraudAlertNotifier()
          ..setAlert(_testAlert, '/easy-mode/pay-bill/1/confirm');
      }),
      trustedPersonProvider.overrideWith((ref) => Stream.value(_testPerson)),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: FraudAlertScreen(),
    ),
  );
}

void main() {
  group('Fraud Shield A11y', () {
    testWidgets('meets a11y guidelines', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('buttons have unique labels', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Continuar de todos modos'), findsOneWidget);
      expect(find.text('Consultar a Valeria'), findsOneWidget);
    });
  });
}
