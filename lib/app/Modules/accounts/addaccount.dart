// import 'dart:ffi';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';
//
// import '../../../model/user_model.dart';
// import '../../../services/dbhelper/dbhelper.dart';
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
//
//
// class Addaccountsdet extends StatefulWidget {
//   const Addaccountsdet({super.key});
//
//   @override
//   State<Addaccountsdet> createState() => _SlidebleListState1();
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
// var items2 = [
//   'Debit',
//   'Credit',
//
// ];
// var items3 = [
//   '2025',
//   '2026',
//   '2027',
//   '2028',
//   '2029',
//   '2030',
//
// ];
// List<MenuItem> menuItems1 = [
//   MenuItem('Debit'),
//   MenuItem('Credit'),
//
//
// ];
//
// // List<MenuItem> menuItems = [
// //    MenuItem('Credit'),
// //   MenuItem('Debit'),
//
//
// // ];
// final TextEditingController accountname = TextEditingController();
// final TextEditingController catogory = TextEditingController();
// final TextEditingController openingbalance = TextEditingController();
// var dropdownvalu = '2025';
// var dropdownvalu1 = 'Asset Account';
// var dropdownvalu2 = 'Debit';
// var id = ["How to Use", "Help on Whatsapp", "Mail Us", "About Us", "Privasy Policy","Terms and Conditions For Use","FeedBack","Share"];
//
//
// // var dropdownvalu1 = 'Debit';
// final TextEditingController menuController = TextEditingController();
// MenuItem? selectedMenu;
// final TextEditingController menuController1 = TextEditingController();
// MenuItem1? selectedMenu1;
// final TextEditingController type = TextEditingController();
//
// final dbhelper = DatabaseHelper.instance;
//
// class _SlidebleListState1 extends State<Addaccountsdet> {
//   // get dbhelper1 => null;
//
//
//
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
//     var date = DateTime.now().toString();
//
//     var dateParse = DateTime.parse(date);
//     var year2 = dateParse.year.toString();
//     print('current year is $year2');
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Account')),
//
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Container(
//           height: 500,
//           // height: MediaQuery.of(context).size.height,
//           //   width: MediaQuery.of(context).size.width,
//           color: const Color.fromARGB(255, 255, 255, 255),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//
//
//               TextFormField(
//                 enabled: true,
//                 controller:accountname,
//                 decoration: InputDecoration(
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: const Color.fromARGB(255, 5, 5, 5), width: .5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: const Color.fromARGB(255, 254, 255, 255), width: .5),
//                   ),
//                   hintText: "Accountname",
//
//
//                   // hintText: 'MObile',
//                   hintStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
//
//
//                   fillColor: const Color.fromARGB(0, 170, 30, 30),
//                   filled: true,
//                   // prefixIcon: const Icon(Icons.person,color:Colors.white)),
//                 ),
//                 validator:(value) {
//                   if (value == "") {
//                     return 'Account name';
//                   }
//                   return null;
//                 },
//
//
//               ),
//               const SizedBox(height: 20),
//
//               Column(
//                 children: [
//                   DropdownButton(
//                     isExpanded: true,
//                     // Initial Value
//                     value: dropdownvalu1,
//
//                     // Down Arrow Icon
//                     icon: const Icon(Icons.keyboard_arrow_down),
//
//                     // Array list of items
//                     items: items1.map((String items) {
//                       return DropdownMenuItem(
//                         value: items,
//                         child: Text(items),
//                       );
//                     }).toList(),
//                     // After selecting the desired option,it will
//                     // change button value to selected value
//                     onChanged: (String? newValue2) {
//                       setState(() {
//                         dropdownvalu1 = newValue2!;
//                         print("Value is..:$dropdownvalu1");
//                       });
//                     },
//                   ),
//
//
//                   //  DropdownMenu<MenuItem>(
//                   //   width: 400,
//
//                   //              initialSelection: menuItems.first,
//
//                   //              controller: menuController,
//                   //            //  width: 600,
//                   //              hintText: "Select Menu",
//                   //              requestFocusOnTap: true,
//                   //              enableFilter: true,
//                   //              label: const Text('Select Catgory '),
//                   //              onSelected: (MenuItem? menu) {
//                   //                selectedMenu = menu;
//                   //              },
//                   //              dropdownMenuEntries:
//                   //                  menuItems.map<DropdownMenuEntry<MenuItem>>((MenuItem menu) {
//                   //                return DropdownMenuEntry<MenuItem>(
//                   //                   value: menu,
//                   //                   label: menu.label,
//                   //                  // leadingIcon: Icon(menu.icon));
//                   //             );    }).toList(),
//                   //            ),
//
//
//                 ],
//               ),
//
//
//
//
//               const SizedBox(height: 10),
//               TextFormField(
//                 enabled: true,
//                 controller:openingbalance,
//
//                 decoration: InputDecoration(
//                   hintStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
//
//
//                   //   hintStyle: (TextStyle(color: Colors.white)),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: const Color.fromARGB(255, 0, 0, 0), width: .5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: const Color.fromARGB(255, 254, 255, 255), width: .5),
//
//                   ),
//                   hintText: "Opening Balance",
//
//
//
//
//                   fillColor: Colors.transparent,
//                   filled: true,
//                   //  prefixIcon: const Icon(Icons.password,color:Colors.white)
//
//                 ),
//                 validator:(value) {
//                   if (value == "") {
//                     return 'Opening Balance';
//                   }
//                   return null;
//                 },
//                 //    obscureText: true,
//               ),
//
//               //  DropdownButton(
//
//
//               //             icon:  Padding(
//               //               padding: const EdgeInsets.only(left: 80.0,right: 10),
//               //               child: Icon(Icons.keyboard_arrow_down),
//
//               //             ),
//               //             items: <String>['2025', '2026', '2027', '2028', '2029', '2030']
//               //                 .map<DropdownMenuItem<String>>((String value) {
//               //               return DropdownMenuItem<String>(
//
//               //                 value: value,
//               //                 child: Text(value),
//
//               //               );
//               //             }).toList(),
//               //             value: dropdownvalu,
//
//               //             onChanged: (values) {
//               //               setState(() {
//               //                 dropdownvalu = values.toString();
//               //               });
//               //             },
//               //           ),
//
//
//               const SizedBox(height: 10),
//               DropdownButton(
//                 isExpanded: true,
//                 // Initial Value
//                 value: dropdownvalu2,
//
//                 // Down Arrow Icon
//                 icon: const Icon(Icons.keyboard_arrow_down),
//
//                 // Array list of items
//                 items: items2.map((String items) {
//                   return DropdownMenuItem(
//                     value: items,
//                     child: Text(items),
//                   );
//                 }).toList(),
//                 // After selecting the desired option,it will
//                 // change button value to selected value
//                 onChanged: (String? newValue1) {
//                   setState(() {
//                     dropdownvalu2 = newValue1!;
//                     print("Value is..:$dropdownvalu2");
//                   });
//                 },
//               ),
//
//               // DropdownMenu<MenuItem>(
//               //   width: 400,
//               //      initialSelection: menuItems1.first,
//               //      controller: menuController1,
//               //       value = dropdownvalu2;
//               //    //  width: 600,
//               //      hintText: "Select Menu",
//               //      requestFocusOnTap: true,
//               //      enableFilter: true,
//               //      label: const Text('Select  type'),
//               //      onSelected: (MenuItem? menu) {
//               //        selectedMenu = menu;
//               //      },
//               //      dropdownMenuEntries:
//               //          menuItems1.map<DropdownMenuEntry<MenuItem>>((MenuItem menu) {
//               //        return DropdownMenuEntry<MenuItem>(
//               //           value: menu,
//
//               //           label: menu.label,
//               //          // leadingIcon: Icon(menu.icon));
//               //     );    }).toList(),
//               //    ),
//
//
//
//
//               //      Container(
//               //       decoration: ShapeDecoration(
//               //   shape: RoundedRectangleBorder(
//               //     side: BorderSide(width: .7, style: BorderStyle.solid),
//               //     borderRadius: BorderRadius.all(Radius.circular(0.0)),
//
//
//
//
//               SizedBox(
//                 child: Container(
//                   width: 400,
//                   height: 250,
//                   color: Colors.orange,
//                   child: Column(
//                     children: [
//                       ElevatedButton(
//
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color.fromARGB(255, 57, 216, 62), // background (button) color
//                           foregroundColor: Colors.white, // foreground (text) color
//                         ),
//
//                         onPressed: () {
//                           final accname = accountname.text;
//
//                           final catogory = dropdownvalu1;
//
//                           final openbalance = openingbalance.text;
//
//                           final type1 = dropdownvalu2;
//
//                           final year1 = year2;
//
//
//                           dbhelper.createacc(Accounts(accountname: accname, catogory: catogory, openingbalance: openbalance, accounttype: type1, accyear: year1));
//
//                           print("Value inserted ");
//                           //  }
//
//
//                           //    Navigator.of(context,rootNavigator: true).pop();
//                           //   clearText();
//
//                         },
//                         child: Text(
//                           "Save",
//                           style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
//                         ),
//                         //   color: const Color(0xFF1BC0C5),
//                       ),
//
//
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
//
//
//                       ElevatedButton(
//                         onPressed: () async{
//                           var alterTable = await dbhelper.alterTableacc('accountstable','year1');
//                         //   alterTable();
//                           //   alterTable();
//
//                           print("Year Altered : $alterTable()");
//                           //  clearText();
//                         },
//
//                         child: Text(
//                           'Alter',
//                           style: TextStyle(color: Colors.blue, fontSize: 25),
//                         ),
//
//                       ),
//                       ElevatedButton(
//                         onPressed: () async{
//                           var delTable = await dbhelper.deleteaccData();
//                           //   alterTable();
//                           //   alterTable();
//
//                           print("Year Deleted : $delTable");
//                           //  clearText();
//                         },
//
//                         child: Text(
//                           'Delete',
//                           style: TextStyle(color: Colors.blue, fontSize: 25),
//                         ),
//
//                       ),
//                     ],),     ),     ),
//             ],
//
//           ),
//         ),
//       ),
//
//
//
//     );
//
//
//   }
//
// }