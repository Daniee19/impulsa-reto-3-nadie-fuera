import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/widgets/action_card.dart';

/// Main screen with 4 large action buttons for easy mode.
class EasyModeHomeScreen extends StatefulWidget {
  /// Creates the easy mode home screen.
  const EasyModeHomeScreen({super.key});

  @override
  State<EasyModeHomeScreen> createState() => _EasyModeHomeScreenState();
}

class _EasyModeHomeScreenState extends State<EasyModeHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.announceHomeScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.easyMode_home_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: l10n.trustedPerson_title,
            onPressed: () =>
                context.go('/easy-mode/settings/trusted-person'),
          ),
        ],
      ),
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
                onTap: () => context.push('/easy-mode/help/contact-picker'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
