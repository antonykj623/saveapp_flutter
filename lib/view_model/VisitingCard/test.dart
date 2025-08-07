// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:new_project_2025/model/password_model/password_model_password.dart';
// import 'package:new_project_2025/view/home/widget/home_screen.dart';
// import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

// void main() {
//   runApp(MaterialApp(home: AddPasswordPage()));
// }

// class AddPasswordPage extends StatefulWidget {
//   // final Function(PasswordEntry) onSave;

//   //AddPasswordPage({required this.onSave});
//   @override
//   _AddPasswordPageState createState() => _AddPasswordPageState();
// }

// class _AddPasswordPageState extends State<AddPasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _websiteController = TextEditingController();
//   final TextEditingController _remarksController = TextEditingController();

//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //backgroundColor: Colors.Grey[100],
//       body: Padding(
//         padding: const EdgeInsets.all(0),
//         child: Column(
//           children: [
//             // ✅ TOP CONTAINER (Back button + title)
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Color(0xFF667eea),
//                     Color(0xFF764ba2),
//                     Color(0xFFF093fb),
//                   ],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,

//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.white.withOpacity(0.1),
//                             blurRadius: 10,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Icon(Icons.arrow_back, color: Colors.white),
//                     ),
//                   ),

//                   Text(
//                     'Add Password Manager',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Form content
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(18.0),
//                   child: Container(
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           _buildTextField(
//                             controller: _titleController,
//                             labelText: 'Title',
//                           ),
//                           SizedBox(height: 20),
//                           _buildTextField(
//                             controller: _usernameController,
//                             labelText: 'Username',
//                           ),
//                           SizedBox(height: 20),
//                           _buildPasswordField(),
//                           SizedBox(height: 20),
//                           _buildTextField(
//                             controller: _websiteController,
//                             labelText: 'Website',
//                           ),
//                           SizedBox(height: 20),
//                           _buildTextField(
//                             controller: _remarksController,
//                             labelText: 'Remarks',
//                             maxLines: 3,
//                           ),
//                           SizedBox(height: 32),
//                           ElevatedButton(
//                             onPressed: _submitForm,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(0xFF26A69A),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 60,
//                                 vertical: 16,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(25),
//                               ),
//                             ),
//                             child: Text(
//                               'Submit',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 16),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // import 'dart:convert';
//   //
//   // import 'package:flutter/material.dart';
//   // import 'package:flutter/widgets.dart';
//   // import 'package:new_project_2025/model/password_model/password_model_password.dart';
//   // import 'package:new_project_2025/view/home/widget/home_screen.dart';
//   // import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
//   //
//   // import '../Edit_password/EditPasswordManager.dart';
//   // import '../Edit_password/Edit_password_screen.dart';
//   //
//   // class AddPasswordPage extends StatefulWidget {
//   //   // final Function(PasswordEntry) onSave;
//   //
//   //
//   //   //AddPasswordPage({required this.onSave});
//   //   @override
//   //   _AddPasswordPageState createState() => _AddPasswordPageState();
//   // }
//   //
//   //
//   // class _AddPasswordPageState extends State<AddPasswordPage> {
//   //   final _formKey = GlobalKey<FormState>();
//   //   final TextEditingController _titleController = TextEditingController();
//   //   final TextEditingController _usernameController = TextEditingController();
//   //   final TextEditingController _passwordController = TextEditingController();
//   //   final TextEditingController _websiteController = TextEditingController();
//   //   final TextEditingController _remarksController = TextEditingController();
//   //
//   //   bool _obscurePassword = true;
//   //
//   //   @override
//   //   Widget build(BuildContext context) {
//   //     return Scaffold(
//   //       backgroundColor: Color(0xFF26A69A),
//   //
//   //       appBar: AppBar(
//   //         backgroundColor: Colors.teal,
//   // actions: [
//   //
//   // ],
//   //         leading: IconButton(
//   //           onPressed: () {
//   //             Navigator.pop(context);
//   //           },
//   //           icon: Icon(Icons.arrow_back, color: Colors.white),
//   //         ),
//   //
//   //         title: Text(' Add Password Manager', style: TextStyle(color: Colors.white)),
//   //       ),
//   //
//   //       body: SafeArea(
//   //         child: Container(
//   //
//   //           margin: EdgeInsets.all(16),
//   //           decoration: BoxDecoration(
//   //             gradient: LinearGradient(
//   //               colors: [Color(0xFF008080), Color(0xFF70e1f5)], // Teal to light blue
//   //               begin: Alignment.topLeft,
//   //               end: Alignment.bottomRight,
//   //             ),
//   //             borderRadius: BorderRadius.circular(16),
//   //             boxShadow: [
//   //               BoxShadow(
//   //                 color: Colors.black12,
//   //                 blurRadius: 10,
//   //                 offset: Offset(0, 4),
//   //               ),
//   //             ],
//   //           ),
//   //           child: Padding(
//   //             padding: EdgeInsets.all(24),
//   //             child: Form(
//   //               key: _formKey,
//   //               child: Column(
//   //                 crossAxisAlignment: CrossAxisAlignment.start,
//   //                 children: [
//   //                   // Text(
//   //                   //   'Password Manager',
//   //                   //   style: TextStyle(
//   //                   //     fontSize: 24,
//   //                   //     fontWeight: FontWeight.bold,
//   //                   //     color: Colors.white,
//   //                   //   ),
//   //                   // ),
//   //                   SizedBox(height: 32),
//   //                   Expanded(
//   //                     child: SingleChildScrollView(
//   //                       child: Column(
//   //                         children: [
//   //                           _buildTextField(
//   //                             controller: _titleController,
//   //                             labelText: 'Title',
//   //                           ),
//   //                           SizedBox(height: 20),
//   //                           _buildTextField(
//   //                             controller: _usernameController,
//   //                             labelText: 'Username',
//   //                           ),
//   //                           SizedBox(height: 20),
//   //                           _buildPasswordField(),
//   //                           SizedBox(height: 20),
//   //                           _buildTextField(
//   //                             controller: _websiteController,
//   //                             labelText: 'Website',
//   //                           ),
//   //                           SizedBox(height: 20),
//   //                           _buildTextField(
//   //                             controller: _remarksController,
//   //                             labelText: 'Remarks',
//   //                             maxLines: 3,
//   //                           ),
//   //                         ],
//   //                       ),
//   //                     ),
//   //                   ),
//   //                   SizedBox(height: 32),
//   //                   Center(
//   //                     child: ElevatedButton(
//   //                       onPressed: () {
//   //                         _submitForm();
//   //
//   //
//   //
//   //                       },
//   //                       style: ElevatedButton.styleFrom(
//   //                         backgroundColor: Color(0xFF26A69A),
//   //                         padding: EdgeInsets.symmetric(
//   //                           horizontal: 60,
//   //                           vertical: 16,
//   //                         ),
//   //                         shape: RoundedRectangleBorder(
//   //                           borderRadius: BorderRadius.circular(25),
//   //                         ),
//   //                       ),
//   //                       child: Text(
//   //                         'Submit',
//   //                         style: TextStyle(
//   //                           fontSize: 18,
//   //                           fontWeight: FontWeight.w600,
//   //                           color: Colors.white,
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       ),
//   //     );
//   //   }
//   //
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String labelText,
//     int maxLines = 1,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: labelText,
//         filled: true,
//         fillColor: Colors.white,
//         labelStyle: TextStyle(color: Colors.grey[600]),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Color(0xFF26A69A), width: 2),
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//       validator: (value) {
//         if (labelText == 'Title' || labelText == 'Username') {
//           if (value == null || value.isEmpty) {
//             return 'Please enter $labelText';
//           }
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildPasswordField() {
//     return TextFormField(
//       controller: _passwordController,
//       obscureText: _obscurePassword,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white,
//         labelText: 'Password',
//         labelStyle: TextStyle(color: Colors.grey[600]),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Color(0xFF26A69A), width: 2),
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscurePassword ? Icons.visibility_off : Icons.visibility,
//             color: Colors.grey[600],
//           ),
//           onPressed: () {
//             setState(() {
//               _obscurePassword = !_obscurePassword;
//             });
//           },
//         ),
//       ),
//     );
//   }

//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Processing Data')));

//         final title = _titleController.text;
//         final username = _usernameController.text;
//         final password = _passwordController.text;
//         final website = _websiteController.text;
//         final remarks = _remarksController.text;
//         Map<String, dynamic> passwordData = {
//           "title": title,
//           "uname": username,
//           "passwd": password,
//           "website": website,
//           "remarks": remarks,
//         };

//         // Save to database
//         await DatabaseHelper().addData(
//           "TABLE_PASSWORD",
//           jsonEncode(passwordData),
//         );

//         // Show success message
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('passwordData  added successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );

//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => SaveApp()),
//           );
//           // Clear form fields
//           // accountname.clear();
//           // openingbalance.clear();
//           // setState(() {
//           //   dropdownvalu1 = 'Asset Account';
//           //   dropdownvalu2 = 'Debit';
//           // });

//           // Return true to indicate success and pop the page
//           // Navigator.pop(context, true);
//         }
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(
//         //       builder: (context) => listpasswordData()

//         //   ),
//         // );
//       } catch (e) {
//         print('Error saving account: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error saving account: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//     // if (_formKey.currentState!.validate()) {
//     //   PasswordEntry newEntry = PasswordEntry(
//     //     title: _titleController.text,
//     //     username: _usernameController.text,
//     //     password: _passwordController.text,
//     //     website: _websiteController.text,
//     //     remarks: _remarksController.text,
//     //   );
//     //
//     //   widget.onSave(newEntry);
//     //   Navigator.pop(context);
//     // }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _websiteController.dispose();
//     _remarksController.dispose();
//     super.dispose();
//   }
// }
