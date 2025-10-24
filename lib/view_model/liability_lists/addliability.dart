import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:new_project_2025/view_model/liability_lists/liabilityaccount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:intl/intl.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';


class LiabilityFormPage extends StatefulWidget {
  String id;
  Map<String, dynamic> map;

  LiabilityFormPage(this.id, this.map);

  @override
  _LiabilityFormPageState createState() => _LiabilityFormPageState(this.id, this.map);
}

class _LiabilityFormPageState extends State<LiabilityFormPage> {
  String id;
  Map<String, dynamic> map;

  _LiabilityFormPageState(this.id, this.map);

  String? liabilityType = "EMI";
  TextEditingController openingBalanceController = TextEditingController();
  TextEditingController emiAmountController = TextEditingController();
  TextEditingController numberOfEmiController = TextEditingController();

  DateTime? paymentDate;
  DateTime? closingDate;
  DateTime? reminddate;

  LiabilityAccount? selectedAccount;
  List<LiabilityAccount> accounts = [];
  String accountsetupid = "0";
  int _currentValue = 0;

  List<String> liabilityTypes = ['EMI', 'NON EMI'];

  Future<void> _pickDate(BuildContext context, bool isPaymentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isPaymentDate) {
          closingDate = picked;
        } else {
          reminddate = picked;
        }
      });
    }
  }

  Widget _buildDatePickerTile(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label : "${date.day}/${date.month}/${date.year}",
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  int monthsBetween(DateTime startDate, DateTime endDate) {
    return ((endDate.year - startDate.year) * 12 + endDate.month - startDate.month);
  }

  Future<void> _saveForm() async {
    print("Form Saved");

    // Validate selected account first
    if (selectedAccount == null) {
      showMyAlertDialog(context, "", "Please select a liability account");
      return;
    }

    if (liabilityType!.compareTo("EMI") == 0) {
      // EMI Validation
      if (emiAmountController.text.trim().isEmpty) {
        showMyAlertDialog(context, "", "Enter EMI Amount");
        return;
      }

      if (numberOfEmiController.text.isEmpty) {
        showMyAlertDialog(context, "", "Enter number of EMI");
        return;
      }

      if (_currentValue == 0) {
        showMyAlertDialog(context, "", "Select Payment date");
        return;
      }

      if (closingDate == null) {
        showMyAlertDialog(context, "", "Select Closing date");
        return;
      }

      if (reminddate == null) {
        showMyAlertDialog(context, "", "Select Remind date");
        return;
      }

      // Create JSON object for EMI
      Map<String, dynamic> jsonObject = {
        "loantype": liabilityType.toString(),
        "amount": emiAmountController.text.trim(),
        "emicount": numberOfEmiController.text.trim(),
        "loan": selectedAccount!.id,
        "loan_account": selectedAccount!.data,
        "Paymentdate": _currentValue.toString(),
        "Closingdate": "${closingDate!.day}-${closingDate!.month}-${closingDate!.year}",
        "remiddate": "${reminddate!.day}-${reminddate!.month}-${reminddate!.year}",
        "openingbalance": openingBalanceController.text,
        "dateofpayment": _currentValue.toString(),
      };

      String jsonString = jsonEncode(jsonObject);
      Map<String, dynamic> mp = {"data": jsonString};

      int result = 0;
      // FIXED: Check if editing (id != "0") vs creating new
      if (id != "0" && id.isNotEmpty) {
        result = await DatabaseHelper().update(mp, id, "TABLE_LIABILITY");
        print("Updated liability ID: $id, Result: $result");
      } else {
        result = await DatabaseHelper().insert(mp, "TABLE_LIABILITY");
        print("Inserted new liability, Result: $result");
      }

      if (result > 0) {
        // Update account balance
        Map<String, dynamic> mpp = jsonDecode(selectedAccount!.jsondata);
        mpp["Amount"] = openingBalanceController.text.toString();
        Map<String, dynamic> acc = {"data": jsonEncode(mpp)};
        await DatabaseHelper().update(acc, selectedAccount!.id, "TABLE_ACCOUNTSETTINGS");

        // Create tasks for EMI payments
        DateTime now = DateTime.now();
        String ab = _currentValue.toString() + "-" + now.month.toString() + "-" + now.year.toString();
        DateTime dt = DateFormat("dd-MM-yyyy").parse(ab);
        DateTime calendar1 = dt;
        int a = monthsBetween(calendar1, closingDate!);

        for (int i = 0; i < a; i++) {
          if (calendar1.isBefore(closingDate!)) {
            int currd = calendar1.day;
            int m1 = calendar1.month;
            int currYear = calendar1.year;

            Map<String, dynamic> task = {
              "name": selectedAccount!.data,
              "date": "${currd}-${m1}-${currYear}",
              "time": TimeOfDay(hour: now.hour, minute: now.minute).format(context),
              "status": 0,
              "reminddate": "${currd}-${m1}-${currYear}",
              "remindPeriod": "Monthly",
            };

            Map<String, dynamic> mpTask = {"data": jsonEncode(task)};
            await DatabaseHelper().insert(mpTask, "TABLE_TASK");

            calendar1 = DateTime(calendar1.year, calendar1.month + 1, calendar1.day);
            a = monthsBetween(calendar1, closingDate!);
          }
        }

        setState(() {
          emiAmountController.clear();
          openingBalanceController.clear();
          numberOfEmiController.clear();
        });

        // Navigate back with success result
        Navigator.pop(context, true);
      } else {
        showMyAlertDialog(context, "Error", "Failed to save liability");
      }
    } else {
      // NON EMI Validation
      if (emiAmountController.text.trim().isEmpty) {
        showMyAlertDialog(context, "", "Enter Amount");
        return;
      }

      if (_currentValue == 0) {
        showMyAlertDialog(context, "", "Select Payment date");
        return;
      }

      if (closingDate == null) {
        showMyAlertDialog(context, "", "Select Closing date");
        return;
      }

      if (reminddate == null) {
        showMyAlertDialog(context, "", "Select Remind date");
        return;
      }

      // Create JSON object for NON EMI
      Map<String, dynamic> jsonObject = {
        "loantype": liabilityType.toString(),
        "amount": emiAmountController.text.trim(),
        "emicount": "0",
        "loan": selectedAccount!.id,
        "loan_account": selectedAccount!.data,
        "Paymentdate": _currentValue.toString(),
        "Closingdate": "${closingDate!.day}-${closingDate!.month}-${closingDate!.year}",
        "remiddate": "${reminddate!.day}-${reminddate!.month}-${reminddate!.year}",
        "openingbalance": openingBalanceController.text,
        "dateofpayment": _currentValue.toString(),
      };

      String jsonString = jsonEncode(jsonObject);
      Map<String, dynamic> mp = {"data": jsonString};

      int result = 0;
      // FIXED: Check if editing vs creating new
      if (id != "0" && id.isNotEmpty) {
        result = await DatabaseHelper().update(mp, id, "TABLE_LIABILITY");
        print("Updated liability ID: $id, Result: $result");
      } else {
        result = await DatabaseHelper().insert(mp, "TABLE_LIABILITY");
        print("Inserted new liability, Result: $result");
      }

      if (result > 0) {
        // Update account balance
        Map<String, dynamic> mpp = jsonDecode(selectedAccount!.jsondata);
        mpp["Amount"] = openingBalanceController.text.toString();
        Map<String, dynamic> acc = {"data": jsonEncode(mpp)};
        await DatabaseHelper().update(acc, selectedAccount!.id, "TABLE_ACCOUNTSETTINGS");

        // Create one-time task
        DateTime now = DateTime.now();
        Map<String, dynamic> task = {
          "name": selectedAccount!.data,
          "date": "${_currentValue}-${now.month}-${now.year}",
          "time": TimeOfDay(hour: now.hour, minute: now.minute).format(context),
          "status": 0,
          "reminddate": "${reminddate!.day}-${reminddate!.month}-${reminddate!.year}",
          "remindPeriod": "One Time",
        };

        Map<String, dynamic> mp1 = {"data": jsonEncode(task)};
        await DatabaseHelper().insert(mp1, "TABLE_TASK");

        setState(() {
          emiAmountController.clear();
          openingBalanceController.clear();
        });

        // Navigate back with success result
        Navigator.pop(context, true);
      } else {
        showMyAlertDialog(context, "Error", "Failed to save liability");
      }
    }
  }

  void showMyAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getAllAccounts() async {
    List<Map<String, dynamic>> mpd = await DatabaseHelper().getAllData("TABLE_ACCOUNTSETTINGS");
    List<LiabilityAccount> mapName = [];

    for (int i = 0; i < mpd.length; i++) {
      String account = mpd[i]["data"];
      Map<String, dynamic> mpp = jsonDecode(account);

      if (mpp["Accounttype"].toString().compareTo("Liability Account") == 0) {
        LiabilityAccount iacc = LiabilityAccount();
        // FIXED: Use 'keyid' instead of 'id'
        iacc.id = mpd[i]["keyid"].toString();
        iacc.data = mpp["Accountname"].toString();
        iacc.jsondata = account;
        mapName.add(iacc);
      }
    }

    setState(() {
      accounts = mapName;
      if (accounts.isNotEmpty) {
        // FIXED: Better handling of account selection
        if (id != "0" && id.isNotEmpty && map.isNotEmpty) {
          accountsetupid = map["loan"].toString();
          for (int i = 0; i < accounts.length; i++) {
            if (accounts[i].id.toString() == accountsetupid) {
              selectedAccount = accounts[i];
              Map<String, dynamic> mpp = jsonDecode(selectedAccount!.jsondata);
              openingBalanceController.text = mpp["Amount"].toString();
              break;
            }
          }
        } else {
          selectedAccount = accounts[0];
          accountsetupid = selectedAccount!.id;
          Map<String, dynamic> mpp = jsonDecode(selectedAccount!.jsondata);
          openingBalanceController.text = mpp["Amount"].toString();
        }
      }
    });
  }

  Future<void> _addNewProvider() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("account_type", "Liability Account");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Addaccountsdet()),
    );

    if (result != null) {
      getAllAccounts();
    }
  }

  Future<void> _showNumberPickerDialog() async {
    int tempValue = _currentValue;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pick a payment date"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return NumberPicker(
                value: tempValue == 0 ? 1 : tempValue,
                minValue: 1,
                maxValue: 31,
                step: 1,
                itemHeight: 50,
                axis: Axis.vertical,
                onChanged: (value) => setStateDialog(() => tempValue = value),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() => _currentValue = tempValue);

                int a1 = 0;
                if (numberOfEmiController.text.toString().trim().isNotEmpty) {
                  a1 = int.parse(numberOfEmiController.text.toString());
                }

                if (a1 > 0 && _currentValue > 0) {
                  DateTime dt = DateTime.now();
                  String ab = _currentValue.toString() + "-" + dt.month.toString() + "-" + dt.year.toString();
                  DateFormat format = DateFormat("dd-MM-yyyy");
                  DateTime parsedDate = format.parse(ab);
                  setState(() {
                    closingDate = DateTime(parsedDate.year, parsedDate.month + a1, parsedDate.day);
                  });
                } else {
                  setState(() {
                    closingDate = null;
                  });
                }

                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getAllAccounts();
    setData();
  }

  void setData() {
    setState(() {
      if (map.isNotEmpty) {
        liabilityType = map["loantype"];
        emiAmountController.text = map["amount"];
        numberOfEmiController.text = map["emicount"];
        _currentValue = int.parse(map["Paymentdate"]);
        closingDate = DateFormat("dd-MM-yyyy").parse(map["Closingdate"]);
        reminddate = DateFormat("dd-MM-yyyy").parse(map["remiddate"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id == "0" || id.isEmpty ? "Add Liability" : "Edit Liability"),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: liabilityType,
              hint: Text("Select Liability Type"),
              items: liabilityTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  liabilityType = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<LiabilityAccount>(
                    isExpanded: true,
                    value: selectedAccount,
                    hint: const Text("Select Liability Account"),
                    items: accounts.map((LiabilityAccount account) {
                      return DropdownMenuItem<LiabilityAccount>(
                        value: account,
                        child: Text(account.data ?? ""),
                      );
                    }).toList(),
                    onChanged: (LiabilityAccount? value) {
                      setState(() {
                        selectedAccount = value;
                        accountsetupid = selectedAccount!.id.toString();
                      });
                      print("Selected ID: ${value?.id}, Name: ${value?.data}");

                      String d = value!.jsondata;
                      Map<String, dynamic> mpp = jsonDecode(d);
                      setState(() {
                        openingBalanceController.text = mpp["Amount"].toString();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  mini: true,
                  onPressed: _addNewProvider,
                  child: Icon(Icons.add),
                  backgroundColor: Colors.pink,
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: openingBalanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Opening Balance",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emiAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: (liabilityType!.compareTo("EMI") == 0) ? "EMI Amount" : "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            if (liabilityType!.compareTo("EMI") == 0) ...[
              TextField(
                controller: numberOfEmiController,
                keyboardType: TextInputType.number,
                onChanged: (a) {
                  int a1 = 0;
                  if (a.toString().trim().isNotEmpty) {
                    a1 = int.parse(a);
                  }

                  if (a1 > 0 && _currentValue > 0) {
                    DateTime dt = DateTime.now();
                    String ab = _currentValue.toString() + "-" + dt.month.toString() + "-" + dt.year.toString();
                    DateFormat format = DateFormat("dd-MM-yyyy");
                    DateTime parsedDate = format.parse(ab);
                    setState(() {
                      closingDate = DateTime(parsedDate.year, parsedDate.month + a1, parsedDate.day);
                    });
                  } else {
                    setState(() {
                      closingDate = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: "Number of EMI",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
            ],
            InkWell(
              onTap: () {
                _showNumberPickerDialog();
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "Select Date Of Payment",
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentValue == 0 ? "No date selected" : _currentValue.toString(),
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildDatePickerTile(
              "Select Closing Date",
              closingDate,
              () => _pickDate(context, true),
            ),
            SizedBox(height: 16),
            _buildDatePickerTile(
              "Select Remind Date",
              reminddate,
              () => _pickDate(context, false),
            ),
            SizedBox(height: 24),
            Container(
              width: 150,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.green],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextButton(
                onPressed: _saveForm,
                child: Text(
                  id == "0" || id.isEmpty ? "Save" : "Update",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}