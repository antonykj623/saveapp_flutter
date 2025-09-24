import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:intl/intl.dart';
import '../../services/dbhelper/dbhelper.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import '../AccountSet_up/Add_Acount.dart';

class AddInvestment extends StatefulWidget {
  final String? accountName;

  const AddInvestment({super.key, this.accountName});

  @override
  State<AddInvestment> createState() => _SlidebleListState1();
}

class _SlidebleListState1 extends State<AddInvestment> {
  var items1 = ['Monthly', 'Fixed', 'Random'];
  List<String> items2 = [];
  List<Map<String, dynamic>> investmentData = [];
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController installmentAmountController =
      TextEditingController();
  final TextEditingController numberInstallmentsController =
      TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  String dropdownvalu = 'Monthly';
  String dropdownvalu1 = '';
  int selectedDay = 1;
  DateTime selected_startDate = DateTime.now();
  DateTime selected_endDate = DateTime.now();

  final dbhelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    loadAccounts();
    if (widget.accountName != null) {
      dropdownvalu1 = widget.accountName!;
      loadExistingData();
    }
    // Add listeners to auto-calculate closing date
    numberInstallmentsController.addListener(_calculateClosingDate);
  }

  @override
  void dispose() {
    numberInstallmentsController.removeListener(_calculateClosingDate);
    super.dispose();
  }

  Future<void> loadAccounts() async {
    try {
      // Get all investment account names from TABLE_ACCOUNTSETTINGS where Accounttype = 'Investment'
      List<Map<String, dynamic>> accounts = await dbhelper.getAllData(
        "TABLE_ACCOUNTSETTINGS",
      );
      List<String> investmentAccounts = [];

      for (var account in accounts) {
        try {
          Map<String, dynamic> accountData = jsonDecode(account["data"]);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();
          String accountName = accountData['Accountname'].toString();

          if (accountType == 'investment') {
            investmentAccounts.add(accountName);
          }
        } catch (e) {
          print('Error parsing account data: $e');
        }
      }

      setState(() {
        items2 = investmentAccounts;

        if (items2.isNotEmpty) {
          if (dropdownvalu1.isEmpty || !items2.contains(dropdownvalu1)) {
            dropdownvalu1 = items2.first;
          }
          _loadInvestmentAmount();
        } else {
          dropdownvalu1 = '';
        }
      });
    } catch (e) {
      print('Error loading accounts: $e');
    }
  }

  void _loadInvestmentAmount() async {
    if (dropdownvalu1.isNotEmpty) {
      try {
        // Calculate current investment balance based on transactions
        double currentBalance = await calculateInvestmentBalance(dropdownvalu1);
        totalAmountController.text = currentBalance.toStringAsFixed(2);
      } catch (e) {
        print('Error loading investment amount: $e');
      }
    }
  }

  // Calculate investment balance based on Payment and Receipt transactions
  Future<double> calculateInvestmentBalance(String accountName) async {
    try {
      final db = await dbhelper.database;

      // Get account setup ID
      String setupId = await getAccountSetupId(accountName);
      if (setupId == '0') {
        print('No setup ID found for account: $accountName');
        return 0.0;
      }

      // Get opening balance from account setup
      double openingBalance = await getAccountOpeningBalance(accountName);
      print('Opening balance for $accountName: $openingBalance');

      // Get all transactions for this investment account from TABLE_ACCOUNTS
      final List<Map<String, dynamic>> transactions = await db.query(
        'TABLE_ACCOUNTS',
        where: 'ACCOUNTS_setupid = ?',
        whereArgs: [setupId],
        orderBy: 'ACCOUNTS_id ASC',
      );

      double transactionBalance = 0.0;
      print('Found ${transactions.length} transactions for $accountName');

      for (var transaction in transactions) {
        try {
          double amount =
              double.tryParse(transaction['ACCOUNTS_amount'].toString()) ?? 0.0;
          String type = transaction['ACCOUNTS_type'].toString().toLowerCase();
          String remarks = transaction['ACCOUNTS_remarks']?.toString() ?? '';

          print('Transaction: Amount=$amount, Type=$type, Remarks=$remarks');

          if (type == 'debit') {
            // Payment to investment (money going into investment)
            transactionBalance += amount;
          } else if (type == 'credit') {
            // Receipt from investment (money coming out of investment)
            transactionBalance -= amount;
          }
        } catch (e) {
          print('Error parsing transaction: $e');
        }
      }

      double totalBalance = openingBalance + transactionBalance;
      print(
        'Final balance for $accountName: Opening($openingBalance) + Transactions($transactionBalance) = $totalBalance',
      );

      return totalBalance;
    } catch (e) {
      print('Error calculating investment balance for $accountName: $e');
      return 0.0;
    }
  }

  // Get account setup ID for given account name
  Future<String> getAccountSetupId(String accountName) async {
    try {
      final db = await dbhelper.database;
      final accounts = await db.query('TABLE_ACCOUNTSETTINGS');

      for (var account in accounts) {
        final dataValue = account['data'];
        if (dataValue != null) {
          Map<String, dynamic> data = jsonDecode(dataValue.toString());
          final storedAccountName = data['Accountname'];
          if (storedAccountName != null &&
              storedAccountName.toString().toLowerCase() ==
                  accountName.toLowerCase()) {
            final keyId = account['keyid'];
            return keyId?.toString() ?? '0';
          }
        }
      }
      return '0';
    } catch (e) {
      print('Error getting account setup ID: $e');
      return '0';
    }
  }

  // Get account opening balance
  Future<double> getAccountOpeningBalance(String accountName) async {
    try {
      final db = await dbhelper.database;
      final accounts = await db.query('TABLE_ACCOUNTSETTINGS');

      for (var account in accounts) {
        final dataValue = account['data'];
        if (dataValue != null) {
          Map<String, dynamic> data = jsonDecode(dataValue.toString());
          final storedAccountName = data['Accountname'];
          if (storedAccountName != null &&
              storedAccountName.toString().toLowerCase() ==
                  accountName.toLowerCase()) {
            final openingBalance = data['OpeningBalance'] ?? data['Amount'];
            return double.tryParse(openingBalance?.toString() ?? '0') ?? 0.0;
          }
        }
      }
      return 0.0;
    } catch (e) {
      print('Error getting opening balance: $e');
      return 0.0;
    }
  }

  Future<void> loadExistingData() async {
    if (dropdownvalu1 == 'My Savings') return;

    try {
      // Check if this investment already exists in INVESTNAMES_TABLE
      List<Map<String, dynamic>> investNames =
          await dbhelper.getAllInvestmentNames();
      bool exists = investNames.any(
        (item) => item['investname'] == dropdownvalu1,
      );

      if (exists) {
        Map<String, dynamic>? accountDetails = await dbhelper
            .getInvestmentDetailsByName(dropdownvalu1);
        if (accountDetails != null) {
          Map<String, dynamic> data = jsonDecode(accountDetails['data']);
          setState(() {
            dropdownvalu = data['investment_type'] ?? 'Monthly';
            totalAmountController.text = data['target_amount'] ?? '';
            installmentAmountController.text = data['installment_amount'] ?? '';
            numberInstallmentsController.text =
                data['number_of_installments'] ?? '';
            remarksController.text = data['remarks'] ?? '';
            selectedDay = int.tryParse(data['selected_day'] ?? '1') ?? 1;
            selected_startDate =
                DateTime.tryParse(data['payment_date'] ?? '') ?? DateTime.now();
            selected_endDate =
                DateTime.tryParse(data['closing_date'] ?? '') ?? DateTime.now();
          });
        }
      }
    } catch (e) {
      print('Error loading existing data: $e');
    }
  }

  void _calculateClosingDate() {
    if (numberInstallmentsController.text.isNotEmpty &&
        dropdownvalu == 'Monthly') {
      int installments = int.tryParse(numberInstallmentsController.text) ?? 0;
      if (installments > 0) {
        DateTime startMonth = DateTime(
          selected_startDate.year,
          selected_startDate.month,
          selectedDay,
        );
        DateTime calculatedEndDate = DateTime(
          startMonth.year,
          startMonth.month + installments,
          selectedDay,
        );

        if (calculatedEndDate.day != selectedDay) {
          calculatedEndDate = DateTime(
            calculatedEndDate.year,
            calculatedEndDate.month,
            0,
          );
        }

        setState(() {
          selected_endDate = calculatedEndDate;
        });
      }
    }
  }

  Future<int> getKeyId(String name) async {
    List<Map<String, dynamic>> rows = await dbhelper.getAllInvestmentNames();
    for (var row in rows) {
      if (row['investname'] == name) {
        return row['keyid'];
      }
    }
    return 0;
  }

  void selectDate(bool isStart) {
    showDatePicker(
      context: context,
      initialDate: isStart ? selected_startDate : selected_endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          if (isStart) {
            selected_startDate = pickedDate;
            _calculateClosingDate();
          } else {
            selected_endDate = pickedDate;
          }
        });
      }
    });
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Widget _buildDaySelector() {
    return Container(
      decoration: const ShapeDecoration(
        shape: BeveledRectangleBorder(
          side: BorderSide(width: .5, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
      ),
      child: DropdownButton<int>(
        isExpanded: true,
        value: selectedDay,
        icon: const Icon(Icons.keyboard_arrow_down),
        items:
            List.generate(31, (index) => index + 1).map((int day) {
              return DropdownMenuItem(value: day, child: Text('Day $day'));
            }).toList(),
        onChanged: (int? newDay) {
          setState(() {
            selectedDay = newDay!;
            _calculateClosingDate();
          });
        },
      ),
    );
  }

  Widget _buildFormBasedOnType() {
    switch (dropdownvalu) {
      case 'Monthly':
        return Column(
          children: [
            _buildDaySelector(),
            const SizedBox(height: 20),
            TextFormField(
              textAlign: TextAlign.end,
              enabled: true,
              controller: installmentAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                hintText: "Monthly Amount",
                fillColor: Colors.transparent,
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter monthly amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              enabled: true,
              controller: numberInstallmentsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                hintText: "Number of Installments",
                fillColor: Colors.transparent,
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number of installments';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => selectDate(true),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getFormattedDate(selected_startDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.teal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Auto End Date: ${getFormattedDate(selected_endDate)}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.grey),
                ],
              ),
            ),
          ],
        );

      case 'Fixed':
        return Column(
          children: [
            InkWell(
              onTap: () => selectDate(false),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selected_endDate != DateTime.now()
                          ? getFormattedDate(selected_endDate)
                          : 'Select Closing Date',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.teal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                hintText: "Enter Remarks",
                fillColor: Colors.transparent,
                filled: true,
              ),
            ),
          ],
        );

      case 'Random':
      default:
        return Column(
          children: [
            InkWell(
              onTap: () => selectDate(false),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selected_endDate != DateTime.now()
                          ? getFormattedDate(selected_endDate)
                          : 'Select Closing Date',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.teal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                hintText: "Enter Remarks",
                fillColor: Colors.transparent,
                filled: true,
              ),
            ),
          ],
        );
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
        title: const Text('Investments', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Investment Account Selection Row with Add Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const ShapeDecoration(
                        shape: BeveledRectangleBorder(
                          side: BorderSide(width: .5, style: BorderStyle.solid),
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value:
                            items2.contains(dropdownvalu1)
                                ? dropdownvalu1
                                : null,
                        hint: const Text('Select Investment Account'),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items:
                            items2.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                        onChanged: (String? newValue2) {
                          setState(() {
                            dropdownvalu1 = newValue2!;
                            _loadInvestmentAmount();
                            loadExistingData();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 40,
                    child: FloatingActionButton(
                      backgroundColor: Colors.red,
                      tooltip: 'Add Account',
                      shape: const CircleBorder(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Addaccountsdet(),
                          ),
                        ).then((result) {
                          if (result == true) {
                            loadAccounts();
                          }
                        });
                      },
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Target Amount Field
              TextFormField(
                textAlign: TextAlign.end,
                enabled: true,
                controller: totalAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintText: "Target Amount",
                  fillColor: Colors.transparent,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Investment Type Dropdown
              Container(
                decoration: const ShapeDecoration(
                  shape: BeveledRectangleBorder(
                    side: BorderSide(width: .5, style: BorderStyle.solid),
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: dropdownvalu,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items:
                      items1.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                  onChanged: (String? newValue2) {
                    setState(() {
                      dropdownvalu = newValue2!;
                      // Clear controllers when type changes
                      installmentAmountController.clear();
                      numberInstallmentsController.clear();
                      remarksController.clear();
                      selectedDay = 1;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic form based on investment type
              _buildFormBasedOnType(),

              const SizedBox(height: 50),

              // Save Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: () async {
                    if (dropdownvalu1.isEmpty ||
                        totalAmountController.text.isEmpty) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Please fill required fields',
                      );
                      return;
                    }

                    // Validation based on investment type
                    if (dropdownvalu == 'Monthly') {
                      if (installmentAmountController.text.isEmpty ||
                          numberInstallmentsController.text.isEmpty) {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          title: 'Please fill all monthly investment fields',
                        );
                        return;
                      }
                    }

                    await saveInvestmentData();
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced save method with proper data handling
  Future<void> saveInvestmentData() async {
    try {
      Map<String, dynamic> investmentDetails = {
        'Accountname': dropdownvalu1,
        'investment_type': dropdownvalu,
        'target_amount': totalAmountController.text,
        'installment_amount': installmentAmountController.text,
        'number_of_installments': numberInstallmentsController.text,
        'selected_day': selectedDay.toString(),
        'payment_date': selected_startDate.toIso8601String(),
        'closing_date': selected_endDate.toIso8601String(),
        'remarks': remarksController.text,
        'Accounttype': 'investment',
        'OpeningBalance': totalAmountController.text,
      };

      int keyid = await getKeyId(dropdownvalu1);
      bool isUpdate = keyid > 0;

      if (isUpdate) {
        // Update existing investment
        Map<String, dynamic>? existingDetails = await dbhelper
            .getInvestmentDetailsByName(dropdownvalu1);
        if (existingDetails != null) {
          Map<String, dynamic> currentData = jsonDecode(
            existingDetails['data'],
          );
          currentData.addAll(investmentDetails);

          int updateResult = await dbhelper.updateData(
            'TABLE_ACCOUNTSETTINGS',
            {'data': jsonEncode(currentData)},
            existingDetails['keyid'],
          );

          if (updateResult > 0) {
            await dbhelper.updateInvestmentName(keyid, dropdownvalu1);

            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'Investment updated successfully',
            );
            Navigator.pop(context);
          } else {
            throw Exception('Failed to update investment data');
          }
        }
      } else {
        // Insert new investment

        // First, add to INVESTNAMES_TABLE
        int newKeyId = await dbhelper.insertInvestmentName(dropdownvalu1);
        if (newKeyId <= 0) {
          throw Exception('Failed to create investment name entry');
        }

        // Then, update the existing account setup with investment details
        List<Map<String, dynamic>> accounts = await dbhelper.getAllData(
          "TABLE_ACCOUNTSETTINGS",
        );
        bool accountUpdated = false;

        for (var account in accounts) {
          try {
            Map<String, dynamic> accountData = jsonDecode(account["data"]);
            if (accountData['Accountname'].toString().toLowerCase() ==
                    dropdownvalu1.toLowerCase() &&
                accountData['Accounttype'].toString().toLowerCase() ==
                    'investment') {
              // Merge investment details with existing account data
              accountData.addAll(investmentDetails);

              int updateResult = await dbhelper.updateData(
                'TABLE_ACCOUNTSETTINGS',
                {'data': jsonEncode(accountData)},
                account['keyid'],
              );

              if (updateResult > 0) {
                accountUpdated = true;
                break;
              }
            }
          } catch (e) {
            print('Error updating account: $e');
          }
        }

        if (accountUpdated) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Investment saved successfully',
          );
          Navigator.pop(context);
        } else {
          throw Exception('Failed to update account with investment details');
        }
      }
    } catch (e) {
      print('Error saving investment: $e');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error: ${e.toString()}',
      );
    }
  }
}
