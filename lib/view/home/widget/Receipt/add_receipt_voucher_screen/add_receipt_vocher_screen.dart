import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:new_project_2025/view/home/widget/Receipt/Receipt_class/receipt_class.dart';
import 'package:new_project_2025/view/home/widget/Receipt/receipt_database/receipt_database.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
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

  List<String> cashOptions = ['Cash'];
  List<String> bankOptions = [];
  List<String> allBankCashOptions = [];

  @override
  void initState() {
    super.initState();
    _loadBankCashOptions();

    if (widget.receipt != null) {
      selectedDate = DateFormat('yyyy-MM-dd').parse(widget.receipt!.date);
      selectedAccount = widget.receipt!.accountName;
      _amountController.text = widget.receipt!.amount.toString();
      paymentMode = widget.receipt!.paymentMode;
      selectedCashOption = widget.receipt!.paymentMode;
      _remarksController.text = widget.receipt!.remarks ?? '';
    } else {
      selectedDate = DateTime.now();
    }
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
      if (context.mounted) {
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

  void _saveReceipt() async {
    if (_formKey.currentState!.validate()) {
      if (selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an account')),
        );
        return;
      }

      try {
        final receipt = Receipt(
          id: widget.receipt?.id,
          date: DateFormat('yyyy-MM-dd').format(selectedDate),
          accountName: selectedAccount!,
          amount: double.parse(_amountController.text),
          paymentMode: selectedCashOption!,
          remarks: _remarksController.text,
        );

        int receiptId;
        if (widget.receipt == null) {
          receiptId = await DatabaseHelper1.instance.insertReceipt(receipt);
        } else {
          receiptId = widget.receipt!.id!;
          await DatabaseHelper1.instance.updateReceipt(receipt);
        }

        await _saveDoubleEntryAccounts(receiptId, receipt);

        setState(() {
          _isSaved = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt saved successfully')),
        );
        _showDownloadPdfDialog(receipt);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving receipt: $e')));
      }
    }
  }

  Future<void> _saveDoubleEntryAccounts(int receiptId, Receipt receipt) async {
    final db = await DatabaseHelper().database;
    final currentDate = DateTime.now();
    final dateString =
        "${currentDate.day}/${currentDate.month}/${currentDate.year}";
    final monthString = _getMonthName(currentDate.month);
    final yearString = currentDate.year.toString();

    final setupId = await getNextSetupId(receipt.accountName);
    final contraAccount =
        receipt.paymentMode == 'Cash' ? 'Cash' : receipt.paymentMode;
    final contraSetupId = await getNextSetupId(contraAccount);

    Map<String, dynamic> cashBankEntry = {
      'ACCOUNTS_VoucherType': 2,
      'ACCOUNTS_entryid': receiptId.toString(),
      'ACCOUNTS_date': dateString,
      'ACCOUNTS_setupid': contraSetupId,
      'ACCOUNTS_amount': receipt.amount.toString(),
      'ACCOUNTS_type': 'debit',
      'ACCOUNTS_remarks': 'Receipt from ${receipt.accountName}',
      'ACCOUNTS_year': yearString,
      'ACCOUNTS_month': monthString,
      'ACCOUNTS_cashbanktype': receipt.paymentMode == 'Cash' ? '1' : '2',
      'ACCOUNTS_billId': '',
      'ACCOUNTS_billVoucherNumber': '',
    };

    Map<String, dynamic> accountEntry = {
      'ACCOUNTS_VoucherType': 2, // Receipt voucher
      'ACCOUNTS_entryid': receiptId.toString(),
      'ACCOUNTS_date': dateString,
      'ACCOUNTS_setupid': setupId,
      'ACCOUNTS_amount': receipt.amount.toString(),
      'ACCOUNTS_type': 'credit', // Customer/Income credited
      'ACCOUNTS_remarks': 'Receipt to $contraAccount',
      'ACCOUNTS_year': yearString,
      'ACCOUNTS_month': monthString,
      'ACCOUNTS_cashbanktype': receipt.paymentMode == 'Cash' ? '1' : '2',
      'ACCOUNTS_billId': '',
      'ACCOUNTS_billVoucherNumber': '',
    };

    await db.transaction((txn) async {
      await txn.insert('TABLE_ACCOUNTS', cashBankEntry);
      await txn.insert('TABLE_ACCOUNTS', accountEntry);
    });

    final isBalanced = await DatabaseHelper().validateDoubleEntry();
    if (!isBalanced) {
      throw Exception('Double-entry accounting is unbalanced');
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
    );
  }

  Future<void> _generateAndDownloadPDF(Receipt receipt) async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission required')),
          );
          return;
        }
      }

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

      final output = await getApplicationDocumentsDirectory();
      final fileName =
          'Receipt_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

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
          onPressed: () => Navigator.pop(context),
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
                    paymentMode: selectedCashOption!,
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
                      child: InkWell(
                        onTap: () => _showSearchableAccountDialog(context),
                        child: Container(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedAccount ?? 'Select An Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      selectedAccount != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                ),
                              ),
                              Icon(Icons.arrow_drop_down),
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
                        if (context.mounted) {
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
                    if (value == null || value.isEmpty)
                      return 'Please enter an amount';
                    if (double.tryParse(value) == null)
                      return 'Please enter a valid number';
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
                        if (bankOptions.isNotEmpty)
                          selectedCashOption = bankOptions.first;
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
                  const Text("cash"),
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
                                  ? cashOptions
                                      .map<DropdownMenuItem<String>>(
                                        (String value) =>
                                            DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            ),
                                      )
                                      .toList()
                                  : bankOptions
                                      .map<DropdownMenuItem<String>>(
                                        (String value) =>
                                            DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            ),
                                      )
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
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Addaccountsdet(),
                        ),
                      );
                      if (result == true) _loadBankCashOptions();
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
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by Account Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().getAllData("TABLE_ACCOUNTSETTINGS"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text('Error: ${snapshot.error}'));

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
                        ))
                          items.add(item);
                      } catch (e) {}
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
