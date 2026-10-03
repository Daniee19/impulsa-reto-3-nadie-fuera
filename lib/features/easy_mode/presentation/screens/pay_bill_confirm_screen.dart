import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/confirmation_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/error_message.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/account_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/bill_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';

/// Confirmation screen for paying a selected bill.
class PayBillConfirmScreen extends ConsumerStatefulWidget {
  /// Creates the pay bill confirm screen.
  const PayBillConfirmScreen({required this.billId, super.key});

  /// The ID of the bill to pay.
  final String billId;

  @override
  ConsumerState<PayBillConfirmScreen> createState() =>
      _PayBillConfirmScreenState();
}

class _PayBillConfirmScreenState extends ConsumerState<PayBillConfirmScreen> {
  bool _processing = false;

  Future<void> _confirmPayment() async {
    if (_processing) return;
    setState(() => _processing = true);

    try {
      final billRepo = ref.read(billRepositoryProvider);
      final accountRepo = ref.read(accountRepositoryProvider);
      final operationRepo = ref.read(operationRepositoryProvider);
      final account = await accountRepo.getAccount();
      final bill = await billRepo.getBillById(widget.billId);

      await accountRepo.updateBalance(
        account.id,
        account.availableBalance - bill.amount,
      );
      await billRepo.payBill(widget.billId);
      final operation = await operationRepo.createOperation(
        type: OperationType.payment,
        recipientName: '${bill.serviceName} - ${bill.providerName}',
        amount: bill.amount,
        description: 'Pago de ${bill.serviceName}',
      );

      ref
        ..invalidate(accountProvider)
        ..invalidate(pendingBillsProvider);

      if (mounted) {
        context.go('/easy-mode/success', extra: operation);
      }
    } catch (_) {
      setState(() => _processing = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.easyMode_error_generic)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final billRepo = ref.read(billRepositoryProvider);

    return FutureBuilder(
      future: billRepo.getBillById(widget.billId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.easyMode_payBill_confirmTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.easyMode_payBill_confirmTitle)),
            body: ErrorMessage(
              message: l10n.easyMode_error_generic,
              actionLabel: l10n.easyMode_back_button,
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }
        final bill = snapshot.data!;
        return ConfirmationScreen(
          title: l10n.easyMode_payBill_confirmTitle,
          items: [
            (
              label: l10n.easyMode_payBill_service,
              value: '${bill.serviceName} - ${bill.providerName}',
            ),
            (
              label: l10n.easyMode_payBill_amount,
              value: 'S/ ${bill.amount.toStringAsFixed(2)}',
            ),
          ],
          confirmLabel: _processing
              ? '...'
              : l10n.easyMode_confirm_button,
          onConfirm: _confirmPayment,
          onBack: () => Navigator.of(context).pop(),
        );
      },
    );
  }
}
