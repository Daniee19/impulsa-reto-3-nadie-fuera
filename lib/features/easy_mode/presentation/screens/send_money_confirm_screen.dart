import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/confirmation_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/saved_contact.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/account_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';

/// Data passed to the send money confirm screen.
class SendMoneyConfirmExtra {
  /// Creates the extra data.
  const SendMoneyConfirmExtra({required this.contact, required this.amount});

  /// The contact to send money to.
  final SavedContact contact;

  /// The amount to send.
  final double amount;
}

/// Confirmation screen for sending money to a contact.
class SendMoneyConfirmScreen extends ConsumerStatefulWidget {
  /// Creates the send money confirm screen.
  const SendMoneyConfirmScreen({required this.extra, super.key});

  /// The transfer details.
  final SendMoneyConfirmExtra extra;

  @override
  ConsumerState<SendMoneyConfirmScreen> createState() =>
      _SendMoneyConfirmScreenState();
}

class _SendMoneyConfirmScreenState
    extends ConsumerState<SendMoneyConfirmScreen> {
  bool _processing = false;

  Future<void> _confirmTransfer() async {
    if (_processing) return;
    setState(() => _processing = true);

    try {
      final accountRepo = ref.read(accountRepositoryProvider);
      final operationRepo = ref.read(operationRepositoryProvider);
      final account = await accountRepo.getAccount();

      await accountRepo.updateBalance(
        account.id,
        account.availableBalance - widget.extra.amount,
      );
      final operation = await operationRepo.createOperation(
        type: OperationType.transfer,
        recipientName: widget.extra.contact.name,
        amount: widget.extra.amount,
        description: 'Envío a ${widget.extra.contact.name}',
      );

      ref.invalidate(accountProvider);

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
    final accountAsync = ref.watch(accountProvider);
    final remainingBalance = accountAsync.whenOrNull(
      data: (account) => account.availableBalance - widget.extra.amount,
    );

    return ConfirmationScreen(
      title: l10n.easyMode_sendMoney_confirmTitle,
      items: [
        (
          label: l10n.easyMode_sendMoney_recipient,
          value: widget.extra.contact.name,
        ),
        (
          label: l10n.easyMode_sendMoney_amountLabel,
          value: 'S/ ${widget.extra.amount.toStringAsFixed(2)}',
        ),
        if (remainingBalance != null)
          (
            label: l10n.easyMode_sendMoney_remainingBalance,
            value: 'S/ ${remainingBalance.toStringAsFixed(2)}',
          ),
      ],
      confirmLabel: _processing ? '...' : l10n.easyMode_confirm_button,
      onConfirm: _confirmTransfer,
      onBack: () => Navigator.of(context).pop(),
    );
  }
}
