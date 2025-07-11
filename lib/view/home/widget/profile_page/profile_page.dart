import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:new_project_2025/app/routes/app_routes.dart';
import 'package:new_project_2025/view/home/widget/Invoice_page/Invoice_page.dart';
import 'package:new_project_2025/view/home/widget/profile_page/profilemodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/API_services/API_services.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: ProfileScreen()),
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? stateid;
  String? countryid;

  String phone = '';
  String name = '';
  String email = '';
  String img = '';
  UserProfileResponse? userProfile;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedLanguage = "English"; // Fixed: Set default value
  late String _phoneNumber = "";
  String imageUrl = "";
  String _token = "";

  String? timestamp;// This will store the complete image URL
  final List<String> _languages = [
    "English",
    "Spanish",
    "French",
    "German",
    "Chinese",
  ];
  var apidata = ApiHelper();
  void ProfileUpdate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stateid = prefs.getString('stateId');
    String? countryid = prefs.getString('countryId');
    print("stateid is $stateid");
    print("Countryid is $countryid");


  }
  void profileUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   _token = prefs.getString('token')!;

    // String? stateid = prefs.getString('stateId');
    // String? countryid = prefs.getString('countryId');

    print("Token is $_token");

     timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String base64Image = "";
    if (_profileImage != null) {
      List<int> imageBytes = await _profileImage!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    ApiHelper api = ApiHelper();
    Map<String, String> logdata = {
      "mobile": _phoneNumber,
      "fullName": _nameController.text.trim(),
      "emailId": _emailController.text.trim(),
      "profileImage": base64Image,
      "defaultLang": _selectedLanguage,
      "timestamp": timestamp!,
      "token": _token!,
    };

    try {
      String logresponse = await api.postApiResponse(
          "getUserDetails.php", logdata);
      debugPrint("Response1: $logresponse");
      var res = json.decode(logresponse);
      debugPrint("res is...$res");

      var data = res['data'];
      stateid = data['state_id'];
      countryid = data['country_id'];
      print("stateid is $stateid");
      print("Countryid is $countryid");
      setState(() {
        _nameController.text = data['full_name'] ?? '';
        _emailController.text = data['email_id'] ?? '';
        _phoneNumber = data['mobile'].toString() ?? 'no data';

        // Fixed: Correct URL construction
        String baseUrl = "https://mysaving.in/uploads/profile/";
        String profileImage = data['profile_image'] ?? ''; // Handle null case

        if (profileImage.isNotEmpty) {
          imageUrl =
              baseUrl + profileImage; // Fixed: Remove extra concatenation
          print("Complete Image URL: $imageUrl"); // Debug print
        } else {
          imageUrl = ""; // No image available
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // 👇 Call upload after image is selected
      await uploadProfilePicture(_profileImage!);
    }
    // if (pickedFile != null) {
    //   final image = File(pickedFile.path);
    //   setState(() {
    //     _profileImage = image;
    //   });
    //
    //   // Ensure token and timestamp are available
    //   if (_token != null || timestamp != null) {
    //     uploadProfilePicture();
    //   } else {
    //     print("Token or timestamp is null");
    //   }
    // }

  }


  void updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');



      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token not found. Please login again.')),
        );
        return;
      }


      Map<String, String> profiledata = {

        "name": _nameController.text.trim(),
        "user_email": _emailController.text.trim(),
        "language": _selectedLanguage,
        "timestamp": timestamp!,
        "country_id":countryid!,
        "state_id":stateid!,
        "token": token,
      };



    try {
      String response = await apidata.postApiResponse("UserProfileUpdate.php", profiledata);
      debugPrint("Update response: $response");

      var res = json.decode(response);

      debugPrint("Updated Profile Data: $res ");

      if (res['status'] == 1) {
       // debugPrint("Updated Profile Data: ${res['data']}");



        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Update failed")),
        );
      }
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }
  Future<void> uploadProfilePicture(File imageFile) async {
    final url = Uri.parse('https://mysaving.in/IntegraAccount/api/uploadUserProfile.php');
    final token = 'qwertyuioplkjhgfvbnmlkjiou.OTc0NzQ5Nzk2Nw==.MjVkNTVhZDI4M2FhNDAwYWY0NjRjNzZkNzEzYzA3YWQ=.qwertyuioplkjhgfvbnmlkjiou';
    final timestamp = DateTime.now().toUtc().toIso8601String();

    print('File path: ${imageFile.path}');
    print('File exists: ${await imageFile.exists()}');
    print('File size: ${await imageFile.length()}');

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'x-timestamp': timestamp,
      })
      // ..files.add(await http.MultipartFile.fromPath('profile_image', imageFile.path));
    ..files.add(await http.MultipartFile.fromPath(
    'file', // <-- field name expected by PHP backend
    imageFile.path,
    filename: imageFile.path.split('/').last,
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      try {
        final json = jsonDecode(response.body);
        print('Decoded JSON: $json');
      } catch (e) {
        print('Could not decode response as JSON: $e');
      }
    } catch (e) {
      print('Error uploading: $e');
    }
  }


  // Future<void> uploadProfilePicture(File imageFile) async {
  //   final url = Uri.parse('https://mysaving.in/IntegraAccount/api/uploadUserProfile.php');
  //   final token = 'qwertyuioplkjhgfvbnmlkjiou.OTc0NzQ5Nzk2Nw==.MjVkNTVhZDI4M2FhNDAwYWY0NjRjNzZkNzEzYzA3YWQ=.qwertyuioplkjhgfvbnmlkjiou';
  //   final timestamp = DateTime.now().toUtc().toIso8601String();
  //
  //   final request = http.MultipartRequest('POST', url)
  //     ..headers.addAll({
  //       'Authorization': 'Bearer $token',
  //       'x-timestamp': timestamp, // or any custom header key
  //      // 'Content-Type': 'multipart/form-data',
  //     })
  //     ..files.add(await http.MultipartFile.fromPath('profile_image', imageFile.path));
  //
  //   final response = await request.send();
  //   final response1 = await http.Response.fromStream(response);
  //
  //   if (response.statusCode == 200) {
  //     print('Upload successful');
  //     print('Server response: ${response1.body}');
  //     final responseData = jsonDecode(response1.body);
  //     if (responseData is List && responseData.isEmpty) {
  //       print('Empty list received from server');
  //     } else if (responseData is List) {
  //       print('List received: $responseData');
  //     } else {
  //       print('Response data: $responseData');
  //     }
  //
  //   } else {
  //     print('Upload failed with status: ${response.statusCode}');
  //   }
  // }
  //
  @override
  void initState() {
    super.initState();
    profileUser();
  }

  // @override
  // void dispose() {
  //   _nameController.dispose();
  //   _emailController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InvoiceApp()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1D2B3C), Color(0xFF00897B)],
              ),
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          // Fixed: Proper image display logic
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!) // Show picked image
                              : (imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl) // Show network image
                              : const AssetImage(
                              'assets/appbar.png') // Show default image
                          ) as ImageProvider,
                          // Add error handling for network images
                          onBackgroundImageError: imageUrl.isNotEmpty
                              ? (exception, stackTrace) {
                            print('Error loading image: $exception');
                          }
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF98CB09),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(

                                Icons.edit,
                                color: Colors.white,
                                size: 18,

                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const Text(
                          'Phone Number',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          ':',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _phoneNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                   // _buildTextField(controller: _nameController),
                    _buildTextField(
                      controller: _nameController,
                      label: "Full Name",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(value)) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),

                    // _buildTextField1(
                    //   controller: _emailController,
                    //   keyboardType: TextInputType.emailAddress,
                    // ),
                    const SizedBox(height: 16),
                    _buildLanguageDropdown(),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00897B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async{

                            updateProfile();

                          },
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text('Profile updated successfully'),
                          //   ),
                          // );

                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    String label = "Name",
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }

  // Widget _buildTextField({
  //   required TextEditingController controller,
  //   TextInputType? keyboardType,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.white54),
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: TextFormField(
  //
  //       controller: controller,
  //       keyboardType: keyboardType,
  //       style: const TextStyle(color: Colors.white),
  //       decoration: const InputDecoration(
  //         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //         border: InputBorder.none,
  //       ),
  //       validator: (value) {
  //         if (value == null || value.isEmpty) {
  //           return 'Please enter name';
  //         }
  //         return null;
  //       },
  //     ),
  //   );
  // }
  Widget _buildTextField1({
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter email';
          }
          return null;
        },
      ),
    );
  }
  Widget _buildLanguageDropdown() {
    return FormField<String>(
      initialValue: _selectedLanguage,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a language';
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: const Color(0xFF0D9488),
                  value: _selectedLanguage,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                      state.didChange(newValue); // Sync with form state
                    });
                  },
                  items: _languages.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 12),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  // Widget _buildLanguageDropdown() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.white54),
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         dropdownColor: const Color(0xFF0D9488),
  //         value: _selectedLanguage,
  //         isExpanded: true,
  //         icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
  //         style: const TextStyle(color: Colors.white),
  //         onChanged: (String? newValue) {
  //           setState(() {
  //             _selectedLanguage = newValue!;
  //           });
  //         },
  //
  //
  //         items: _languages.map<DropdownMenuItem<String>>((String value) {
  //           return DropdownMenuItem<String>(
  //             value: value,
  //             child: Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 8),
  //               child: Text(value),
  //             ),
  //           );
  //
  //         }).toList(),
  //
  //       ),
  //     ),
  //   );
  // }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'dart:io';
// import 'package:new_project_2025/app/routes/app_routes.dart';
// import 'package:new_project_2025/view/home/widget/Invoice_page/Invoice_page.dart';
// import 'package:new_project_2025/view/home/widget/profile_page/profilemodel.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../services/API_services/API_services.dart';
//
// void main() {
//   runApp(
//     const MaterialApp(debugShowCheckedModeBanner: false, home: ProfileScreen()),
//   );
// }
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   String phone = '';
//   String name = '';
//   String  email = '';
//   String  img = '';
//     UserProfileResponse? userProfile;
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController(
//
//   );
//   final TextEditingController _emailController = TextEditingController(
//
//   );
//   String _selectedLanguage = " ";
//   late String _phoneNumber = " ";
//   String imageUrl = "";
//   final List<String> _languages = [
//     "English",
//     "Spanish",
//     "French",
//     "German",
//     "Chinese",
//   ];
//   var apidata = ApiHelper();
//
//   void profileUser() async {
//     SharedPreferences prefs =   await SharedPreferences.getInstance();
//     String? _token = prefs.getString('token');
//     print("Token is $_token");
//     // generates a random UUID
//     String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
//     String base64Image = "";
//     if (_profileImage != null) {
//       List<int> imageBytes = await _profileImage!.readAsBytes();
//       base64Image = base64Encode(imageBytes);
//     }
//
//     ApiHelper api = ApiHelper();
//     Map<String, String>  logdata = {
//       "mobile": _phoneNumber,
//       "fullName": _nameController.text.trim(),
//       "emailId":_emailController.text.trim(),
//         "profileImage":base64Image,
//       "defaultLang":_selectedLanguage,
//       "timestamp": timestamp,
//       "token": _token!,
//     };
//
//
//     try {
//       String logresponse = await api.postApiResponse("getUserDetails.php",logdata);
//      // String logresponse = await api.getApiResponse(method)
//    debugPrint("Response1: $logresponse");
//      var res = json.decode(logresponse);
//       debugPrint("res is...$res");
//
//       var data = res['data'];
//       setState(() {
//
//
//       _nameController.text = data['full_name'];
//       _emailController.text = data['email_id'] ?? '';
//       _phoneNumber = data['mobile'].toString() ?? 'no data';
//       String baseUrl = "https://mysaving.in/uploads/profile/";
//       // String profileImage = res['data']['profile_image']; // from your API
//       // String fullImageUrl = baseUrl + profileImage;
//       //   imageUrl = "$baseUrl$fullImageUrl ";
//       String fileName = res['data']['profile_image'];
//         imageUrl = "https://mysaving.in/uploads/profile/$fileName";
//       });
//     } catch (e) {
//       print("Error: $e");
//     }
//   }
//
//   File? _profileImage;
//   final ImagePicker _picker = ImagePicker();
//
//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }
//   @override
//   void initState() {
//     super.initState();
//
//     profileUser();
//   }
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Profile', style: TextStyle(color: Colors.white)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.assignment_outlined, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => InvoiceApp()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//
//         children: [
//
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xFF1D2B3C), Color(0xFF00897B)],
//               ),
//             ),
//           ),
//
//           SafeArea(
//             child: Form(
//               key: _formKey,
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//
//            child:
//               Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   Stack(
//                     children: [
//                       CircleAvatar(
//                         radius: 60,
//                         backgroundColor: Colors.grey.shade300,
// backgroundImage: NetworkImage(imageUrl),
//                       //    backgroundImage: AssetImage(Image.network(imageUrl) as String
//  //   )
//                         //  )
//
//
//
//                             // _profileImage != null
//                             //     ? FileImage(_profileImage!)
//                             //     : const AssetImage(
//                             //           'assets/appbar.png',
//                             //         )
//                             //         as ImageProvider,
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 4,
//                         child: GestureDetector(
//                           onTap: _pickImage,
//                           child: Container(
//                             padding: const EdgeInsets.all(6),
//                             decoration: const BoxDecoration(
//                               color: Color(0xFF98CB09),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.edit,
//                               color: Colors.white,
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   Row(
//                     children: [
//                       const Text(
//                         'Phone Number',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                       const SizedBox(width: 10),
//                       const Text(
//                         ':',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                       const SizedBox(width: 10),
//                       Text(
//                         _phoneNumber,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(controller: _nameController),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildLanguageDropdown(),
//                   const SizedBox(height: 40),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: const Color(0xFF00897B),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Profile updated successfully'),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         'Update',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     TextInputType? keyboardType,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.white54),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         style: const TextStyle(color: Colors.white),
//         decoration: const InputDecoration(
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLanguageDropdown() {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.white54),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       // child: DropdownButtonHideUnderline(
//       //   child: DropdownButton<String>(
//       //     dropdownColor: const Color(0xFF0D9488),
//       //     value: _selectedLanguage,
//       //     isExpanded: true,
//       //     icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
//       //     style: const TextStyle(color: Colors.white),
//       //     onChanged: (String? newValue) {
//       //       setState(() {
//       //         _selectedLanguage = newValue!;
//       //       });
//       //     },
//       //     items:
//       //         _languages.map<DropdownMenuItem<String>>((String value) {
//       //           return DropdownMenuItem<String>(
//       //             value: value,
//       //             child: Padding(
//       //               padding: const EdgeInsets.symmetric(horizontal: 8),
//       //               child: Text(value),
//       //             ),
//       //           );
//       //         }).toList(),
//       //   ),
//       // ),
//     );
//   }
// }
