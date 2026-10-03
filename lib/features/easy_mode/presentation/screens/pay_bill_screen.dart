import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/error_message.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/bill_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/services/risk_engine.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/fraud_alert_provider.dart';

/// Lists pending bills for the user to select and pay.
class PayBillScreen extends ConsumerWidget {
  /// Creates the pay bill screen.
  const PayBillScreen({super.key});

  Future<void> _navigateWithRiskCheck(
    BuildContext context,
    WidgetRef ref,
    Bill bill,
  ) async {
    final operationRepo = ref.read(operationRepositoryProvider);
    final history = await operationRepo.getOperations();
    final opContext = OperationContext(
      type: OperationType.payment,
      amount: bill.amount,
      recipientId: bill.id,
      recipientName: '${bill.serviceName} - ${bill.providerName}',
      timestamp: DateTime.now(),
    );
    final alert = RiskEngine().evaluate(operation: opContext, history: history);

    if (!context.mounted) return;

    if (alert != null) {
      ref
          .read(fraudAlertProvider.notifier)
          .setAlert(alert, '/easy-mode/pay-bill/${bill.id}/confirm');
      await context.push<void>('/easy-mode/fraud-alert');
    } else {
      context.go('/easy-mode/pay-bill/${bill.id}/confirm');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final billsAsync = ref.watch(pendingBillsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.easyMode_payBill_title)),
      body: SafeArea(
        child: billsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorMessage(
            message: l10n.easyMode_error_generic,
            actionLabel: l10n.easyMode_back_button,
            onAction: () => Navigator.of(context).pop(),
          ),
          data: (bills) {
            if (bills.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.easyMode_payBill_noPending,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
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
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: A11yHelpers.minSeparation / 2,
                  ),
                  child: Semantics(
                    button: true,
                    label:
                        '${bill.serviceName}, '
                        'S/ ${bill.amount.toStringAsFixed(2)}',
                    child: Card(
                      child: InkWell(
                        onTap: () async =>
                            _navigateWithRiskCheck(context, ref, bill),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bill.serviceName,
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bill.providerName,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'S/ ${bill.amount.toStringAsFixed(2)}',
                                style: theme.textTheme.displayMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
