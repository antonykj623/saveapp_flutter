import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class Addaccountsdet extends StatefulWidget {
  const Addaccountsdet({super.key});

  @override
  State<Addaccountsdet> createState() => _SlidebleListState1();
}

class MenuItem {
  // final int id;
  final String label;
  // final IconData icon;

  MenuItem(this.label);
}

class MenuItem1 {
  // final int id;
  final String label1;
  // final IconData icon;

  MenuItem1(this.label1);
}

var items1 = [
  'Asset Account',
  'Bank',
  'Cash',
  'Credit Card',
  'Customers',
  'Expense Account',
  'Income Account',
  'Insurance',
  'Investment',
  'Liability Account',
];
var items2 = ['Debit', 'Credit'];
var items3 = ['2025', '2026', '2027', '2028', '2029', '2030'];
List<MenuItem> menuItems1 = [MenuItem('Debit'), MenuItem('Credit')];

// List<MenuItem> menuItems = [
//    MenuItem('Credit'),
//   MenuItem('Debit'),

final _formKey = GlobalKey<FormState>();
final TextEditingController accountname = TextEditingController();
final TextEditingController catogory = TextEditingController();
final TextEditingController openingbalance = TextEditingController();
var dropdownvalu = '2025';
var dropdownvalu1 = 'Asset Account';
var dropdownvalu2 = 'Debit';
var id = [
  "How to Use",
  "Help on Whatsapp",
  "Mail Us",
  "About Us",
  "Privasy Policy",
  "Terms and Conditions For Use",
  "FeedBack",
  "Share",
];

// var dropdownvalu1 = 'Debit';
final TextEditingController menuController = TextEditingController();
MenuItem? selectedMenu;
final TextEditingController menuController1 = TextEditingController();
MenuItem1? selectedMenu1;
final TextEditingController type = TextEditingController();

class _SlidebleListState1 extends State<Addaccountsdet> {
  // get dbhelper1 => null;

  //
  // void queryall() async {
  //   var allrows = await dbhelper.queryallacc();
  //   allrows.forEach((row){
  //     print("rowdatas are:$row");
  //
  //   }
  //   );
  //
  //
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Add Account Setup')),
      appBar: AppBar(
        backgroundColor: Colors.teal,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),

        title: Text('Add Account Setup', style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Container(
            height: 500,
            // height: MediaQuery.of(context).size.height,
            //   width: MediaQuery.of(context).size.width,
            // color: const Color.fromARGB(255, 255, 255, 255),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  enabled: true,
                  controller: accountname,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                    ),
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(
                    //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                    // ),
                    hintText: "Accountname",

                    // hintText: 'MObile',
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),

                    fillColor: const Color.fromARGB(0, 170, 30, 30),
                    filled: true,
                    // prefixIcon: const Icon(Icons.person,color:Colors.white)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                    // validator:(value) {
                    //   if (value == "") {
                    //     return 'Account name';
                    //   }
                    //   return null;
                  },
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: ShapeDecoration(
                    shape: BeveledRectangleBorder(
                      side: BorderSide(width: .5, style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                    ),
                  ),

                  child: DropdownButton(
                    isExpanded: true,
                    // Initial Value
                    value: dropdownvalu1,

                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),

                    // Array list of items
                    items:
                        items1.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue2) {
                      setState(() {
                        dropdownvalu1 = newValue2!;
                        print("Value is..:$dropdownvalu1");
                      });
                    },
                  ),
                ),

                SizedBox(height: 20),

                TextFormField(
                  textAlign: TextAlign.end,
                  enabled: true,
                  controller: openingbalance,

                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),

                    //   hintStyle: (TextStyle(color: Colors.white)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(
                    //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                    //
                    // ),
                    hintText: "enter Opening Balance",

                    fillColor: Colors.transparent,
                    filled: true,

                    //  prefixIcon: const Icon(Icons.password,color:Colors.white)
                  ),
                  validator: (value) {
                    if (value == "") {
                      return 'please add Opening Balance';
                    }
                    return null;
                  },
                  //    obscureText: true,
                ),

                const SizedBox(height: 20),
                InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    // Initial Value
                    value: dropdownvalu2,

                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),

                    // Array list of items
                    items:
                        items2.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue1) {
                      setState(() {
                        dropdownvalu2 = newValue1!;
                        print("Value is..:$dropdownvalu2");
                      });
                    },
                  ),
                ),

                const SizedBox(height: 90),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.teal, // background (button) color
                        foregroundColor:
                            Colors.white, // foreground (text) color
                      ),

                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, proceed
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Processing Data')),
                          );

                          final accname = accountname.text;

                          final catogory = dropdownvalu1;
                          final openbalance = openingbalance.text;

                          final type = dropdownvalu2;

                          Map<String, dynamic> accountsetupData = {
                            "Accountname": accname,
                            "Accounttype": dropdownvalu1,
                            "OpeningBalance": openbalance,
                            "Type": type,
                          };
                          final _databaseHelper = DatabaseHelper().addData(
                            "TABLE_ACCOUNTSETTINGS",
                            jsonEncode(accountsetupData),
                          );

                          print('account name is ...$accname');
                          //    dbhelper.createacc(Accounts(accountname: accname, catogory: catogory, openingbalance: openbalance, accounttype: type1, accyear: year));

                          print("Value inserted ");
                        }
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      //   color: const Color(0xFF1BC0C5),
                    ),

                    //                       Padding(
                    //                         padding: const EdgeInsets.all(8.0),
                    //                         child: ElevatedButton(onPressed: () async {
                    //
                    //
                    //                           var data =  await dbhelper.queryallacc();
                    //
                    //                           print("Datas are...$data");
                    //
                    //
                    //
                    //                           //  dbhelper1.accountqueryall1();
                    //                           // dbhelper1;
                    // //                               QuickAlert.show(
                    // //  context: context,
                    // //  type: QuickAlertType.success,
                    // //   title: 'registration Completed Please login',
                    //
                    // // );
                    //
                    //
                    //                         }, child: Text('showdata'),),
                    //                       ),
                    //
                    //

                    // ElevatedButton(
                    //   onPressed: () async{
                    //     var alterTable = await dbhelper.alterTable('accountstable','catogory');
                    //     // alterTable();
                    //     //   alterTable();
                    //
                    //     print("Value Altered : $alterTable()");
                    //     //  clearText();
                    //   },
                    //
                    //   child: Text(
                    //     'Alter',
                    //     style: TextStyle(color: Colors.blue, fontSize: 25),
                    //   ),
                    //
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
