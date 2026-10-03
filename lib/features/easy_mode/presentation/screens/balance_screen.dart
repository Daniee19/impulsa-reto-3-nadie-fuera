import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/error_message.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/account_provider.dart';

/// Shows the user's available balance in large, accessible text.
class BalanceScreen extends ConsumerWidget {
  /// Creates the balance screen.
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final accountAsync = ref.watch(accountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.easyMode_balance_title)),
      body: SafeArea(
        child: accountAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorMessage(
            message: l10n.easyMode_error_generic,
            actionLabel: l10n.easyMode_back_button,
            onAction: () => Navigator.of(context).pop(),
          ),
          data: (account) => Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  label: '${l10n.easyMode_balance_accountLabel}: '
                      '${account.holderName}',
                  child: Text(
                    account.holderName,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: '${l10n.easyMode_balance_accountLabel}: '
                      '${account.maskedNumber}',
                  child: Text(
                    account.maskedNumber,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.easyMode_balance_availableBalance,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: '${l10n.easyMode_balance_availableBalance}: '
                      'S/ ${account.availableBalance.toStringAsFixed(2)}',
                  child: Text(
                    'S/ ${account.availableBalance.toStringAsFixed(2)}',
                    style: theme.textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: A11yHelpers.minTapTarget),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.easyMode_back_button),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      A11yHelpers.minTapTarget,
                      A11yHelpers.minTapTarget,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
