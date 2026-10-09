import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/data/repositories/mock_account_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/data/repositories/mock_bill_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/data/repositories/mock_contact_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/data/repositories/mock_operation_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/account_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/bill_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/contact_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/balance_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/easy_mode_home_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/operation_success_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/pay_bill_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/send_money_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/entities/reminder.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/presentation/providers/reminder_provider.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      accountRepositoryProvider.overrideWithValue(MockAccountRepository()),
      billRepositoryProvider.overrideWithValue(MockBillRepository()),
      contactRepositoryProvider.overrideWithValue(MockContactRepository()),
      operationRepositoryProvider.overrideWithValue(MockOperationRepository()),
      activeRemindersProvider
          .overrideWith((ref) => Future.value(<Reminder>[])),
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
  group('Easy Mode A11y', () {
    testWidgets('home screen meets a11y guidelines', (tester) async {
      await tester.pumpWidget(_wrap(const EasyModeHomeScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('balance screen meets a11y guidelines', (tester) async {
      await tester.pumpWidget(_wrap(const BalanceScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('balance uses words not symbols', (tester) async {
      await tester.pumpWidget(_wrap(const BalanceScreen()));
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.text('S/ 2450.00'));
      expect(semantics.label, contains('soles'));
    });

    testWidgets('pay bill screen meets a11y guidelines', (tester) async {
      await tester.pumpWidget(_wrap(const PayBillScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('send money screen meets a11y guidelines', (tester) async {
      await tester.pumpWidget(_wrap(const SendMoneyScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('success screen meets a11y guidelines', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OperationSuccessScreen(
            operation: Operation(
              id: 'op-1',
              type: OperationType.payment,
              recipientName: 'Luz - Enel',
              amount: 85.50,
              date: DateTime(2026, 10, 3),
              status: OperationStatus.success,
              description: 'Pago de Luz',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('success screen uses words for amount', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OperationSuccessScreen(
            operation: Operation(
              id: 'op-1',
              type: OperationType.payment,
              recipientName: 'Luz - Enel',
              amount: 85.50,
              date: DateTime(2026, 10, 3),
              status: OperationStatus.success,
              description: 'Pago de Luz',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.text('S/ 85.50'));
      expect(semantics.label, contains('soles'));
    });
  });
}
