// import 'package:flutter/material.dart';
// import 'package:new_project_2025/model/password_model/password_model_password.dart';
// import 'package:new_project_2025/view/home/widget/password_manger/password_list_screen/Edit_password/Edit_password_screen.dart';
// import 'package:new_project_2025/view/home/widget/password_manger/password_list_screen/password_details/password_details.dart';



// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Password Manager',
//       theme: ThemeData(primarySwatch: Colors.teal),
//       home: PasswordListPage(),
//     );
//   }
// }

// // First Page - Password List with stored entries
// class PasswordListPage extends StatefulWidget {
//   @override
//   _PasswordListPageState createState() => _PasswordListPageState();
// }

// class _PasswordListPageState extends State<PasswordListPage> {

//   List<PasswordEntry> passwordEntries = [
//     PasswordEntry(title: 'My Fb Password', username: 'uiiii'),
//   ];

//   void _addNewEntry(PasswordEntry entry) {
//     setState(() {
//       passwordEntries.add(entry);
//     });
//   }

//   void _deleteEntry(int index) {
//     setState(() {
//       passwordEntries.removeAt(index);
//     });
//   }

//   void _editEntry(int index, PasswordEntry updatedEntry) {
//     setState(() {
//       passwordEntries[index] = updatedEntry;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF5F5F5),
//       appBar: AppBar(
//         backgroundColor: Color(0xFF26A69A),
//         title: Text('Password Manager', style: TextStyle(color: Colors.white)),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         elevation: 0,
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: passwordEntries.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (context) => Editpasswordmanager(

//                       ),
//                 ),
//               );
//             },
//             child: Container(
//               margin: EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Title',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   Text(
//                                     ' : ${passwordEntries[index].title}',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Username',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   Text(
//                                     ' : ${passwordEntries[index].username}',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             _deleteEntry(index);
//                           },
//                           child: Text(
//                             'Delete',
//                             style: TextStyle(color: Colors.red, fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddPasswordPage( ),
//              // builder: (context) => AddPasswordPage(onSave: _addNewEntry),
//             ),
//           );
//         },
//         backgroundColor: Color(0xFFE91E63),
//         child: Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }

// // New Edit Password Page
