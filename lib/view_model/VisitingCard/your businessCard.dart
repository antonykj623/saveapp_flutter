

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:new_project_2025/view_model/VisitingCard/visitingcard.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';


class AddVisitingCard extends StatefulWidget {


  const AddVisitingCard({Key? key,}) : super(key: key);

  @override
  State<AddVisitingCard> createState() => _VisitingCardPageState();
}
class _VisitingCardPageState extends State<AddVisitingCard> {


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
        title: const Text('Your VisitingCard ', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.grey[200],
      body: SizedBox(
        child: SingleChildScrollView(

          child: Column(

            children: [


              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,

                    child: Row(
                      children: [
                        // Image section
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/1.jpg'), // Your card image
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Info section


                        Expanded(
                          child:
                      Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name : Antony"),
                              Text("Phone : 7575757373"),
                              Text("Website : www.google.com"),
                              Text("Designation : Mobile Application Developer"),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // delete action
                                  },
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                          ),),

                      ],
                    ),

                ),
              ),


              ]))



              // Share Button

        ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,



        child: Row(

          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Spacer(),
            // Spacer(),
            // Spacer(),
            // Spacer(),
            // Spacer(),
            Container(
              height:105,



            ),
            //  Text('Home'),

            Padding(
              padding: const EdgeInsets.only(bottom: 18.0,right: 20),
              child: Container(



                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  tooltip: 'Increment',
                  shape:   const CircleBorder(),
                  onPressed: (){
                    Navigator.push(context,MaterialPageRoute(builder:(context)=>VisitingCard( )));


                  },
                  child: const Icon(Icons.add, color: Colors.white, size: 25),
                ),



              ),
            )

          ],
        ),
      ),
    );
  }
}


// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';
//
// import '../../services/dbhelper/dbhelper.dart';
// import 'package:intl/intl.dart';
//
// class  BusinessCardDetails extends StatefulWidget {
//   const BusinessCardDetails({super.key});
//
//   @override
//   State<BusinessCardDetails> createState() => _SlidebleListState1();
// }
//
//
// class MenuItem {
//   // final int id;
//   final String label;
//   // final IconData icon;
//
//   MenuItem(this.label);
// }
//
// class MenuItem1 {
//   // final int id;
//   final String label1;
//   // final IconData icon;
//
//   MenuItem1(this.label1);
// }
//
// var items1 = [
//   'Non EMI',
//   'EMI'
//
// ];
// var items2 = [
//   'HDFC LOAN',
//   'SBIN lOAN',
//   'SIB LOAN'
//
// ];
//
// final TextEditingController nonemiamount = TextEditingController();
//
// final TextEditingController emiamount = TextEditingController();
// final TextEditingController emiperiod = TextEditingController();
// var emi = 0;
// var dropdownvalu = 'Non EMI';
// var dropdownvalu1 = 'HDFC LOAN';
// //var dropdownvalu1 = 'Non EMI';
// //var dropdownvalu2 = 'Debit';
// var id = ["How to Use", "Help on Whatsapp", "Mail Us", "About Us", "Privasy Policy","Terms and Conditions For Use","FeedBack","Share"];
// DateTime selected_startDate = DateTime.now();
// DateTime selected_endDate = DateTime.now();
// String getCurrentMonthYear() {
//   final now = DateTime.now();
//   final formatter = DateFormat('MMM/yyyy'); // e.g., May/2025
//   return formatter.format(now);
// }
//
//
// final TextEditingController menuController = TextEditingController();
// MenuItem? selectedMenu;
// final TextEditingController menuController1 = TextEditingController();
// MenuItem1? selectedMenu1;
// final TextEditingController type = TextEditingController();
//
// final dbhelper = DatabaseHelper.instance;
//
// class _SlidebleListState1 extends State<BusinessCardDetails> {
//   // get dbhelper1 => null;
//
//   bool _showTextBox = false;
//
//   void queryall() async {
//     var allrows = await dbhelper.queryallacc();
//     allrows.forEach((row){
//       print("rowdatas are:$row");
//
//     }
//     );
//
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     void selectDate(bool isStart) {
//       showDatePicker(
//         context: context,
//         //initialDate: isStart ? selected_startDate : selected_endDate,
//         firstDate: DateTime(2000),
//         lastDate: DateTime(2100),
//       ).then((pickedDate) {
//         if (pickedDate != null) {
//           setState(() {
//             // selectedYearMonth = DateFormat('yyyy-MM').format(pickedDate);
//             if (isStart) {
//               selected_startDate = pickedDate;
//             } else {
//               selected_endDate = pickedDate;
//             }
//             //  _loadReceipts();
//           });
//         }
//       });
//     }
//
//     return Scaffold(
//       // appBar: AppBar(title: const Text('Add Account Setup')),
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//
//         leading: IconButton(onPressed: (){
//           Navigator.pop(context);
//
//         }, icon: Icon(Icons.arrow_back, color: Colors.white,
//         )),
//
//         title: Text('Your Business Card details',style: TextStyle(color: Colors.white)),
//
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//
//         child: Container(
//
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             // color: const Color.fromARGB(255, 255, 255, 255),
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     color: const Color.fromARGB(255, 252, 252, 252),
//                     height: MediaQuery.of(context).size.height / 4.2,  // Also Including Tab-bar height.
//                     child:  CarouselSlider(
//                       items: [
//
//                         //1st Image of Slider
//                         Container(
//                           margin: EdgeInsets.all(6.0),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8.0),
//
//                             image: DecorationImage(
//                               image: NetworkImage('https://images.pexels.com/photos/2681319/pexels-photo-2681319.jpeg?auto=compress&cs=tinysrgb&w=600'),
//                               fit: BoxFit.cover,
//
//
//                             ),
//                           ),
//                         ),
//
//
//                         //4th Image of Slider
//                         Container(
//                           margin: EdgeInsets.all(6.0),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8.0),
//                             image: DecorationImage(
//                               image: NetworkImage('https://www.pixelstalk.net/wp-content/uploads/image12/Laptop-Desktop-HD-Wallpaper-with-a-tranquil-beach-with-turquoise-waters-and-a-vibrant-sunset-620x347.jpg'),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//
//                         //5th Image of Slider
//                         Container(
//                           margin: EdgeInsets.all(6.0),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8.0),
//                             image: DecorationImage(image: NetworkImage('https://www.pixelstalk.net/wp-content/uploads/2016/08/Background-HD-Wallpapers-620x349.jpg'),
//                               // image:AssetImage('5.jpg'),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//
//                       ],
//
//                       //Slider Container properties
//                       options: CarouselOptions(
//                         height: 180.0,
//
//                         enlargeCenterPage: true,
//                         autoPlay: true,
//                         aspectRatio: 16/10,
//                         autoPlayCurve: Curves.fastOutSlowIn,
//                         enableInfiniteScroll: true,
//                         autoPlayAnimationDuration: Duration(milliseconds: 800),
//                         viewportFraction: 0.8,
//                       ),
//                       //
//                       //   child: Chewie(
//                       //                          controller: _chewieController,
//                     ),
//
//                   ),
//
//
//
//
//
//
//
//
//
//
//                   const SizedBox(height: 10),
//
//                   Container(
//                     decoration: ShapeDecoration(shape: BeveledRectangleBorder(side: BorderSide(width: .5,style: BorderStyle.solid),borderRadius: BorderRadius.all(Radius.circular(0)))
//                     ),
//
//                     child: DropdownButton(
//
//                       isExpanded: true,
//                       // Initial Value
//                       value: dropdownvalu,
//
//                       // Down Arrow Icon
//                       icon: const Icon(Icons.keyboard_arrow_down),
//
//                       // Array list of items
//                       items: items1.map((String items) {
//                         return DropdownMenuItem(
//                           value: items,
//                           child: Text(items),
//                         );
//                       }).toList(),
//                       // After selecting the desired option,it will
//                       // change button value to selected value
//                       onChanged: (String? newValue2) {
//                         setState(() {
//                           dropdownvalu = newValue2!;
//                           _showTextBox = newValue2 == 'EMI';
//                           print("Value is..:$dropdownvalu");
//                         });
//                       },
//                     ),
//
//                   ),
//                   const SizedBox(height: 10),
//                   Container(
//
//
//                     child: Row(
//                       children: [
//                         Expanded(
//
//                           child: Container(
//                             decoration: ShapeDecoration(shape: BeveledRectangleBorder(side: BorderSide(width: .5,style: BorderStyle.solid),borderRadius: BorderRadius.all(Radius.circular(0)))),
//                             // padding: const EdgeInsets.symmetric(horizontal: 16),
//                             //                 decoration: BoxDecoration(
//                             //                   border: Border.all(color: Colors.black),
//                             //                   borderRadius: BorderRadius.circular(4),
//                             //                 ),
//                             child: DropdownButton(
//
//                               isExpanded: true,
//                               // Initial Value
//                               value: dropdownvalu1,
//
//                               // Down Arrow Icon
//                               icon: const Icon(Icons.keyboard_arrow_down),
//
//                               // Array list of items
//                               items: items2.map((String items) {
//                                 return DropdownMenuItem(
//                                   value: items,
//                                   child: Text(items),
//                                 );
//                               }).toList(),
//                               // After selecting the desired option,it will
//                               // change button value to selected value
//                               onChanged: (String? newValue2) {
//                                 setState(() {
//                                   dropdownvalu1 = newValue2!;
//                                   print("Value is..:$dropdownvalu1");
//                                 });
//                               },
//                             ),
//
//
//                           ),
//                         ),
//                         SizedBox(width: 50,
//                           child: Container(
//
//
//                             child: FloatingActionButton(
//                               backgroundColor: Colors.red,
//                               tooltip: 'Increment',
//                               shape:   const CircleBorder(),
//                               onPressed: (){
//                                 //      Navigator.push(context,MaterialPageRoute(builder:(context)=>AddBill( )));
//
//
//                               },
//                               child: const Icon(Icons.add, color: Colors.white, size: 25),
//                             ),
//
//
//                           ),
//                         ),
//
//                       ],),
//
//
//                     //   decoration: ShapeDecoration(shape: BeveledRectangleBorder(side: BorderSide(width: .5,style: BorderStyle.solid),borderRadius: BorderRadius.all(Radius.circular(0)))
//                   ),
//
//
//
//
//
//                   const SizedBox(height: 20),
//
//
//
//
//                   TextFormField(
//                     textAlign: TextAlign.end,
//                     enabled: true,
//                     controller:nonemiamount,
//
//                     decoration: InputDecoration(
//                       hintStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
//
//
//                       //   hintStyle: (TextStyle(color: Colors.white)),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                             color: Colors.black),
//                       ),
//                       // focusedBorder: OutlineInputBorder(
//                       //   borderSide: BorderSide(
//                       //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
//                       //
//                       // ),
//                       hintText: "2500",
//
//
//
//
//                       fillColor: Colors.transparent,
//                       filled: true,
//                       //  prefixIcon: const Icon(Icons.password,color:Colors.white)
//
//                     ),
//                     validator:(value) {
//                       if (value == "") {
//                         return ' Amount';
//                       }
//                       return null;
//                     },
//                     //    obscureText: true,
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     textAlign: TextAlign.end,
//                     enabled: true,
//                     controller:emiamount,
//
//                     decoration: InputDecoration(
//                       hintStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
//
//
//                       //   hintStyle: (TextStyle(color: Colors.white)),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(
//                             color: Colors.black),
//                       ),
//                       // focusedBorder: OutlineInputBorder(
//                       //   borderSide: BorderSide(
//                       //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
//                       //
//                       // ),
//                       hintText: "Amount",
//
//                       fillColor: Colors.transparent,
//                       filled: true,
//                       //  prefixIcon: const Icon(Icons.password,color:Colors.white)
//
//                     ),
//                     validator:(value) {
//                       if (value == "") {
//                         return 'Emi Amount';
//                       }
//                       return null;
//                     },
//                     //    obscureText: true,
//                   ),
//                   const SizedBox(height: 20),
//                   if (_showTextBox)
//                     TextFormField(
//                       enabled: true,
//                       controller:emiperiod,
//                       decoration: InputDecoration(
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Colors.black,width: 1.5),
//                         ),
//                         // focusedBorder: OutlineInputBorder(
//                         //   borderSide: BorderSide(
//                         //       color: const Color.fromARGB(255, 254, 255, 255), width: .5),
//                         // ),
//                         hintText: "Number of Emi",
//
//
//                         // hintText: 'MObile',
//                         hintStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
//
//
//                         fillColor: const Color.fromARGB(0, 170, 30, 30),
//                         filled: true,
//                         // prefixIcon: const Icon(Icons.person,color:Colors.white)),
//                       ),
//                       validator:(value) {
//                         if (value == "") {
//                           return 'Number of Emi';
//                         }
//                         return null;
//                       },
//
//
//                     ),
//
//
//
//                   const SizedBox(height: 20),
//
//                   Padding(
//                     padding: const EdgeInsets.only(top:8.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: InkWell(
//                             onTap: () => selectDate(true),
//                             child: Container(
//                               height: 50,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.black),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//
//                                   Text(
//                                     //' ${ _getDisplayStartDate()}',
//                                     'Select Closing Date',
//                                     style: const TextStyle(fontSize: 16),
//                                   ),
//                                   const Icon(Icons.calendar_today, color: Colors.teal),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//
//
//                       ],
//
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   Padding(
//                     padding: const EdgeInsets.only(top:8.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: InkWell(
//
//                             onTap: () => selectDate(true),
//                             child: Container(
//                               height: 50,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.black),
//                                 borderRadius: BorderRadius.circular(0),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//
//                                   Text(
//                                     //' ${ _getDisplayStartDate()}',
//                                     'Set Remind Date',
//                                     style: const TextStyle(fontSize: 16),
//                                   ),
//                                   const Icon(Icons.calendar_today, color: Colors.teal),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//
//
//                       ],
//
//                     ),
//                   ),
//                   const SizedBox(height: 150,),
//                   Column(
//                     children: [
//                       ElevatedButton(
//
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.teal,// background (button) color
//                           foregroundColor: Colors.white, // foreground (text) color
//                         ),
//
//                         onPressed: () {
//                           // final accname = accountname.text;
//                           //
//                           // final catogory = dropdownvalu1;
//                           //
//                           // final openbalance = openingbalance.text;
//                           //
//                           // final type1 = dropdownvalu2;
//                           //
//                           // final status1 = '0';
//                           //
//                           // dbhelper.createacc(Accounts(accountname: accname, catogory: catogory, openingbalance: openbalance, accounttype: type1, accyear: year));
//                           //
//                           //
//                           // print("Value inserted ");
//                           //
//                         },
//                         child: Text(
//                           "Save",
//                           style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
//                         ),
//                         //   color: const Color(0xFF1BC0C5),
//                       ),
//
//
// //                       Padding(
// //                         padding: const EdgeInsets.all(8.0),
// //                         child: ElevatedButton(onPressed: () async {
// //
// //
// //                           var data =  await dbhelper.queryallacc();
// //
// //                           print("Datas are...$data");
// //
// //
// //
// //                           //  dbhelper1.accountqueryall1();
// //                           // dbhelper1;
// // //                               QuickAlert.show(
// // //  context: context,
// // //  type: QuickAlertType.success,
// // //   title: 'registration Completed Please login',
// //
// // // );
// //
// //
// //                         }, child: Text('showdata'),),
// //                       ),
// //
// //
//
//
//                       // ElevatedButton(
//                       //   onPressed: () async{
//                       //     var alterTable = await dbhelper.alterTable('accountstable','catogory');
//                       //     // alterTable();
//                       //     //   alterTable();
//                       //
//                       //     print("Value Altered : $alterTable()");
//                       //     //  clearText();
//                       //   },
//                       //
//                       //   child: Text(
//                       //     'Alter',
//                       //     style: TextStyle(color: Colors.blue, fontSize: 25),
//                       //   ),
//                       //
//                       // ),
//
//                     ],),
//
//
//                 ]) ),
//       ),
//
//
//
//
//     );
//
//
//   }
//
// }
//
