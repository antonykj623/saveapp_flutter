import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/databasehelper/data_base_helper.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';

import 'addSubject.dart';

class AddDiary extends StatefulWidget {
  final Payment? payment;

  const AddDiary({super.key, this.payment});

  @override
  State<AddDiary> createState() => _AddPaymentVoucherPageState();
}

class _AddPaymentVoucherPageState extends State<AddDiary> {
  final _formKey = GlobalKey<FormState>();
  late DateTime selectedDate;
  String? selectedAccount;
  final TextEditingController _amountController = TextEditingController();
  String paymentMode = 'Cash';
  String? selectedCashOption;
  final TextEditingController _remarksController = TextEditingController();
  var dropdownvalu1 = 'English';
  var dropdownvalu2 = 'Add Subjecct';
  var items1 = [
    'English',
    'Malayalam',
    'Hindi',

  ];
  var items2= [
    'Add Subjecct',


  ];



  String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  DateTime selected_startDate = DateTime.now();
  DateTime selected_endDate = DateTime.now();

  String _getDisplayStartDate() {
    return DateFormat('dd/MM/yyyy').format(selected_startDate);
  }

  selectDate(bool isStart) {
    showDatePicker(
      context: context,

      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          // selectedDate = pickedDate;
          selectedYearMonth = DateFormat('yyyy-MM').format(pickedDate);
          if (isStart) {
            selected_startDate = pickedDate;
          } else {
            selected_endDate = pickedDate;
          }

        });
      }
    });
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
        title: const Text('Add Diary', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child:DropdownButton(
                  isExpanded: true,
                  // Initial Value
                  value: dropdownvalu1,

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
                      dropdownvalu1 = newValue2!;
                      print("Value is..:$dropdownvalu1");
                    });
                  },
                ),

              ),
              SizedBox(height: 20),
              Container(
                width: 380,
                height: 40,
                child: InkWell(
                  onTap: () {
                    selectDate(true);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getDisplayStartDate(),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ),
              // InkWell(
              //   onTap: () => _selectDate(context),
              //   child: Container(
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.grey),
              //       borderRadius: BorderRadius.circular(4),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           DateFormat('dd-MM-yyyy').format(selectedDate),
              //           style: const TextStyle(fontSize: 16),
              //         ),
              //         const Icon(Icons.calendar_today),
              //       ],
              //     ),
              //   ),
              // ),
              //






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

                      child: DropdownButton(
                        isExpanded: true,
                        // Initial Value
                        value: dropdownvalu2,

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
                            dropdownvalu2 = newValue2!;
                            print("Value is..:$dropdownvalu2");
                          });
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: FloatingActionButton(
                        backgroundColor: Colors.red,
                        tooltip: 'Increment',
                        shape:   const CircleBorder(),
                        onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder:(context)=>Adddsubject( )));


                        },
                        child: const Icon(Icons.add, color: Colors.white, size: 25),
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
                  maxLines: 6,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Data',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(

                child: Column(
                  children: [
                    Container(
                      width: 100,
                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,// background (button) color
                          foregroundColor: Colors.white,
                          // foreground (text) color
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


              ),
            ],
          ),
        ),
      ),
    );
  }
}
