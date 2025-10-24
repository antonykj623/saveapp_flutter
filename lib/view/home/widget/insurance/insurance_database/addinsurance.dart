import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/InsuranceAccount.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:shared_preferences/shared_preferences.dart';



class InsuranceFormPage extends StatefulWidget {

String id;

Map<String,dynamic>map;


  InsuranceFormPage(this.id,this.map);


  @override
  _InsuranceFormPageState createState() => _InsuranceFormPageState(this.id,this.map);
}

class _InsuranceFormPageState extends State<InsuranceFormPage> {


  String id;

  Map<String,dynamic>map;



  _InsuranceFormPageState(this.id,this.map);


  String? selectedProvider;
  String? selectedInsuranceType="";

  DateTime? _selectedClosingDate;

  String datemonth="";

  String accountsetupid="";

  final TextEditingController amountController = TextEditingController();
  final TextEditingController premiumController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  final List<String> providers = ['LIC', 'HDFC', 'Star Health'];
  List<InsuranceAccount> accounts = [

  ];

  InsuranceAccount? selectedAccount;
  final List<String> insuranceTypes = [
    'Quarterly',
    'Half yearly',
    'Monthly',
    'Yearly',
  ];

  Future<void> _addNewProvider() async {
    // Optionally show a dialog to add a new provider
    final prefs = await SharedPreferences.getInstance();

prefs.setString("account_type","Insurance");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>Addaccountsdet()),
    );

    if (result != null||result==null) {


      getAllAccounts();
    }

  }

  void _saveInsurance() {
    // TODO: Implement save logic
    print("Saved Insurance");
    if (selectedAccount!=null) {
    if (premiumController.text.isNotEmpty) {

      if(_dateController.text.isNotEmpty)
        {
          if(_selectedClosingDate!=null)
          {


            if(map.length>0)
              {
                Map<String, dynamic> jsonObject = {
                  "insurance_no": accountsetupid,
                  "account": selectedAccount!.data,
                  "amount": premiumController.text,
                  // TextEditingController.text
                  "type": selectedInsuranceType.toString(),
                  // selected dropdown value
                  "dateofpayment": datemonth,
                  "close_date": "${_selectedClosingDate!
                      .day}-${_selectedClosingDate!.month}-${_selectedClosingDate!
                      .year}",
                  "remarks": remarksController.text,

                };
                String jsonString = jsonEncode(jsonObject);
                Map<String, dynamic> mp = new HashMap();
                mp["data"] = jsonString;

                new DatabaseHelper().update(mp,id, "TABLE_INSURANCE");

                setState(() {
                  premiumController.clear();
                  remarksController.clear();

                  datemonth = "";
                });

                Navigator.of(context).pop({});
              }
            else {
              Map<String, dynamic> jsonObject = {
                "insurance_no": accountsetupid,
                "account": selectedAccount!.data,
                "amount": premiumController.text,
                // TextEditingController.text
                "type": selectedInsuranceType.toString(),
                // selected dropdown value
                "dateofpayment": datemonth,
                "close_date": "${_selectedClosingDate!
                    .day}-${_selectedClosingDate!.month}-${_selectedClosingDate!
                    .year}",
                "remarks": remarksController.text,

              };
              String jsonString = jsonEncode(jsonObject);
              Map<String, dynamic> mp = new HashMap();
              mp["data"] = jsonString;

              new DatabaseHelper().insert(mp, "TABLE_INSURANCE");

              addToTask("${_selectedClosingDate!
                  .day}-${_selectedClosingDate!.month}-${_selectedClosingDate!
                  .year}", datemonth, id);





              Map<String,dynamic>mpp=jsonDecode(selectedAccount!.jsondata);
              mpp["Amount"]=amountController.text.toString();

              Map<String, dynamic> acc = {
                "data": jsonEncode(mpp)
              };


              new DatabaseHelper().update(
                  acc, selectedAccount!.id,"TABLE_ACCOUNTSETTINGS");




              setState(() {
                premiumController.clear();
                remarksController.clear();

                datemonth = "";
              });

              Navigator.of(context).pop({});
            }




          }
          else{

            showMyAlertDialog(context, "", "Select date of payment");
          }

        }
      else{

        showMyAlertDialog(context, "", "Select date of payment");
      }


    }
    else {
      showMyAlertDialog(context, "", "Enter Premium Amount");
    }
  }
    else {
      showMyAlertDialog(context, "", "Select insurance account");
    }


  }




  Future<void> addToTask(String closingDate, String monthYear, String id) async {
    try {

      List<String> months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];


      DateTime now = DateTime.now();
      int y = now.year;
      int mnnth = now.month; // 1-12
      int dt = now.day;

      List<String> my = monthYear.split("/");
      int date = int.parse(my[0]);

      int d1=0;

      for(int i=0;i<months.length;i++)
        {
          if(months[i].compareTo(my[1])==0)
            {

              d1=i+1;
              break;
            }

        }






      if (d1 < mnnth) {
        y = y + 1;
      } else if (d1 == mnnth) {
        if (date < dt) {
          y = y + 1;
        }
      }

      int m = d1; // month from monthYear
      String startDateStr = "$date-$m-$y";

      DateFormat sdf = DateFormat("dd-MM-yyyy");
      DateTime strDate = sdf.parse(startDateStr);
      DateTime endDate = sdf.parse(closingDate);

      int a = monthsBetween(strDate, endDate);

      DateTime calendar1 = strDate;

      if (calendar1.isBefore(endDate)) {
        // Fetch account subject
       // String subject = selectedAccount!.data;
        // Map<String, dynamic>? accountData = await getDataByID(id);
        // if (accountData != null) {
        //   subject = accountData["Accountname"] ?? "";
        // }

      //  String timeselected = DateFormat("hh:mm a").format(now);




        // taskId.add(rowid.toString());

        // Schedule notification (replace with flutter_local_notifications)
        // scheduleNotification(subject, calendar1);
      }

      for (int i = 0; i < a; i++) {


        if (calendar1.isBefore(endDate)) {


          int currd = calendar1.day;
          int m1 = calendar1.month;
          int currYear = calendar1.year;

          Map<String, dynamic> task = {
            "name": selectedAccount!.data,
            "date": "${currd}-${m1}-${currYear}",
            "time": TimeOfDay(hour: now.hour, minute: now.minute)?.format(context),
            "status": 0,
            "reminddate": "${currd}-${m1}-${currYear}",
            "remindPeriod": selectedInsuranceType!,
          };

          Map<String, dynamic> mp = new HashMap();
          // Save in DB
          String jsonTask = jsonEncode(task);
          mp["data"] = jsonTask;
          int rowid = await new DatabaseHelper().insert(mp, "TABLE_TASK") ;



          if (selectedInsuranceType!.toLowerCase() == "quarterly") {
            calendar1 = DateTime(calendar1.year, calendar1.month + 3, calendar1.day);
          } else if (selectedInsuranceType!.toLowerCase() == "half yearly") {
            calendar1 = DateTime(calendar1.year, calendar1.month + 6, calendar1.day);
          } else if (selectedInsuranceType!.toLowerCase() == "monthly") {
            calendar1 = DateTime(calendar1.year, calendar1.month + 1, calendar1.day);
          } else if (selectedInsuranceType!.toLowerCase() == "yearly") {
            calendar1 = DateTime(calendar1.year + 1, calendar1.month, calendar1.day);
          }
          a = monthsBetween(calendar1, endDate);

        }
      }
    } catch (e) {
      print("Error in addToTask: $e");
    }
  }

  int monthsBetween(DateTime startDate, DateTime endDate) {
    return ((endDate.year - startDate.year) * 12 + endDate.month - startDate.month);
  }



  void showMyAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[

            TextButton(
              child: Text("OK"),
              onPressed: () {
                // Do something on OK
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  getAllAccounts()async
  {

    List<Map<String,dynamic>>mpd=await new DatabaseHelper().getAllData("TABLE_ACCOUNTSETTINGS");

    List<InsuranceAccount> mapName=[];

    for(int i=0;i<mpd.length;i++)
      {
        String account = mpd[i]["data"];

        Map<String,dynamic>mpp=jsonDecode(account);

        if(mpp["Accounttype"].toString().compareTo("Insurance")==0)
          {

            InsuranceAccount iacc=new InsuranceAccount();
            iacc.id=mpd[i]["id"].toString();
            iacc.data=mpp["Accountname"].toString();
            iacc.jsondata=account;

            mapName.add(iacc);

          }
      }

    setState(() {



      accounts=mapName;
      if (accounts.isNotEmpty) {


        if(map.length>0) {
          accountsetupid = map["insurance_no"];
          for(int i=0;i<accounts.length;i++)
          {
            if(accounts[i].id.toString().compareTo(accountsetupid)==0)
            {
              selectedAccount = accounts[i];

              Map<String,dynamic>mpp=jsonDecode(selectedAccount!.jsondata);


                amountController.text=  mpp["Amount"].toString();

              break;
            }
          }


        }
        else {
          selectedAccount = accounts[0];
          accountsetupid = selectedAccount!.id;
        }

        // default selection
      }



    });
  }



  final TextEditingController _dateController = TextEditingController();
  int selectedMonth = DateTime.now().month;
  int selectedDay = DateTime.now().day;

  List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
  Future<void> pickMonthDayCustom(BuildContext context) async {


    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Select Day & Month"),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButton<int>(
                      value: selectedDay,
                      items: List.generate(31, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text((index + 1).toString()),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedDay = val;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: DropdownButton<int>(
                      value: selectedMonth,
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(months[index]),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedMonth = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      "month": selectedMonth,
                      "day": selectedDay,
                    });
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        final monthName = months[(result['month'] as int) - 1];
        setState(() {
          datemonth = "${result['day']}/$monthName"; // e.g., 25/Jan
          _dateController.text = datemonth; // update TextField
        });
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getAllAccounts();
    setState(() {
      selectedInsuranceType=insuranceTypes.first;
    });

    showDataForEdit(map);
  }



  showDataForEdit(Map<String,dynamic>m)
  {

    if(m.length>0)
      {
        // Map<String, dynamic> jsonObject = {
        //   "insurance_no": accountsetupid,
        //   "account":selectedAccount!.data,
        //   "amount": premiumController.text,  // TextEditingController.text
        //   "type": selectedInsuranceType.toString(), // selected dropdown value
        //   "dateofpayment": datemonth,
        //   "close_date": "${_selectedClosingDate!.day}-${_selectedClosingDate!.month}-${_selectedClosingDate!.year}",
        //   "remarks": remarksController.text,
        //
        // };

        setState(() {
          accountsetupid=m["insurance_no"];
          premiumController.text=m["amount"];
          selectedInsuranceType=m["type"];
          datemonth=m["dateofpayment"];
          _dateController.text=datemonth;
          remarksController.text=m["remarks"];
          String close_date=m["close_date"];
          final dateformat=DateFormat("dd-MM-yyyy");
          _selectedClosingDate=dateformat.parse(close_date);


        });



      }

  }





  Future<void> _pickDate(BuildContext context, Function(DateTime) onSelected) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insurance Entry"),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Provider Dropdown + Add FAB
            Row(
              children: [
                Expanded(
                  child: DropdownButton<InsuranceAccount>(
                    isExpanded: true,
                    value: selectedAccount,
                    hint: const Text("Select Insurance Account"),
                    items: accounts.map((InsuranceAccount account) {
                      return DropdownMenuItem<InsuranceAccount>(
                        value: account,
                        child: Text(account.data ?? ""),
                      );
                    }).toList(),
                    onChanged: (InsuranceAccount? value) {
                      setState(() {
                        selectedAccount = value;
                        accountsetupid=selectedAccount!.id.toString();
                      });
                      // You can now access both id and data:
                      print("Selected ID: ${value?.id}, Name: ${value?.data}");

                      String d=value!.jsondata;
                      Map<String,dynamic>mpp=jsonDecode(d);
                      setState(() {

                        amountController.text=  mpp["Amount"].toString();
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

            // Amount Field
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Premium Amount Field
            TextField(
              controller: premiumController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Premium Amount",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Insurance Type Dropdown
            DropdownButtonFormField<String>(
              value: selectedInsuranceType,
              hint: Text("Select Insurance Type"),
              items: insuranceTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),   
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedInsuranceType = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

    TextField(
    readOnly: true,
    controller: _dateController,
    decoration: InputDecoration(
    labelText: "Select Date of Payment",
    border: OutlineInputBorder(),
    suffixIcon: Icon(Icons.calendar_today),
    ),
    onTap: () => pickMonthDayCustom(context),
    ),

            SizedBox(height: 16),

            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Closing Date",
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: () => _pickDate(context, (date) {
                setState(() {
                  _selectedClosingDate = date;
                });
              }),
              controller: TextEditingController(
                text: _selectedClosingDate == null
                    ? ""
                    : "${_selectedClosingDate!.day}-${_selectedClosingDate!.month}-${_selectedClosingDate!.year}",
              ),
            ),
            const SizedBox(height: 16),

            // Remarks
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Enter Remarks",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),

            // Save Button
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
                onPressed: _saveInsurance,
                child: Text(
                  "Save",
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
