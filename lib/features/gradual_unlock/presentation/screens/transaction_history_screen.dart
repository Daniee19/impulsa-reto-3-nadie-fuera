import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';

/// Shows the last 10 operations.
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  /// Creates the transaction history screen.
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  List<Operation> _operations = [];

  @override
  void initState() {
    super.initState();
    _loadOperations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(
        View.of(context),
        l10n.unlock_feature_transactions,
      );
    });
  }

  Future<void> _loadOperations() async {
    final ops = await ref.read(operationRepositoryProvider).getOperations();
    if (mounted) setState(() => _operations = ops.take(10).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.unlock_feature_transactions)),
      body: SafeArea(
        child: _operations.isEmpty
            ? Center(
                child: Text(
                  l10n.easyMode_payBill_noPending,
                  style: theme.textTheme.bodyLarge,
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _operations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final op = _operations[index];
                  final icon = op.type == OperationType.payment
                      ? Icons.receipt_long
                      : Icons.send;
                  return Semantics(
                    label:
                        '${op.description}, '
                        'S/ ${op.amount.toStringAsFixed(2)}',
                    child: ListTile(
                      leading: Icon(icon, size: 32),
                      title: Text(op.description),
                      subtitle: Text(op.recipientName),
                      trailing: Text(
                        'S/ ${op.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
