import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/balance_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/easy_mode_home_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/help_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/operation_success_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/pay_bill_confirm_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/pay_bill_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/send_money_confirm_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/send_money_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/screens/fraud_alert_screen.dart';

/// App router with easy mode routes.
final appRouter = GoRouter(
  initialLocation: '/easy-mode',
  routes: [
    GoRoute(
      path: '/easy-mode',
      builder: (context, state) => const EasyModeHomeScreen(),
      routes: [
        GoRoute(
          path: 'balance',
          builder: (context, state) => const BalanceScreen(),
        ),
        GoRoute(
          path: 'pay-bill',
          builder: (context, state) => const PayBillScreen(),
          routes: [
            GoRoute(
              path: ':billId/confirm',
              builder: (context, state) {
                final billId = state.pathParameters['billId']!;
                return PayBillConfirmScreen(billId: billId);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'send-money',
          builder: (context, state) => const SendMoneyScreen(),
          routes: [
            GoRoute(
              path: 'confirm',
              builder: (context, state) {
                final extra = state.extra! as SendMoneyConfirmExtra;
                return SendMoneyConfirmScreen(extra: extra);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'fraud-alert',
          builder: (context, state) => const FraudAlertScreen(),
        ),
        GoRoute(path: 'help', builder: (context, state) => const HelpScreen()),
        GoRoute(
          path: 'success',
          builder: (context, state) {
            final operation = state.extra! as Operation;
            return OperationSuccessScreen(operation: operation);
          },
        ),
      ],
    ),
  ],
);
