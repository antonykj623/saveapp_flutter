import 'dart:convert';
import 'dart:io';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

import '../password_details/password_details.dart';
import 'EditPasswordManager.dart';

class passwordModel {
  final int? keyid;
  final String title;
  final String uname;
  final String passwd;
  final String website;
  final String remarks;

  passwordModel({
    required this.keyid,
    required this.title,
    required this.uname,
    required this.passwd,
    required this.website,
    required this.remarks,
  });

  // Factory constructor for creating a new instance from a map
  factory passwordModel.fromJson(Map<String, dynamic> json) {
    return passwordModel(
      keyid: json['keyid'],
      title: json['title'],
      uname: json['uname'],
      passwd: json['passwd'],
      website: json['website'],
      remarks: json['remarks'],
    );
  }
  factory passwordModel.fromMap(Map<String, dynamic> map) {
    return passwordModel(
      keyid: map['keyid'] ?? '',
      title: map['title'] ?? '',
      uname: map['uname'] ?? '',
      passwd: map['passwd'] ?? '',
      website: map['website'] ?? '',
      remarks: map['remarks'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'keyid': keyid,
      'title': title,
      'uname': uname,
      'passwd': passwd,
      'website': website,
      'remarks': remarks,
    };
  }

  // Method to convert instance to map
  Map<String, dynamic> toJson() {
    return {
      'keyid': keyid,
      'title': title,
      'uname': uname,
      'passwd': passwd,
      'website': website,
      'remarks': remarks,
    };
  }

  // @override
  // String toString() {
  //   return 'passwordItem((keyId: $keyid,title: $title, uname: $uname, passwd: $passwd, website: $website,remarks:$remarks)';
  // }
}

var id;

List<String> _filteredItems = [];
TextEditingController _searchController = TextEditingController();

class listpasswordData extends StatefulWidget {
  const listpasswordData({super.key});

  @override
  State<listpasswordData> createState() => _Home_ScreenState();
}

List<Map<String, dynamic>> _foundUsers = [];

class _Home_ScreenState extends State<listpasswordData> {
  bool isLoading = false;

  List<passwordModel> docLinks = [];
  int currentYear = DateTime.now().year;
  void _loadData() async {
    final rawData = await DatabaseHelper().fetchAllpassData();
    List<passwordModel> loadedLinks = [];
    for (var entry in rawData) {
      final keyId = entry['keyid'];
      final jsonString = entry['data'];

      try {
        final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
        decodedMap['keyid'] = keyId; // Add keyId
        loadedLinks.add(passwordModel.fromMap(decodedMap));
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }

    setState(() {
      docLinks = loadedLinks;
    });
  }

  @override
  initState() {
    super.initState();
    _loadData();
  }

  Future<void> _handleDelete(int keyid) async {
    setState(() => isLoading = true);
    await Future.delayed(Duration.zero);
    await DatabaseHelper().deleteByFieldId('TABLE_PASSWORD', keyid);
    _loadData();
    await Future.delayed(Duration(seconds: 0));

    setState(() => isLoading = false);
  }

  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                      Color(0xFFF093fb),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      //   onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SaveApp(),
                                  ),
                                );
                                // Navigator.of(context).pop();
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            ' Password Manager',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    // decoration: BoxDecoration(
                    //   gradient: LinearGradient(
                    //     colors: [
                    //       Colors.blue,           // Start with white
                    //       Color(0xFFCFD1EE),      // Light BlueGrey (BlueGrey[100])
                    //     ], // white to BlueGrey[100] // BlueGrey[700] to BlueGrey[100]
                    //     //   colors: [Color(0xFF001010), Color(0xFF70e2f5)],
                    //     begin: Alignment.topCenter,
                    //     end: Alignment.bottomCenter,
                    //   ),
                    //   borderRadius: BorderRadius.circular(20),
                    // ),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: DatabaseHelper().getAllData('TABLE_PASSWORD'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final items = snapshot.data ?? [];
                        print("Items areeeee$items");

                        if (items.isEmpty) {
                          return const Center(
                            child: Text("No documents found"),
                          );
                        }

                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final keyId =
                                item['keyid']; // <-- Get correct keyid directly
                            final dataJson = jsonDecode(item['data'] ?? '{}');

                            return GestureDetector(
                              onTap: () async {
                                final passwordItem = passwordModel.fromMap({
                                  'keyid': keyId,
                                  'title': dataJson['title'] ?? '',
                                  'uname': dataJson['uname'] ?? '',
                                  'passwd': dataJson['passwd'] ?? '',
                                  'website': dataJson['website'] ?? '',
                                  'remarks': dataJson['remarks'] ?? '',
                                });

                                // Navigate to EditPasswordPage (you need to modify EditPasswordPage to accept passwordModel)
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EditPasswordPage(
                                          entry: passwordItem,
                                        ),
                                  ),
                                );

                                if (result == true) {
                                  // Refresh the data if update was successful
                                  _loadData();
                                  setState(
                                    () {},
                                  ); // optional, depending on your logic
                                }
                              },
                              child: Card(
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Title: ${dataJson['title'] ?? 'N/A'}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Username: ${dataJson['uname'] ?? 'N/A'}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              if (keyId != null) {
                                                await _handleDelete(keyId);
                                              }
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // elevation: 5,
                              // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              // child: Padding(
                              //   padding: const EdgeInsets.all(12.0),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Text("Title: ${dataJson['title'] ?? 'N/A'}",
                              //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              //       const SizedBox(height: 8),
                              //       Text("Username: ${dataJson['uname'] ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold)),
                              //       const SizedBox(height: 16),
                              //       Row(
                              //         mainAxisAlignment: MainAxisAlignment.end,
                              //         children: [
                              //           TextButton(
                              //             onPressed: () async {
                              //               List<Map<String, dynamic>> documents = await DatabaseHelper().fetchAllpassData();
                              //               final kid = documents[index]['keyid'];
                              //               if (kid != null) {
                              //                 await _handleDelete(kid);
                              //               }
                              //             },
                              //             child: const Text(
                              //               'Delete',
                              //               style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              //             ),
                              //           ),
                              //           const SizedBox(width: 10),
                              //         ],
                              //       )
                              //     ],
                              //   ),
                              // ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),

      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 40.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Container(
              height: 65,

              child: FloatingActionButton(
                backgroundColor: Colors.red,
                tooltip: 'Increment',
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPasswordPage()),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white, size: 25),
              ),
            ),
            //  Text('Home'),
            Spacer(),
          ],
        ),
      ),
    );

    //  return   Placeholder();
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:new_project_2025/model/password_model/password_model_password.dart';
//
// class EditPasswordPage extends StatefulWidget {
//   final PasswordEntry entry;
//   final int index;
//   final Function(int, PasswordEntry) onSave;
//
//   EditPasswordPage({
//     required this.entry,
//     required this.index,
//     required this.onSave,
//   });
//
//   @override
//   _EditPasswordPageState createState() => _EditPasswordPageState();
// }
//
// class _EditPasswordPageState extends State<EditPasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _titleController;
//   late TextEditingController _usernameController;
//   late TextEditingController _passwordController;
//   late TextEditingController _websiteController;
//   late TextEditingController _remarksController;
//   bool _obscurePassword = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.entry.title);
//     _usernameController = TextEditingController(text: widget.entry.username);
//     _passwordController = TextEditingController(text: widget.entry.password);
//     _websiteController = TextEditingController(text: widget.entry.website);
//     _remarksController = TextEditingController(text: widget.entry.remarks);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF26A69A),
//       body: SafeArea(
//         child: Container(
//           margin: EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Edit Password',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   SizedBox(height: 32),
//                   Expanded(
//                     child: SingleChildScrollView(
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
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 32),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: _submitForm,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFF26A69A),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 60,
//                           vertical: 16,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       child: Text(
//                         'Save',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
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
//
//   Widget _buildPasswordField() {
//     return TextFormField(
//       controller: _passwordController,
//       obscureText: _obscurePassword,
//       decoration: InputDecoration(
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
//
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       PasswordEntry updatedEntry = PasswordEntry(
//         title: _titleController.text,
//         username: _usernameController.text,
//         password: _passwordController.text,
//         website: _websiteController.text,
//         remarks: _remarksController.text,
//       );
//       widget.onSave(widget.index, updatedEntry);
//       Navigator.pop(context);
//     }
//   }
//
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