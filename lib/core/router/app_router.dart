import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/router/navigation_observer.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/navigation_context_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/screens/help_channel_picker_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/screens/help_connecting_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/screens/help_contact_picker_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/screens/help_fallback_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/widgets/help_fab.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/balance_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/easy_mode_home_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/operation_success_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/pay_bill_confirm_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/pay_bill_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/send_money_confirm_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/send_money_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/screens/fraud_alert_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/screens/feature_management_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/screens/mobile_recharge_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/screens/qr_payment_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/screens/transaction_history_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/config_suggestion.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/config_suggestion_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/trusted_person_change_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/trusted_person_detail_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/trusted_person_permissions_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/trusted_person_register_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/trusted_person_remove_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/trusted_person_setup_screen.dart';

/// App router provider with navigation observer and help FAB.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/easy-mode',
    observers: [
      NavigationObserver((route) {
        ref.read(navigationContextProvider.notifier).updateFromRoute(route);
      }),
    ],
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final isHelpScreen = state.uri.path.contains('/help/');
          return Stack(
            children: [
              child,
              if (!isHelpScreen)
                Positioned(
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  child: const HelpFab(),
                ),
            ],
          );
        },
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
                path: 'settings/trusted-person',
                builder: (context, state) => const TrustedPersonSetupScreen(),
                routes: [
                  GoRoute(
                    path: 'register',
                    builder: (context, state) =>
                        const TrustedPersonRegisterScreen(),
                  ),
                  GoRoute(
                    path: 'permissions',
                    builder: (context, state) {
                      final data =
                          state.extra! as TrustedPersonRegistrationData;
                      return TrustedPersonPermissionsScreen(data: data);
                    },
                  ),
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) =>
                        const TrustedPersonDetailScreen(),
                  ),
                  GoRoute(
                    path: 'change',
                    builder: (context, state) =>
                        const TrustedPersonChangeScreen(),
                  ),
                  GoRoute(
                    path: 'remove',
                    builder: (context, state) =>
                        const TrustedPersonRemoveScreen(),
                  ),
                  GoRoute(
                    path: 'suggestion',
                    builder: (context, state) {
                      final suggestion = state.extra! as ConfigSuggestion;
                      return ConfigSuggestionScreen(suggestion: suggestion);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'transactions',
                builder: (context, state) => const TransactionHistoryScreen(),
              ),
              GoRoute(
                path: 'recharge',
                builder: (context, state) => const MobileRechargeScreen(),
              ),
              GoRoute(
                path: 'qr-payment',
                builder: (context, state) => const QrPaymentScreen(),
              ),
              GoRoute(
                path: 'settings/features',
                builder: (context, state) => const FeatureManagementScreen(),
              ),
              GoRoute(
                path: 'fraud-alert',
                builder: (context, state) => const FraudAlertScreen(),
              ),
              GoRoute(
                path: 'help/contact-picker',
                builder: (context, state) => const HelpContactPickerScreen(),
              ),
              GoRoute(
                path: 'help/channel-picker',
                builder: (context, state) {
                  final target = state.extra! as HelpTarget;
                  return HelpChannelPickerScreen(target: target);
                },
              ),
              GoRoute(
                path: 'help/connecting',
                builder: (context, state) => const HelpConnectingScreen(),
              ),
              GoRoute(
                path: 'help/fallback',
                builder: (context, state) => const HelpFallbackScreen(),
              ),
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
      ),
    ],
  );
});
