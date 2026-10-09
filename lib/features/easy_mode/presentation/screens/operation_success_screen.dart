import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/amount_to_words.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/providers/feature_flags_provider.dart';

/// Success screen after a payment or transfer is completed.
class OperationSuccessScreen extends ConsumerStatefulWidget {
  /// Creates the operation success screen.
  const OperationSuccessScreen({required this.operation, super.key});

  /// The completed operation.
  final Operation operation;

  @override
  ConsumerState<OperationSuccessScreen> createState() =>
      _OperationSuccessScreenState();
}

class _OperationSuccessScreenState
    extends ConsumerState<OperationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(featureFlagRepositoryProvider).incrementOpsWithoutHelp();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final amountWords = AmountToWords.convert(widget.operation.amount);
      final message = widget.operation.type == OperationType.payment
          ? l10n.announcePaymentSuccess(
              amountWords,
              widget.operation.recipientName,
            )
          : l10n.announceTransferSuccess(
              amountWords,
              widget.operation.recipientName,
            );
      A11yHelpers.screenAnnounce(View.of(context), message);
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
                Semantics(
                  label: l10n.a11y_operationSuccess,
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: theme.colorScheme.secondary,
                  ),
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
                Semantics(
                  label: AmountToWords.convert(widget.operation.amount),
                  excludeSemantics: true,
                  child: Text(
                    'S/ ${widget.operation.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
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
