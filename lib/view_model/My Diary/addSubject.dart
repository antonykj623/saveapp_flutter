

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../services/dbhelper/dbhelper.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';


class Adddsubject extends StatefulWidget {
  const Adddsubject({super.key});

  @override
  State<Adddsubject> createState() => _SlidebleListState1();


}

class _SlidebleListState1 extends State<Adddsubject> {

  @override
  void initState() {
    super.initState();
    // Schedule the dialog to be shown after the widget has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showmyDialog();
    });}






  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController subject = TextEditingController();

  static const IconData camera_alt = IconData(0xe130, fontFamily: 'MaterialIcons');







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(title: const Text('Add Account Setup')),
      appBar: AppBar(
        backgroundColor: Colors.teal,

        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back, color: Colors.white,
        )),

        title: Text(
            'Add Subject', style: TextStyle(color: Colors.white)),

      ),
      drawer:  Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Choose Option'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Subject'),
              onTap: () {
                Navigator.pop(context);

              },
            ),

          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),


      ),


    );
  }

  void showmyDialog() {
    showDialog(
      context: context,
      // barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content:  Container(

              width: 300,
              height: 300,

              //   color: const Color.fromARGB(255, 255, 255, 255),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(height: 50,),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('Enter Subject',style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(height: 20,),
                    TextFormField(

                      enabled: true,
                      controller: subject,

                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.normal),


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
                        hintText: "Add Subject ",


                        fillColor: Colors.transparent,
                        filled: true,
                        //  prefixIcon: const Icon(Icons.password,color:Colors.white)

                      ),

                      //    obscureText: true,
                    ),
SizedBox(height: 20,),
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
                                "Add",
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


                    SizedBox(height: 20,),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 100.0),
                    //   child: Column(
                    //     children: [
                    //
                    //
                    //
                    //     ],),
                    // ),
                    //
                    //


                  ])),

        );
      },
    );
  }



}
