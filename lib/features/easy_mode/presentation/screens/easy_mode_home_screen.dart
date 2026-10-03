import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/widgets/action_card.dart';

/// Main screen with 4 large action buttons for easy mode.
class EasyModeHomeScreen extends StatelessWidget {
  /// Creates the easy mode home screen.
  const EasyModeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.easyMode_home_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionCard(
                label: l10n.easyMode_home_checkBalance,
                icon: Icons.account_balance_wallet,
                onTap: () => context.go('/easy-mode/balance'),
              ),
              ActionCard(
                label: l10n.easyMode_home_payBill,
                icon: Icons.receipt_long,
                onTap: () => context.go('/easy-mode/pay-bill'),
              ),
              ActionCard(
                label: l10n.easyMode_home_sendMoney,
                icon: Icons.send,
                onTap: () => context.go('/easy-mode/send-money'),
              ),
              ActionCard(
                label: l10n.easyMode_home_getHelp,
                icon: Icons.help,
                onTap: () => context.go('/easy-mode/help'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
