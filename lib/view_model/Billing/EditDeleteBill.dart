
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class EditBill extends StatefulWidget {
  final String billNumber;

  const EditBill({super.key, required this.billNumber});

  @override
  State<EditBill> createState() => _EditBillState();
}

class _EditBillState extends State<EditBill> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? selectedAccount;
  String? selectedIncomeAccount;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  List<String> accountNames = [];
  List<String> incomeAccountNames = [];
  String? customerSetupId;
  String? incomeSetupId;

  //	Load bill data & account options
  @override

  void initState() {
    super.initState();
    _loadBillData();
    _loadAccounts();
  }

  //Populate form fields from DB

  Future<void> _loadBillData() async {
    final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTS');
    for (var item in data) {
      if (item['ACCOUNTS_billVoucherNumber'] == widget.billNumber) {
        if (item['ACCOUNTS_type'] == 'credit') {
          setState(() {
            selectedDate = DateFormat('dd-MM-yyyy').parse(item['ACCOUNTS_date']);
            _amountController.text = item['ACCOUNTS_amount'];
            _remarksController.text = item['ACCOUNTS_remarks'] ?? '';
            customerSetupId = item['ACCOUNTS_setupid'];
          });
        } else if (item['ACCOUNTS_type'] == 'debit') {
          incomeSetupId = item['ACCOUNTS_setupid'];
        }
      }
    }
    // Resolve account names
    if (customerSetupId != null) {
      selectedAccount = await _getAccountName(customerSetupId!);
    }
    if (incomeSetupId != null) {
      selectedIncomeAccount = await _getAccountName(incomeSetupId!);
    }
    setState(() {});
  }


  //	Load account options from DB

  Future<void> _loadAccounts() async {
    final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTSETTINGS');
    setState(() {
      for (var i in data) {
        Map<String, dynamic> dat = jsonDecode(i["data"]);
        if (dat['Accounttype'].toString().contains("Customers")) {
          accountNames.add(dat['Accountname'].toString());
        }
        if (dat['Accounttype'].toString().contains("Income Account")) {
          incomeAccountNames.add(dat['Accountname'].toString());
        }
      }
    });
  }

  //Convert setup ID to name

  Future<String> _getAccountName(String id) async {
    try {
      List<Map<String, dynamic>> allRows = await DatabaseHelper().queryallacc();
      for (var row in allRows) {
        if (row['keyid'].toString() == id) {
          Map<String, dynamic> dat = jsonDecode(row["data"]);
          return dat['Accountname'].toString();
        }
      }
      return 'Unknown Account';
    } catch (e) {
      print("Error getting account name: $e");
      return 'Error';
    }
  }


  //	Convert name to setup ID

  Future<String> getNextSetupId(String name) async {
    try {
      String maxId = "0";
      List<Map<String, dynamic>> allRows = await DatabaseHelper().queryallacc();
      for (var row in allRows) {
        Map<String, dynamic> dat = jsonDecode(row["data"]);
        if (dat['Accountname'].toString() == name) {
          maxId = row['keyid'].toString();
          break;
        }
      }
      return maxId;
    } catch (e) {
      print("Error getting setup ID: $e");
      return '0';
    }
  }


  //	Show date picker

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Edit Bill', style: TextStyle(color: Colors.white)),
      ),
      body: selectedDate == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    const Text('Bill no: '),
                    Text(
                      widget.billNumber,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
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
                        DateFormat('dd-MM-yyyy').format(selectedDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedAccount,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: accountNames.map((String account) {
                      return DropdownMenuItem<String>(
                        value: account,
                        child: Text(account),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAccount = newValue;
                      });
                    },
                    hint: const Text('Select Customer Account'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedIncomeAccount,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: incomeAccountNames.map((String account) {
                      return DropdownMenuItem<String>(
                        value: account,
                        child: Text(account),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedIncomeAccount = newValue;
                      });
                    },
                    hint: const Text('Select Income Account'),
                  ),
                ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),

                    //Update DB with new values
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final date = DateFormat('dd-MM-yyyy').format(selectedDate!);
                        final year = selectedDate!.year.toString();
                        final month = selectedDate!.month.toString();
                        final amount = _amountController.text;
                        final remarks = _remarksController.text;

                        String newCustomerSetupId = await getNextSetupId(selectedAccount!);
                        String newIncomeSetupId = await getNextSetupId(selectedIncomeAccount!);

                        // Update credit entry
                        Map<String, dynamic> creditDatas = {
                          "ACCOUNTS_date": date,
                          "ACCOUNTS_billVoucherNumber": widget.billNumber,
                          "ACCOUNTS_amount": amount,
                          "ACCOUNTS_setupid": newCustomerSetupId,
                          "ACCOUNTS_VoucherType": "3",
                          "ACCOUNTS_type": "credit",
                          "ACCOUNTS_remarks": remarks,
                          "ACCOUNTS_year": year,
                          "ACCOUNTS_month": month,
                          "ACCOUNTS_cashbanktype": "0",
                          "ACCOUNTS_billId": "0",
                        };

                        // Update debit entry
                        Map<String, dynamic> debitDatas = {
                          "ACCOUNTS_date": date,
                          "ACCOUNTS_billVoucherNumber": widget.billNumber,
                          "ACCOUNTS_amount": amount,
                          "ACCOUNTS_setupid": newIncomeSetupId,
                          "ACCOUNTS_VoucherType": "3",
                          "ACCOUNTS_type": "debit",
                          "ACCOUNTS_remarks": remarks,
                          "ACCOUNTS_year": year,
                          "ACCOUNTS_month": month,
                          "ACCOUNTS_cashbanktype": "0",
                          "ACCOUNTS_billId": "0",
                        };

                        // Update database
                        final db = await DatabaseHelper().database;
                        await db.update(
                          'TABLE_ACCOUNTS',
                          creditDatas,
                          where: 'ACCOUNTS_billVoucherNumber = ? AND ACCOUNTS_type = ?',
                          whereArgs: [widget.billNumber, 'credit'],
                        );
                        await db.update(
                          'TABLE_ACCOUNTS',
                          debitDatas,
                          where: 'ACCOUNTS_billVoucherNumber = ? AND ACCOUNTS_type = ?',
                          whereArgs: [widget.billNumber, 'debit'],
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bill updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),

                    //Confirm & delete entry
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text('Are you sure you want to delete this bill?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final db = await DatabaseHelper().database;
                                await db.delete(
                                  'TABLE_ACCOUNTS',
                                  where: 'ACCOUNTS_billVoucherNumber = ?',
                                  whereArgs: [widget.billNumber],
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Bill deleted successfully!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                Navigator.pop(context);
                                Navigator.pop(context, true);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
