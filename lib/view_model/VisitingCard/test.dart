import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MaterialApp(home: PDFGeneratorScreen()));
}

class PDFGeneratorScreen extends StatelessWidget {
  final pdf = pw.Document();

  Future<File> generatePDFFile() async {
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Center(
              child: pw.Text(
                "Hello! This is a shared PDF.",
                style: pw.TextStyle(fontSize: 24),
              ),
            ),
      ),
    );

    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> sharePDF(File pdfFile) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      text: "Here is your generated PDF file!",
      subject: "Generated PDF",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Share Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final file = await generatePDFFile();
            await sharePDF(file);
          },
          child: const Text("Generate & Share PDF"),
        ),
      ),
    );
  }
}
