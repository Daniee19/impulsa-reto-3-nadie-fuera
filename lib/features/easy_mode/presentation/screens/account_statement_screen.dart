import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/error_message.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/data/services/statement_pdf_builder.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/account_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';
import 'package:printing/printing.dart';

enum _FilterType { all, payments, transfers }

/// BCP-style account statement with date/type filters and PDF preview.
class AccountStatementScreen extends ConsumerStatefulWidget {
  /// Creates the account statement screen.
  const AccountStatementScreen({super.key});

  @override
  ConsumerState<AccountStatementScreen> createState() =>
      _AccountStatementScreenState();
}

class _AccountStatementScreenState
    extends ConsumerState<AccountStatementScreen> {
  late DateTime _dateFrom;
  late DateTime _dateTo;
  _FilterType _filter = _FilterType.all;
  List<Operation> _allOps = [];
  bool _generated = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateTo = now;
    _dateFrom = DateTime(now.year, now.month - 1, now.day);
  }

  List<Operation> get _filteredOps {
    return _allOps.where((op) {
      if (op.date.isBefore(_dateFrom) ||
          op.date.isAfter(
            _dateTo.add(const Duration(days: 1)),
          )) {
        return false;
      }
      return switch (_filter) {
        _FilterType.all => true,
        _FilterType.payments =>
          op.type == OperationType.payment,
        _FilterType.transfers =>
          op.type == OperationType.transfer,
      };
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _generate() async {
    setState(() => _loading = true);
    final ops = await ref
        .read(operationRepositoryProvider)
        .getOperations();
    await Future<void>.delayed(
      const Duration(milliseconds: 800),
    );
    if (!mounted) return;
    setState(() {
      _allOps = ops;
      _generated = true;
      _loading = false;
    });
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _dateFrom : _dateTo,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: isFrom ? 'Fecha inicio' : 'Fecha fin',
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _dateFrom = picked;
      } else {
        _dateTo = picked;
      }
      if (_generated) _generated = false;
    });
  }

  Future<void> _downloadPdf() async {
    final account = ref.read(accountProvider).valueOrNull;
    if (account == null) return;

    final builder = StatementPdfBuilder(
      accountName: account.holderName,
      accountNumber: account.maskedNumber,
      balance: account.availableBalance,
      operations: _filteredOps,
      dateFrom: _formatDate(_dateFrom),
      dateTo: _formatDate(_dateTo),
    );

    final bytes = await builder.build();
    if (!mounted) return;

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PdfPreviewScreen(pdfBytes: bytes),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountAsync = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.easyMode_home_accountStatement),
      ),
      body: SafeArea(
        child: accountAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => ErrorMessage(
            message: l10n.easyMode_error_generic,
            actionLabel: l10n.easyMode_back_button,
            onAction: () => Navigator.of(context).pop(),
          ),
          data: (account) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Account card
                _AccountHeader(
                  name: account.holderName,
                  number: account.maskedNumber,
                  balance: account.availableBalance,
                ),
                const SizedBox(height: 20),
                // Date filters
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        label: l10n.statement_from,
                        date: _formatDate(_dateFrom),
                        onTap: () => _pickDate(isFrom: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateButton(
                        label: l10n.statement_to,
                        date: _formatDate(_dateTo),
                        onTap: () => _pickDate(isFrom: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Type filter chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: l10n.statement_filterAll,
                      selected: _filter == _FilterType.all,
                      onTap: () => setState(
                        () => _filter = _FilterType.all,
                      ),
                    ),
                    _FilterChip(
                      label: l10n.statement_filterPayments,
                      selected:
                          _filter == _FilterType.payments,
                      onTap: () => setState(
                        () => _filter = _FilterType.payments,
                      ),
                    ),
                    _FilterChip(
                      label: l10n.statement_filterTransfers,
                      selected:
                          _filter == _FilterType.transfers,
                      onTap: () => setState(
                        () => _filter = _FilterType.transfers,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Generate button
                ElevatedButton.icon(
                  onPressed: _loading ? null : _generate,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.description),
                  label: Text(l10n.statement_generate),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      A11yHelpers.minTapTarget,
                    ),
                  ),
                ),
                // Results
                if (_generated) ...[
                  const SizedBox(height: 20),
                  _StatementReport(
                    operations: _filteredOps,
                    dateFrom: _formatDate(_dateFrom),
                    dateTo: _formatDate(_dateTo),
                    accountName: account.holderName,
                    accountNumber: account.maskedNumber,
                    onDownload: _downloadPdf,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.name,
    required this.number,
    required this.balance,
  });

  final String name;
  final String number;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              number,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Saldo disponible',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
            Text(
              'S/ ${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: '$label: $date',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      date,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
    );
  }
}

class _StatementReport extends StatelessWidget {
  const _StatementReport({
    required this.operations,
    required this.dateFrom,
    required this.dateTo,
    required this.accountName,
    required this.accountNumber,
    required this.onDownload,
  });

  final List<Operation> operations;
  final String dateFrom;
  final String dateTo;
  final String accountName;
  final String accountNumber;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final total = operations.fold<double>(
      0,
      (sum, op) => sum + op.amount,
    );

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PDF-like header
            Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.easyMode_home_accountStatement,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.statement_period(
                          dateFrom,
                          dateTo,
                        ),
                        style:
                            theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Account info
            Text(
              accountName,
              style: theme.textTheme.titleMedium,
            ),
            Text(
              accountNumber,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            // Summary row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.statement_totalOps(
                      operations.length,
                    ),
                    style:
                        theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.statement_totalAmount(
                      total.toStringAsFixed(2),
                    ),
                    style:
                        theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Operations table
            if (operations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: Text(
                  l10n.statement_noOps,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              // Table header
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Fecha',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Descripción',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Monto',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...operations.map(
                (op) => _StatementRow(operation: op),
              ),
            ],
            const SizedBox(height: 20),
            // Download button
            ElevatedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(l10n.statement_download),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  A11yHelpers.minTapTarget,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatementRow extends StatelessWidget {
  const _StatementRow({required this.operation});

  final Operation operation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        '${operation.date.day.toString().padLeft(2, '0')}/'
        '${operation.date.month.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              dateStr,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operation.recipientName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  operation.type == OperationType.payment
                      ? 'Pago'
                      : 'Transferencia',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '-S/ ${operation.amount.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfPreviewScreen extends StatelessWidget {
  const _PdfPreviewScreen({required this.pdfBytes});

  final Uint8List pdfBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado de cuenta'),
      ),
      body: PdfPreview(
        build: (_) => pdfBytes,
        canChangePageFormat: false,
        canChangeOrientation: false,
        pdfFileName: 'estado_cuenta.pdf',
      ),
    );
  }
}
