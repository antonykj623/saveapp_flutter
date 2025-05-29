

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../services/dbhelper/dbhelper.dart';
import 'package:intl/intl.dart';

class AddInvestment extends StatefulWidget {
  const AddInvestment({super.key});

  @override
  State<AddInvestment> createState() => _SlidebleListState1();
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
// List<MenuItem> menuItems = [
//   MenuItem('Asset Account'),
//   MenuItem('Bank'),
//   MenuItem('Cash'),
//   MenuItem('Credit Card'),
//   MenuItem('Customers'),
//   MenuItem('Expense Account'),
//   MenuItem('Income Account'),
//   MenuItem('Insurance'),
//   MenuItem('Investment'),
//   MenuItem('Liability Account'),
//
//
// ];
var items1 = [
  'Monthly',
  'Fixed',
  'Random',

];
var items2 = [
  'My Savings',


];

final TextEditingController nonemiamount = TextEditingController();

final TextEditingController emiamount = TextEditingController();
final TextEditingController emiperiod = TextEditingController();
var emi = 0;
var dropdownvalu = 'Monthly';
var dropdownvalu1 = 'My Savings';
//var dropdownvalu2 = 'Debit';
var id = ["How to Use", "Help on Whatsapp", "Mail Us", "About Us", "Privasy Policy","Terms and Conditions For Use","FeedBack","Share"];
DateTime selected_startDate = DateTime.now();
DateTime selected_endDate = DateTime.now();
String getCurrentMonthYear() {
  final now = DateTime.now();
  final formatter = DateFormat('MMM/yyyy'); // e.g., May/2025
  return formatter.format(now);
}


final TextEditingController menuController = TextEditingController();
MenuItem? selectedMenu;
final TextEditingController menuController1 = TextEditingController();
MenuItem1? selectedMenu1;
final TextEditingController type = TextEditingController();

final dbhelper = DatabaseHelper.instance;

class _SlidebleListState1 extends State<AddInvestment> {
  // get dbhelper1 => null;

  bool _showTextBox = false;

  void queryall() async {
    var allrows = await dbhelper.queryallacc();
    allrows.forEach((row){
      print("rowdatas are:$row");

    }
    );


  }

  @override
  Widget build(BuildContext context) {
    void selectDate(bool isStart) {
      showDatePicker(
        context: context,
        //initialDate: isStart ? selected_startDate : selected_endDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      ).then((pickedDate) {
        if (pickedDate != null) {
          setState(() {
            // selectedYearMonth = DateFormat('yyyy-MM').format(pickedDate);
            if (isStart) {
              selected_startDate = pickedDate;
            } else {
              selected_endDate = pickedDate;
            }
            //  _loadReceipts();
          });
        }
      });
    }

    return Scaffold(
      // appBar: AppBar(title: const Text('Add Account Setup')),
      appBar: AppBar(
        backgroundColor: Colors.teal,

        leading: IconButton(onPressed: (){
          Navigator.pop(context);

        }, icon: Icon(Icons.arrow_back, color: Colors.white,
        )),

        title: Text('Investments',style: TextStyle(color: Colors.white)),

      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),

        child: Container(

            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            // color: const Color.fromARGB(255, 255, 255, 255),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [


                  Container(


                    child: Row(

                      children: [
                        Expanded(

                          child: Container(

                            decoration: ShapeDecoration(shape: BeveledRectangleBorder(side: BorderSide(width: .5,style: BorderStyle.solid),borderRadius: BorderRadius.all(Radius.circular(0)))),
                            // padding: const EdgeInsets.symmetric(horizontal: 16),
                            //                 decoration: BoxDecoration(
                            //                   border: Border.all(color: Colors.black),
                            //                   borderRadius: BorderRadius.circular(4),
                            //                 ),
                            child: DropdownButton(

                              isExpanded: true,
                              // Initial Value
                              value: dropdownvalu1,

                              // Down Arrow Icon
                              icon: const Icon(Icons.keyboard_arrow_down),

                              // Array list of items
                              items: items2.map((String items) {
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
                        ),

                        Container(width: 15,),
                        SizedBox(width:40,
                          child: Container(


                            child: FloatingActionButton(
                              backgroundColor: Colors.red,
                              tooltip: 'Increment',
                              shape:   const CircleBorder(),
                              onPressed: (){
                                //      Navigator.push(context,MaterialPageRoute(builder:(context)=>AddBill( )));


                              },
                              child: const Icon(Icons.add, color: Colors.white, size: 25),
                            ),


                          ),
                        ),

                      ],),


                    //   decoration: ShapeDecoration(shape: BeveledRectangleBorder(side: BorderSide(width: .5,style: BorderStyle.solid),borderRadius: BorderRadius.all(Radius.circular(0)))
                  ),



                  const SizedBox(height: 10),


                  TextFormField(
                    textAlign: TextAlign.end,
                    enabled: true,
                    controller:nonemiamount,

                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),


                      //   hintStyle: (TextStyle(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black),
                      ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                      //
                      // ),
                      hintText: "25000",




                      fillColor: Colors.transparent,
                      filled: true,
                      //  prefixIcon: const Icon(Icons.password,color:Colors.white)

                    ),
                    validator:(value) {
                      if (value == "") {
                        return ' Amount';
                      }
                      return null;
                    },
                    //    obscureText: true,
                  ),

                  const SizedBox(height: 20),
                  Container(
                    decoration: ShapeDecoration(shape: BeveledRectangleBorder(side: BorderSide(width: .5,style: BorderStyle.solid),borderRadius: BorderRadius.all(Radius.circular(0)))
                    ),

                    child: DropdownButton(

                      isExpanded: true,
                      // Initial Value
                      value: dropdownvalu,

                      // Down Arrow Icon
                      icon: const Icon(Icons.keyboard_arrow_down),

                      // Array list of items
                      items: items1.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      // After selecting the desired option,it will
                      // change button value to selected value
                      onChanged: (String? newValue2) {
                        setState(() {
                          dropdownvalu = newValue2!;
                         // _showTextBox = newValue2 == 'EMI';
                          print("Value is..:$dropdownvalu");
                        });
                      },
                    ),

                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    textAlign: TextAlign.end,
                    enabled: true,
                    controller:nonemiamount,

                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),


                      //   hintStyle: (TextStyle(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black),
                      ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                      //
                      // ),
                      hintText: "2500",




                      fillColor: Colors.transparent,
                      filled: true,
                      //  prefixIcon: const Icon(Icons.password,color:Colors.white)

                    ),
                    validator:(value) {
                      if (value == "") {
                        return ' Amount';
                      }
                      return null;
                    },
                    //    obscureText: true,
                  ),









                  const SizedBox(height: 20),
                  TextFormField(
                    //textAlign: TextAlign.end,
                    enabled: true,
                    controller:emiamount,

                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.normal),


                      //   hintStyle: (TextStyle(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black),
                      ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderSide: BorderSide(
                      //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                      //
                      // ),
                      hintText: "Number of Installment",

                      fillColor: Colors.transparent,
                      filled: true,
                      //  prefixIcon: const Icon(Icons.password,color:Colors.white)

                    ),
                    validator:(value) {
                      if (value == "") {
                        return 'Emi Amount';
                      }
                      return null;
                    },
                    //    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  // if (_showTextBox)
                  //   TextFormField(
                  //     enabled: true,
                  //     controller:emiperiod,
                  //     decoration: InputDecoration(
                  //       enabledBorder: OutlineInputBorder(
                  //         borderSide: BorderSide(
                  //             color: Colors.black,width: 1.5),
                  //       ),
                  //       // focusedBorder: OutlineInputBorder(
                  //       //   borderSide: BorderSide(
                  //       //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
                  //       // ),
                  //       hintText: "",
                  //
                  //
                  //       // hintText: 'MObile',
                  //       hintStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                  //
                  //
                  //       fillColor: const Color.fromARGB(0, 170, 30, 30),
                  //       filled: true,
                  //       // prefixIcon: const Icon(Icons.person,color:Colors.white)),
                  //     ),
                  //     validator:(value) {
                  //       if (value == "") {
                  //         return 'Number of Emi';
                  //       }
                  //       return null;
                  //     },
                  //
                  //
                  //   ),
                  //


                 // const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
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
                                    //' ${ _getDisplayStartDate()}',
                                    'Select Date of Payment',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Icon(Icons.calendar_today, color: Colors.teal),
                                ],
                              ),
                            ),
                          ),
                        ),


                      ],

                    ),
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(

                            onTap: () => selectDate(true),
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Text(
                                    //' ${ _getDisplayStartDate()}',
                                    'Select Closing Date',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Icon(Icons.calendar_today, color: Colors.teal),
                                ],
                              ),
                            ),
                          ),
                        ),


                      ],

                    ),
                  ),
                  const SizedBox(height:  50,),
                  Column(
                    children: [
                      ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,// background (button) color
                          foregroundColor: Colors.white, // foreground (text) color
                        ),

                        onPressed: () {
                          // final accname = accountname.text;
                          //
                          // final catogory = dropdownvalu1;
                          //
                          // final openbalance = openingbalance.text;
                          //
                          // final type1 = dropdownvalu2;
                          //
                          // final status1 = '0';
                          //
                          // dbhelper.createacc(Accounts(accountname: accname, catogory: catogory, openingbalance: openbalance, accounttype: type1, accyear: year));
                          //
                          //
                          // print("Value inserted ");
                          //
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
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

                    ],),


                ]) ),
      ),




    );


  }

}

