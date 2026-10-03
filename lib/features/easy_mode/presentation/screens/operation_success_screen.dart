import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';

/// Success screen after a payment or transfer is completed.
class OperationSuccessScreen extends StatefulWidget {
  /// Creates the operation success screen.
  const OperationSuccessScreen({required this.operation, super.key});

  /// The completed operation.
  final Operation operation;

  @override
  State<OperationSuccessScreen> createState() => _OperationSuccessScreenState();
}

class _OperationSuccessScreenState extends State<OperationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      final message = widget.operation.type == OperationType.payment
          ? l10n.easyMode_success_paymentDone
          : l10n.easyMode_success_transferDone;
      A11yHelpers.announceForAccessibility(View.of(context), message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isPayment = widget.operation.type == OperationType.payment;
    final title = isPayment
        ? l10n.easyMode_success_paymentDone
        : l10n.easyMode_success_transferDone;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 80,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(height: 24),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    title,
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.operation.recipientName,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'S/ ${widget.operation.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go('/easy-mode'),
                  icon: const Icon(Icons.home),
                  label: Text(l10n.easyMode_success_goHome),
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
