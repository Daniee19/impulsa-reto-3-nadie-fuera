import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/error_message.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/saved_contact.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/account_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/contact_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/screens/send_money_confirm_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/services/risk_engine.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/fraud_alert_provider.dart';

/// Screen to select a contact and enter an amount to send.
class SendMoneyScreen extends ConsumerStatefulWidget {
  /// Creates the send money screen.
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  SavedContact? _selectedContact;
  final _amountController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final l10n = AppLocalizations.of(context)!;
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      setState(() => _errorText = l10n.easyMode_error_amountZero);
      return;
    }

    final account = ref.read(accountProvider).valueOrNull;
    if (account != null && amount > account.availableBalance) {
      setState(() {
        _errorText = l10n.easyMode_sendMoney_insufficientFunds(
          account.availableBalance.toStringAsFixed(2),
        );
      });
      return;
    }

    setState(() => _errorText = null);

    final extra = SendMoneyConfirmExtra(
      contact: _selectedContact!,
      amount: amount,
    );

    final operationRepo = ref.read(operationRepositoryProvider);
    final history = await operationRepo.getOperations();
    final opContext = OperationContext(
      type: OperationType.transfer,
      amount: amount,
      recipientId: _selectedContact!.id,
      recipientName: _selectedContact!.name,
      timestamp: DateTime.now(),
    );
    final alert = RiskEngine().evaluate(operation: opContext, history: history);

    if (!mounted) return;

    if (alert != null) {
      ref
          .read(fraudAlertProvider.notifier)
          .setAlert(alert, '/easy-mode/send-money/confirm', extra);
      await context.push<void>('/easy-mode/fraud-alert');
    } else {
      context.go('/easy-mode/send-money/confirm', extra: extra);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contactsAsync = ref.watch(contactsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.easyMode_sendMoney_title)),
      body: SafeArea(
        child: contactsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorMessage(
            message: l10n.easyMode_error_generic,
            actionLabel: l10n.easyMode_back_button,
            onAction: () => Navigator.of(context).pop(),
          ),
          data: (contacts) {
            if (contacts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.easyMode_sendMoney_noContacts,
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

            if (_selectedContact == null) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: A11yHelpers.minSeparation / 2,
                    ),
                    child: Semantics(
                      button: true,
                      label: contact.name,
                      child: Card(
                        child: InkWell(
                          onTap: () =>
                              setState(() => _selectedContact = contact),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: Text(
                                    contact.initial,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    contact.name,
                                    style: theme.textTheme.titleLarge,
                                  ),
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
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    label:
                        '${l10n.easyMode_sendMoney_recipient}: '
                        '${_selectedContact!.name}',
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            _selectedContact!.initial,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _selectedContact!.name,
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    label: l10n.easyMode_sendMoney_enterAmount,
                    textField: true,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      style: theme.textTheme.displayMedium,
                      decoration: InputDecoration(
                        labelText: l10n.easyMode_sendMoney_enterAmount,
                        prefixText: 'S/ ',
                        errorText: _errorText,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async => _onContinue(),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l10n.easyMode_confirm_button),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        A11yHelpers.minTapTarget,
                        A11yHelpers.minTapTarget,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedContact = null),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.easyMode_back_button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.primary,
                      minimumSize: const Size(
                        A11yHelpers.minTapTarget,
                        A11yHelpers.minTapTarget,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
