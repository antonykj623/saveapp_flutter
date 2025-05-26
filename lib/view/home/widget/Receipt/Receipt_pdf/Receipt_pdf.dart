import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/Receipt/Receipt_class/receipt_class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReceiptPdfExporter {
  static Future<File> generatePdf(
    List<Receipt> receipts,
    String monthYear,
  ) async {
    final pdf = pw.Document();

    // Format the month and year for display
    final parts = monthYear.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthName = DateFormat('MMMM').format(DateTime(2022, month));
    final displayMonthYear = '$monthName $year';

    // Calculate total
    final total = receipts.fold(0.0, (sum, receipt) => sum + receipt.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Receipt Statement',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Month: $displayMonthYear',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.Divider(),
              ],
            ),
        footer:
            (context) => pw.Column(
              children: [
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Generated on: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                    ),
                    pw.Text(
                      'Page ${context.pageNumber} of ${context.pagesCount}',
                    ),
                  ],
                ),
              ],
            ),
        build:
            (context) => [
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Account Name', 'Amount', 'Payment Mode'],
                data:
                    receipts
                        .map(
                          (receipt) => [
                            DateFormat('dd/MM/yyyy').format(
                              DateFormat('yyyy-MM-dd').parse(receipt.date),
                            ),
                            receipt.accountName,
                            receipt.amount.toString(),
                            receipt.paymentMode,
                          ],
                        )
                        .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.center,
                },
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total: ${total.toStringAsFixed(1)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
      ),
    );

    // Save the PDF to a file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipts_$monthYear.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<void> shareReceiptsPdf(
    BuildContext context,
    List<Receipt> receipts,
    String monthYear,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating PDF...'),
              ],
            ),
          );
        },
      );

      // Generate PDF file
      final file = await generatePdf(receipts, monthYear);

      // Close loading dialog
      Navigator.of(context).pop();

      // Share the PDF file
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Receipts for $monthYear');
    } catch (e) {
      // Close loading dialog if still showing
      if (context.mounted) Navigator.of(context).pop();

      // Show error dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to generate or share PDF: ${e.toString()}'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
