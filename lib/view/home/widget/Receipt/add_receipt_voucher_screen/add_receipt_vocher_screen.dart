import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/Receipt/Receipt_class/receipt_class.dart';
import 'package:new_project_2025/view/home/widget/Receipt/receipt_database/receipt_database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AddReceiptVoucherPage extends StatefulWidget {
  final Receipt? receipt;

  const AddReceiptVoucherPage({super.key, this.receipt});

  @override
  State<AddReceiptVoucherPage> createState() => _AddReceiptVoucherPageState();
}

class _AddReceiptVoucherPageState extends State<AddReceiptVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime selectedDate;
  String? selectedAccount;
  final TextEditingController _amountController = TextEditingController();
  String paymentMode = 'Cash';
  String? selectedCashOption;
  final TextEditingController _remarksController = TextEditingController();
  bool _isSaved = false;

  final List<String> accounts = [
    'Agriculture Expenses',
    'Agriculture Income',
    'Household Expenses',
    'Salary Income',
    'Miscellaneous',
  ];

  final List<String> cashOptions = [
    'Cash',
    'Bank - HDFC',
    'Bank - SBI',
    'Bank - ICICI',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.receipt != null) {
      selectedDate = DateFormat('yyyy-MM-dd').parse(widget.receipt!.date);
      selectedAccount = widget.receipt!.accountName;
      _amountController.text = widget.receipt!.amount.toString();
      paymentMode = widget.receipt!.paymentMode;
      selectedCashOption =
          widget.receipt!.paymentMode == 'Bank'
              ? cashOptions[1]
              : cashOptions[0];
      _remarksController.text = widget.receipt!.remarks ?? '';
    } else {
      selectedDate = DateTime.now();
      selectedCashOption = cashOptions[0];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveReceipt() async {
    if (_formKey.currentState!.validate()) {
      final receipt = Receipt(
        id: widget.receipt?.id,
        date: DateFormat('yyyy-MM-dd').format(selectedDate),
        accountName: selectedAccount!,
        amount: double.parse(_amountController.text),
        paymentMode: paymentMode,
        remarks: _remarksController.text,
      );

      if (widget.receipt == null) {
        await DatabaseHelper1.instance.insertReceipt(receipt);
      } else {
        await DatabaseHelper1.instance.updateReceipt(receipt);
      }

      setState(() {
        _isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt Saved Successfully')),
      );

      // After saving, ask user if they want to download PDF
      _showDownloadPdfDialog(receipt);
    }
  }

  void _showDownloadPdfDialog(Receipt receipt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Download PDF'),
          content: const Text(
            'Do you want to download a PDF copy of this receipt?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Download'),
              onPressed: () {
                Navigator.of(context).pop();
                _generateAndDownloadPDF(receipt);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndDownloadPDF(Receipt receipt) async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to save PDF'),
            ),
          );
          return;
        }
      }

      // Create the PDF document
      final pdf = pw.Document();

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'RECEIPT VOUCHER',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Divider(thickness: 1),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Receipt details in table format
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(3),
                    },
                    children: [
                      // Table header
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Field',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Details',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Receipt ID
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Receipt ID'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              receipt.id?.toString() ?? 'New Receipt',
                            ),
                          ),
                        ],
                      ),
                      // Account Name
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Account Name'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(receipt.accountName),
                          ),
                        ],
                      ),
                      // Amount
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Amount'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '₹ ${receipt.amount.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                      // Payment Mode
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Payment Mode'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(receipt.paymentMode),
                          ),
                        ],
                      ),
                      // Account Details
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Account Details'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(selectedCashOption ?? ''),
                          ),
                        ],
                      ),
                      // Remarks
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Remarks'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(receipt.remarks ?? 'N/A'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 40),

                  // Signature section
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Receiver Signature'),
                          pw.SizedBox(height: 20),
                          pw.Container(
                            width: 100,
                            decoration: pw.BoxDecoration(
                              border: pw.Border(top: pw.BorderSide(width: 1)),
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Authorizer Signature'),
                          pw.SizedBox(height: 20),
                          pw.Container(
                            width: 100,
                            decoration: pw.BoxDecoration(
                              border: pw.Border(top: pw.BorderSide(width: 1)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.Spacer(),

                  // Footer
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Divider(thickness: 1),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Generated on: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Get the document directory
      final output = await getApplicationDocumentsDirectory();
      final String fileName =
          'Receipt_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');

      // Save the PDF file
      await file.writeAsBytes(await pdf.save());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved at: ${file.path}'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => OpenFile.open(file.path),
          ),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Receipt Voucher'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_isSaved)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                if (_isSaved) {
                  final receipt = Receipt(
                    id: widget.receipt?.id,
                    date: DateFormat('yyyy-MM-dd').format(selectedDate),
                    accountName: selectedAccount!,
                    amount: double.parse(_amountController.text),
                    paymentMode: paymentMode,
                    remarks: _remarksController.text,
                  );
                  _generateAndDownloadPDF(receipt);
                }
              },
              tooltip: 'Download PDF',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd-MM-yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          hint: const Text('Select An Account'),
                          value: selectedAccount,
                          isExpanded: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an account';
                            }
                            return null;
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAccount = newValue;
                            });
                          },
                          items:
                              accounts.map<DropdownMenuItem<String>>((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feature to add new account'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Amount',
                    labelText: 'Amount',
                    prefixText: '₹ ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Radio<String>(
                    value: 'Bank',
                    groupValue: paymentMode,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMode = value!;
                        selectedCashOption = cashOptions[1];
                      });
                    },
                  ),
                  const Text('Bank'),
                  const SizedBox(width: 30),
                  Radio<String>(
                    value: 'Cash',
                    groupValue: paymentMode,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMode = value!;
                        selectedCashOption = cashOptions[0];
                      });
                    },
                  ),
                  const Text('Cash'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          value: selectedCashOption,
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCashOption = newValue;
                              if (newValue == 'Cash') {
                                paymentMode = 'Cash';
                              } else {
                                paymentMode = 'Bank';
                              }
                            });
                          },
                          items:
                              paymentMode == 'Cash'
                                  ? [
                                    cashOptions[0],
                                  ].map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList()
                                  : cashOptions
                                      .sublist(1)
                                      .map<DropdownMenuItem<String>>((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      })
                                      .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feature to add new bank account'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Remarks',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _saveReceipt,
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
