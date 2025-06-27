import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:new_project_2025/model/receipt.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../../save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  List<String> cashOptions = ['Cash'];
  List<String> bankOptions = [];
  List<String> allBankCashOptions = [];

  @override
  void initState() {
    super.initState();
    _loadBankCashOptions();

    if (widget.receipt != null) {
      try {
        selectedDate = DateFormat('dd/MM/yyyy').parse(widget.receipt!.date);
      } catch (e) {
        print(
          'Error parsing date: ${widget.receipt!.date}, using current date',
        );
        selectedDate = DateTime.now();
      }
      selectedAccount = widget.receipt!.accountName;
      _amountController.text = widget.receipt!.amount.toString();
      paymentMode = widget.receipt!.paymentMode;
      selectedCashOption = widget.receipt!.paymentMode;
      _remarksController.text = widget.receipt!.remarks ?? '';
    } else {
      selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadBankCashOptions() async {
    try {
      List<Map<String, dynamic>> accounts = await DatabaseHelper().getAllData(
        "TABLE_ACCOUNTSETTINGS",
      );
      List<String> banks = [];
      List<String> cashAccounts = [];

      for (var account in accounts) {
        try {
          Map<String, dynamic> accountData = jsonDecode(account["data"]);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          if (accountType == 'bank') {
            banks.add(accountName);
          } else if (accountType == 'cash' &&
              accountName.toLowerCase() != 'cash') {
            cashAccounts.add(accountName);
          }
        } catch (e) {
          print('Error parsing account data: $e');
        }
      }

      setState(() {
        cashOptions = ['Cash', ...cashAccounts];
        bankOptions = banks;
        allBankCashOptions = [...cashOptions, ...bankOptions];

        if (paymentMode == 'Cash') {
          selectedCashOption =
              cashOptions.contains(selectedCashOption)
                  ? selectedCashOption
                  : cashOptions.first;
        } else {
          selectedCashOption =
              bankOptions.contains(selectedCashOption)
                  ? selectedCashOption
                  : bankOptions.isNotEmpty
                  ? bankOptions.first
                  : null;
        }
      });
    } catch (e) {
      print('Error loading bank/cash options: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bank/cash options: $e')),
        );
      }
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

  void _showSearchableAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchableAccountDialog(
          onAccountSelected: (String accountName) {
            setState(() {
              selectedAccount = accountName;
            });
          },
        );
      },
    );
  }

  Future<String> getNextSetupId(String name) async {
    try {
      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> allRows = await db.query(
        'TABLE_ACCOUNTSETTINGS',
      );
      for (var row in allRows) {
        Map<String, dynamic> dat = jsonDecode(row["data"]);
        if (dat['Accountname'].toString().toLowerCase() == name.toLowerCase()) {
          return row['keyid'].toString();
        }
      }
      return name.toLowerCase() == 'cash' ? '1' : '0';
    } catch (e) {
      print('Error getting setup ID: $e');
      return '0';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return months[month - 1];
  }

  Future<void> _saveDoubleEntryAccounts(Receipt receipt, int receiptId) async {
    try {
      final db = await DatabaseHelper().database;
      final dateString = receipt.date;
      final monthString = _getMonthName(selectedDate.month);
      final yearString = selectedDate.year.toString();

      final firstSetupId = await getNextSetupId(selectedAccount!);
      final contraSetupId = await getNextSetupId(selectedCashOption!);

      if (widget.receipt != null) {
        // Update existing entries
        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateString,
            "ACCOUNTS_setupid": contraSetupId,
            "ACCOUNTS_amount": receipt.amount.toString(),
            "ACCOUNTS_remarks": 'Receipt from $selectedAccount',
            "ACCOUNTS_year": yearString,
            "ACCOUNTS_month": monthString,
            "ACCOUNTS_cashbanktype": paymentMode == 'Cash' ? '1' : '2',
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [2, widget.receipt!.id.toString(), 'credit'],
        );

        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": dateString,
            "ACCOUNTS_setupid": firstSetupId,
            "ACCOUNTS_amount": receipt.amount.toString(),
            "ACCOUNTS_remarks": 'Receipt to $selectedCashOption',
            "ACCOUNTS_year": yearString,
            "ACCOUNTS_month": monthString,
            "ACCOUNTS_cashbanktype": paymentMode == 'Cash' ? '1' : '2',
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [2, widget.receipt!.id.toString(), 'debit'],
        );
      } else {
        // Insert new entries
        Map<String, dynamic> cashBankEntry = {
          'ACCOUNTS_VoucherType': 2,
          'ACCOUNTS_entryid': receiptId.toString(),
          'ACCOUNTS_date': dateString,
          'ACCOUNTS_setupid': contraSetupId,
          'ACCOUNTS_amount': receipt.amount.toString(),
          'ACCOUNTS_type': 'credit',
          'ACCOUNTS_remarks': 'Receipt from $selectedAccount',
          'ACCOUNTS_year': yearString,
          'ACCOUNTS_month': monthString,
          'ACCOUNTS_cashbanktype': paymentMode == 'Cash' ? '1' : '2',
          'ACCOUNTS_billId': '',
          'ACCOUNTS_billVoucherNumber': '',
        };

        await db.insert("TABLE_ACCOUNTS", cashBankEntry);

        Map<String, dynamic> accountEntry = {
          'ACCOUNTS_VoucherType': 2,
          'ACCOUNTS_entryid': receiptId.toString(),
          'ACCOUNTS_date': dateString,
          'ACCOUNTS_setupid': firstSetupId,
          'ACCOUNTS_amount': receipt.amount.toString(),
          'ACCOUNTS_type': 'debit',
          'ACCOUNTS_remarks': 'Receipt to $selectedCashOption',
          'ACCOUNTS_year': yearString,
          'ACCOUNTS_month': monthString,
          'ACCOUNTS_cashbanktype': paymentMode == 'Cash' ? '1' : '2',
          'ACCOUNTS_billId': '',
          'ACCOUNTS_billVoucherNumber': '',
        };

        await db.insert("TABLE_ACCOUNTS", accountEntry);
      }

      final isBalanced = await DatabaseHelper().validateDoubleEntry();
      if (!isBalanced) {
        throw Exception('Double-entry accounting is unbalanced');
      }
    } catch (e) {
      print('Error saving double-entry accounts: $e');
      throw e;
    }
  }

  void _saveReceipt() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedAccount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }
    if (selectedCashOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a cash/bank option')),
      );
      return;
    }

    try {
      final receipt = Receipt(
        id: widget.receipt?.id,
        date: DateFormat('dd/MM/yyyy').format(selectedDate),
        accountName: selectedAccount!,
        amount: double.parse(_amountController.text),
        paymentMode: selectedCashOption!,
        remarks: _remarksController.text,
      );

      final db = await DatabaseHelper().database;
      int receiptId;
      if (widget.receipt != null) {
        receiptId = widget.receipt!.id!;
        await db.update(
          "TABLE_ACCOUNTS",
          {
            "ACCOUNTS_date": receipt.date,
            "ACCOUNTS_setupid": await getNextSetupId(receipt.accountName),
            "ACCOUNTS_amount": receipt.amount.toString(),
            "ACCOUNTS_remarks": receipt.remarks,
            "ACCOUNTS_year": selectedDate.year.toString(),
            "ACCOUNTS_month": _getMonthName(selectedDate.month),
            "ACCOUNTS_cashbanktype": receipt.paymentMode == 'Cash' ? '1' : '2',
          },
          where:
              "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ? AND ACCOUNTS_type = ?",
          whereArgs: [2, receiptId.toString(), 'debit'],
        );
      } else {
        receiptId = await DatabaseHelper().insertReceipt(receipt);
      }

      await _saveDoubleEntryAccounts(receipt, receiptId);

      setState(() {
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt saved successfully')),
        );
        _showDownloadPDFDialog(receipt);
      }
    } catch (e) {
      print('Error saving receipt: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving receipt: $e')));
      }
    }
  }

  void _showDownloadPDFDialog(Receipt receipt) {
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
              onPressed: () => Navigator.of(context).pop(),
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
    ).then((_) {
      if (mounted) {
        Navigator.pop(context, true); // Navigate back after dialog is closed
      }
    });
  }

  Future<void> _generateAndDownloadPDF(Receipt receipt) async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission required')),
            );
          }
          return;
        }
      }

      // Load custom font
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'RECEIPT VOUCHER',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Date: ${receipt.date}',
                          style: pw.TextStyle(fontSize: 14, font: ttf),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Divider(thickness: 1),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(3),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Field',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Details',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: ttf,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Receipt ID',
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              receipt.id?.toString() ?? 'New Receipt',
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Account Name',
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              receipt.accountName,
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Amount',
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '₹ ${receipt.amount.toStringAsFixed(2)}',
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Payment Mode',
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              receipt.paymentMode,
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Account Details',
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              selectedCashOption ?? receipt.paymentMode,
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Remarks',
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              receipt.remarks?.isEmpty ?? true
                                  ? 'N/A'
                                  : receipt.remarks!,
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 40),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Receiver Signature',
                            style: pw.TextStyle(font: ttf),
                          ),
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
                          pw.Text(
                            'Authorizer Signature',
                            style: pw.TextStyle(font: ttf),
                          ),
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
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Divider(thickness: 1),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Generated on: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
                          style: pw.TextStyle(fontSize: 10, font: ttf),
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

      final output = await getApplicationDocumentsDirectory();
      final fileName =
          'Receipt_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
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
      }
    } catch (e) {
      print('Error generating PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receipt != null
              ? 'Edit Receipt Voucher'
              : 'Add Receipt Voucher',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSaved)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                final receipt = Receipt(
                  id: widget.receipt?.id,
                  date: DateFormat('dd/MM/yyyy').format(selectedDate),
                  accountName: selectedAccount!,
                  amount: double.parse(_amountController.text),
                  paymentMode: selectedCashOption!,
                  remarks: _remarksController.text,
                );
                _generateAndDownloadPDF(receipt);
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
                      child: InkWell(
                        onTap: () => _showSearchableAccountDialog(context),
                        child: Container(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedAccount ?? 'Select an Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      selectedAccount != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Addaccountsdet(),
                        ),
                      );
                      if (result == true) {
                        await _loadBankCashOptions();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account added successfully'),
                            ),
                          );
                        }
                      }
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
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus(); // Dismiss keyboard
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
                        if (bankOptions.isNotEmpty) {
                          selectedCashOption = bankOptions.first;
                        }
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
                        selectedCashOption = 'Cash';
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
                          value:
                              paymentMode == 'Cash'
                                  ? (cashOptions.contains(selectedCashOption)
                                      ? selectedCashOption
                                      : cashOptions.first)
                                  : (bankOptions.contains(selectedCashOption)
                                      ? selectedCashOption
                                      : (bankOptions.isNotEmpty
                                          ? bankOptions.first
                                          : null)),
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCashOption = newValue!;
                              paymentMode =
                                  bankOptions.contains(newValue)
                                      ? 'Bank'
                                      : 'Cash';
                            });
                          },
                          items:
                              paymentMode == 'Cash'
                                  ? cashOptions.map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList()
                                  : bankOptions.map<DropdownMenuItem<String>>((
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
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Addaccountsdet(),
                        ),
                      );
                      if (result == true) {
                        await _loadBankCashOptions();
                      }
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
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus(); // Dismiss keyboard
                  },
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
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
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

class SearchableAccountDialog extends StatefulWidget {
  final Function(String) onAccountSelected;

  const SearchableAccountDialog({super.key, required this.onAccountSelected});

  @override
  State<SearchableAccountDialog> createState() =>
      _SearchableAccountDialogState();
}

class _SearchableAccountDialogState extends State<SearchableAccountDialog> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Select Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by Account Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().getAllData("TABLE_ACCOUNTSETTINGS"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<Map<String, dynamic>> items = [];
                  List<Map<String, dynamic>> allItems = snapshot.data ?? [];

                  if (searchQuery.isEmpty) {
                    items = allItems;
                  } else {
                    for (var item in allItems) {
                      try {
                        Map<String, dynamic> dat = jsonDecode(item["data"]);
                        String accountName = dat['Accountname'].toString();
                        if (accountName.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        )) {
                          items.add(item);
                        }
                      } catch (e) {
                        print('Error parsing account: $e');
                      }
                    }
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      Map<String, dynamic> dat = jsonDecode(item["data"]);
                      String accountName = dat['Accountname'].toString();

                      return ListTile(
                        title: Text(accountName),
                        onTap: () {
                          widget.onAccountSelected(accountName);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
