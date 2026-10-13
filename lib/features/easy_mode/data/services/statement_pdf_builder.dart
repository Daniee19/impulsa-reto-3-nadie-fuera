import 'dart:typed_data';

import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Builds an account statement PDF in memory.
class StatementPdfBuilder {
  StatementPdfBuilder({
    required this.accountName,
    required this.accountNumber,
    required this.balance,
    required this.operations,
    required this.dateFrom,
    required this.dateTo,
  });

  final String accountName;
  final String accountNumber;
  final double balance;
  final List<Operation> operations;
  final String dateFrom;
  final String dateTo;

  Future<Uint8List> build() async {
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
      ),
    );
    final total = operations.fold<double>(
      0,
      (sum, op) => sum + op.amount,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _header(context),
        footer: (context) => _footer(context),
        build: (context) => [
          _accountInfo(),
          pw.SizedBox(height: 16),
          _summary(total),
          pw.SizedBox(height: 16),
          if (operations.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(24),
                child: pw.Text(
                  'No hay movimientos en este período',
                ),
              ),
            )
          else
            _operationsTable(),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _header(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Estado de Cuenta',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Período: $dateFrom al $dateTo',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _footer(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Documento generado automáticamente',
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey500,
          ),
        ),
        pw.Text(
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey500,
          ),
        ),
      ],
    );
  }

  pw.Widget _accountInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                accountName,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Cuenta: $accountNumber',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Saldo disponible',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                'S/ ${balance.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _summary(double total) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${operations.length} movimientos',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Total: S/ ${total.toStringAsFixed(2)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _operationsTable() {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      },
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
      ),
      cellPadding: const pw.EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      headers: ['Fecha', 'Descripción', 'Tipo', 'Monto'],
      data: operations.map((op) {
        final d = op.date;
        final date =
            '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/'
            '${d.year}';
        final type = op.type == OperationType.payment
            ? 'Pago'
            : 'Transferencia';
        return [
          date,
          op.recipientName,
          type,
          '-S/ ${op.amount.toStringAsFixed(2)}',
        ];
      }).toList(),
    );
  }
}
