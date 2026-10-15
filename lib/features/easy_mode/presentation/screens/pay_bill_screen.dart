import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/amount_to_words.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/error_message.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/operation_in_progress.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/operation_in_progress_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/bill_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/fraud_alert_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/risk_engine_provider.dart';

/// Provider that extracts unique service names from payment history.
final quickAccessServicesProvider = FutureProvider<List<String>>(
  (ref) async {
    final ops =
        await ref.watch(operationRepositoryProvider).getOperations();
    final serviceNames = <String>{};
    for (final op in ops) {
      if (op.type == OperationType.payment &&
          op.status == OperationStatus.success) {
        final name = op.recipientName.split(' - ').first.trim();
        serviceNames.add(name);
      }
    }
    return serviceNames.toList();
  },
  dependencies: [operationRepositoryProvider],
);

/// Lists pending bills for the user to select and pay.
class PayBillScreen extends ConsumerWidget {
  /// Creates the pay bill screen.
  const PayBillScreen({super.key});

  Future<void> _navigateWithRiskCheck(
    BuildContext context,
    WidgetRef ref,
    Bill bill,
  ) async {
    ref
        .read(operationInProgressProvider.notifier)
        .set(
          OperationInProgress(
            type: OperationType.payment,
            amount: bill.amount,
            recipientName: '${bill.serviceName} - ${bill.providerName}',
            recipientId: bill.id,
          ),
        );

    final operationRepo = ref.read(operationRepositoryProvider);
    final history = await operationRepo.getOperations();
    final opContext = OperationContext(
      type: OperationType.payment,
      amount: bill.amount,
      recipientId: bill.id,
      recipientName: '${bill.serviceName} - ${bill.providerName}',
      timestamp: DateTime.now(),
    );
    final alert = ref
        .read(riskEngineProvider)
        .evaluate(operation: opContext, history: history);

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

  void _showAddServiceDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final providerController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.easyMode_payBill_addTitle),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.easyMode_payBill_serviceNameLabel,
                    hintText: l10n.easyMode_payBill_serviceNameHint,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? l10n.easyMode_payBill_fieldRequired
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: providerController,
                  decoration: InputDecoration(
                    labelText: l10n.easyMode_payBill_providerLabel,
                    hintText: l10n.easyMode_payBill_providerHint,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? l10n.easyMode_payBill_fieldRequired
                          : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.easyMode_back_button),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final repo = ref.read(billRepositoryProvider);
              await repo.addBill(
                serviceName: nameController.text.trim(),
                providerName: providerController.text.trim(),
                amount: 50,
                dueDate: DateTime.now().add(const Duration(days: 30)),
              );
              ref.invalidate(pendingBillsProvider);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.easyMode_payBill_serviceAdded)),
                );
              }
            },
            child: Text(l10n.easyMode_confirm_button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final billsAsync = ref.watch(pendingBillsProvider);
    final quickAsync = ref.watch(quickAccessServicesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.easyMode_payBill_title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.easyMode_payBill_addService),
      ),
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
                        onPressed: () => _showAddServiceDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.easyMode_payBill_addService),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            A11yHelpers.minTapTarget,
                            A11yHelpers.minTapTarget,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
            return ListView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 80,
              ),
              children: [
                // Quick access chips from payment history
                ...quickAsync.maybeWhen(
                  data: (services) {
                    if (services.isEmpty) return <Widget>[];
                    return [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l10n.easyMode_payBill_quickAccess,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: services.map((name) {
                          final matchingBill = bills.cast<Bill?>().firstWhere(
                            (b) => b!.serviceName == name,
                            orElse: () => null,
                          );
                          return ActionChip(
                            avatar: Icon(
                              matchingBill != null
                                  ? Icons.receipt_long
                                  : Icons.history,
                              size: 20,
                              color: Colors.white,
                            ),
                            label: Text(name),
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            onPressed: matchingBill != null
                                ? () async => _navigateWithRiskCheck(
                                      context,
                                      ref,
                                      matchingBill,
                                    )
                                : null,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                    ];
                  },
                  orElse: () => <Widget>[],
                ),
                // Full bill list
                ...bills.map(
                  (bill) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: A11yHelpers.minSeparation / 2,
                    ),
                    child: MergeSemantics(
                      child: Semantics(
                        button: true,
                        label: bill.amount > 0
                            ? '${bill.serviceName}, '
                              '${AmountToWords.convert(bill.amount)}'
                            : '${bill.serviceName}, '
                              '${l10n.easyMode_payBill_pendingAmount}',
                        child: Card(
                          color: theme.colorScheme.primary,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bill.serviceName,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(color: Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          bill.providerName,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ExcludeSemantics(
                                    child: Text(
                                      bill.amount > 0
                                          ? 'S/ ${bill.amount.toStringAsFixed(2)}'
                                          : l10n.easyMode_payBill_pendingAmount,
                                      style: bill.amount > 0
                                          ? theme.textTheme.displayMedium
                                              ?.copyWith(color: Colors.white)
                                          : theme.textTheme.bodyLarge?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.white70,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
