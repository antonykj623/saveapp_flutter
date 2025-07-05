import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../services/dbhelper/dbhelper.dart';
import 'package:intl/intl.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _SlidebleListState1();
}

final TextEditingController task = TextEditingController();

final TextEditingController emiamount = TextEditingController();
final TextEditingController emiperiod = TextEditingController();

DateTime selected_startDate = DateTime.now();
DateTime selected_endDate = DateTime.now();    
String getCurrentMonthYear() {
  final now = DateTime.now();
  final formatter = DateFormat('MMM/yyyy'); // e.g., May/2025
  return formatter.format(now);
}

var dropdownvalu = 'OneTime';
var items1 = [
  'OneTime',
  'Daily',
  'Monthly',
  'Weekly',
  'Quarterly',
  'Half Yearly',
  'Yearly',
];
final TextEditingController menuController = TextEditingController();

final TextEditingController menuController1 = TextEditingController();

final TextEditingController type = TextEditingController();

final dbhelper = DatabaseHelper.instance;

class _SlidebleListState1 extends State<Tasks> {
  // get dbhelper1 => null;

  bool _showTextBox = false;

  TextEditingController _timeController = TextEditingController();

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      setState(() {
        _timeController.text = formattedTime;
      });
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void selectDate(bool isStart) {
      showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      ).then((pickedDate) {
        if (pickedDate != null) {
          setState(() {
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
      appBar: AppBar(
        backgroundColor: Colors.teal,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),

        title: Text('Tasks', style: TextStyle(color: Colors.white)),
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
              const SizedBox(height: 10),

              TextFormField(
                enabled: true,
                controller: task,

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
                  hintText: "Tasks",

                  fillColor: Colors.transparent,
                  filled: true,

                  //  prefixIcon: const Icon(Icons.password,color:Colors.white)
                ),
                validator: (value) {
                  if (value == "") {
                    return ' Tasks';
                  }
                  return null;
                },
                //    obscureText: true,
              ),
              SizedBox(height: 20),

              Container(
                width: 380,
                height: 60,
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
              SizedBox(height: 20),
              TextField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Select Time',
                  suffixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                onTap: () => _selectTime(context),
              ),
              SizedBox(height: 20),

              Container(
                width: 380,
                height: 60,
                child: InkWell(
                  onTap: () {
                    selectDate(false);
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
                          _getDisplayEndDate(),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                  value: dropdownvalu,

                  // Down Arrow Icon
                  icon: const Icon(Icons.keyboard_arrow_down),

                  // Array list of items
                  items:
                      items1.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(items),
                          ),
                        );
                      }).toList(),
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (String? newValue2) {
                    setState(() {
                      dropdownvalu = newValue2!;
                      // _showTextBox = newValue2 == 'EMI';
                      //  print("Value is..:$dropdownvalu");
                    });
                  },
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(left: 130.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.teal, // background (button) color
                        foregroundColor:
                            Colors.white, // foreground (text) color
                      ),

                      onPressed: () {},
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _getDisplayStartDate() {
  return DateFormat('dd/MM/yyyy').format(selected_startDate);
}

String _getDisplayEndDate() {
  return DateFormat('dd/MM/yyyy').format(selected_endDate);
}
