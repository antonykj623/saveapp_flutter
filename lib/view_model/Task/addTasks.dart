import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view_model/VisitingCard/test.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBill extends StatefulWidget {
  final Payment? payment;

  const AddBill({super.key, this.payment});

  @override
  State<AddBill> createState() => _AddPaymentVoucherPageState();
}

class _AddPaymentVoucherPageState extends State<AddBill> {
  int _counter = 0;

  Future<void> _incrementCounterAutomatically() async {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('counter') ?? 0;
    counter++;
    await prefs.setInt('counter', counter);

    setState(() {
      _counter = counter;
    });
  }

  String name = "";
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate = DateTime.now();
  String? selectedAccount;
  String? selectedincomeAccount;
  final TextEditingController _amountController = TextEditingController();
  String paymentMode = 'Cash';
  String? selectedCashOption;
  final TextEditingController _remarksController = TextEditingController();
  var dropdownvalu1 = 'Asset Account';
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _items1 = [];
  List<String> accountNames = [];
  List<String> incomeaccountNames = [];
  String eid = "";

  // var items1 = [
  //   'Asset Account',
  //   'Bank',
  //   'Cash',
  //   'Credit Card',
  //   'Customers',
  //   'Expense Account',
  //   'Income Account',
  //   'Insurance',
  //   'Investment',
  //   'Liability Account',
  // ];
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
    _loadItemsFromDB();
    _loadaccountFromDB();
    _incrementCounterAutomatically();
  }

  Future<void> _loadaccountFromDB() async {
    final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTSETTINGS');
    setState(() {
      _items1 = data;
      for (var i in _items1) {
        Map<String, dynamic>dat = jsonDecode(i["data"]);
        if (dat['Accounttype'].toString().contains("Income Account")) {
          incomeaccountNames.add(dat['Accountname'].toString());
        }
      }
      // Extract account names from the database
      // accountNames = _items
      //     .map((item) => jsonDecode(item['data'])['Accountname'].toString() )
      //     .toList();
      // Set default selected account if available
      selectedincomeAccount =
      incomeaccountNames.isNotEmpty ? incomeaccountNames[0] : null;
    });
  }

  Future<void> _loadItemsFromDB() async {
    final data = await DatabaseHelper().getAllData('TABLE_ACCOUNTSETTINGS');
    setState(() {
      _items = data;
      for (var i in _items) {
        Map<String, dynamic>dat = jsonDecode(i["data"]);
        if (dat['Accounttype'].toString().contains("Customers")) {
          accountNames.add(dat['Accountname'].toString());
        }
      }
      // Extract account names from the database
      // accountNames = _items
      //     .map((item) => jsonDecode(item['data'])['Accountname'].toString() )
      //     .toList();
      // Set default selected account if available
      selectedAccount = accountNames.isNotEmpty ? accountNames[0] : null;
    });
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Add Bill', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
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
                    Text('Bill no                                      :'),
                    Text(
                      ' Save_Bill_000 $_counter ',
                      style: TextStyle(fontSize: 14),
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
                          hint: const Text('Select Account'),
                        ),
                      ),


                    ),
                  ),


                  const SizedBox(width: 16),

                  Container(


                    child: FloatingActionButton(
                      backgroundColor: Colors.red,
                      tooltip: 'Increment',
                      shape: const CircleBorder(),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (
                            context) => Addaccountsdet()));
                      },
                      child: const Icon(
                          Icons.add, color: Colors.white, size: 25),
                    ),


                  ),
                ],
              ),


              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                  ),


                ],
              ),


              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedincomeAccount,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: incomeaccountNames.map((String account) {
                            return DropdownMenuItem<String>(
                              value: account,
                              child: Text(account),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedincomeAccount = newValue;
                            });
                          },
                          hint: const Text('Select Income Account'),
                        ),
                      ),


                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: FloatingActionButton(
                        backgroundColor: Colors.red,
                        tooltip: 'Increment',
                        shape: const CircleBorder(),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Addaccountsdet()));
                        },
                        child: const Icon(
                            Icons.add, color: Colors.white, size: 25),
                      ),
                    ),
                  ),
                ],),


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
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Processing Data')),
                        );

                        final billno = _counter;
                        final date = selectedDate;
                        DateTime date1 = selectedDate!;
                        int year = date1.year;
                        int month = date1.month;
                        final customersdata = selectedAccount;
                        final amount = _amountController.text;
                        final income = selectedincomeAccount;
                        final remarks = _remarksController.text;

                        Future<String> getNextSetupId(name) async {
                          try {
                            String maxId = "0";
                            List<Map<String,
                                dynamic>> allrows = await DatabaseHelper()
                                .queryallacc();

                            allrows.forEach((row) {
                              Map<String, dynamic> dat = jsonDecode(
                                  row["data"]);
                              if (dat['Accountname'].toString().compareTo(
                                  name) == 0) {
                                maxId = row['keyid'].toString();
                              }
                            });

                            return maxId;
                          } catch (e) {
                            return '0';
                          }
                        }

                        String setid = await getNextSetupId(customersdata
                            .toString());

                        // Credit entry
                        Map<String, dynamic> creditDatas = {
                          "ACCOUNTS_date": DateFormat('yyyy-MM-dd').format(
                              selectedDate!),
                          // Fixed format
                          "ACCOUNTS_billVoucherNumber": billno.toString(),
                          "ACCOUNTS_amount": amount,
                          "ACCOUNTS_setupid": setid,
                          "ACCOUNTS_VoucherType": 3,
                          // Remove quotes for integer
                          "ACCOUNTS_entryid": "0",
                          "ACCOUNTS_type": "credit",
                          "ACCOUNTS_remarks": remarks,
                          "ACCOUNTS_year": year.toString(),
                          "ACCOUNTS_month": month.toString(),
                          "ACCOUNTS_cashbanktype": "0",
                          "ACCOUNTS_billId": "0",
                        };

                        final id = await DatabaseHelper().insertData(
                            "TABLE_ACCOUNTS", creditDatas);
                        if (id != null) {
                          print("credit data inserted...$id");
                        }

                        String setupid = await getNextSetupId(income
                            .toString());

                        // Debit entry
                        Map<String, dynamic> debitDatas = {
                          "ACCOUNTS_date": DateFormat('yyyy-MM-dd').format(
                              selectedDate!),
                          // Fixed format
                          "ACCOUNTS_billVoucherNumber": billno.toString(),
                          "ACCOUNTS_amount": amount,
                          "ACCOUNTS_setupid": setupid,
                          "ACCOUNTS_VoucherType": 3,
                          // Remove quotes for integer
                          "ACCOUNTS_entryid": id.toString(),
                          "ACCOUNTS_type": "debit",
                          "ACCOUNTS_remarks": remarks,
                          "ACCOUNTS_year": year.toString(),
                          "ACCOUNTS_month": month.toString(),
                          "ACCOUNTS_cashbanktype": "0",
                          "ACCOUNTS_billId": "0",
                        };

                        var debtdata = await DatabaseHelper().insertData(
                            "TABLE_ACCOUNTS", debitDatas);
                        if (debtdata != null) {
                          print("debt data inserted...$debtdata");

                          Navigator.pop(context, true);
                        }

                        print("Value inserted");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // background (button) color
                      foregroundColor: Colors.white, // foreground (text) color
                    ),

                    child: Text(
                      "Save",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),



                ],),

      
            ],
          ),
        ),
      ),
    );
  }
}


