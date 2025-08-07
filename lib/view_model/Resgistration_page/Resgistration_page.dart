import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/app/Modules/accounts/global.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:new_project_2025/view_model/OtpRegistration/otp_registration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registration App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

var apidata = ApiHelper();

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  initState() {
    super.initState();
    fetchCountryData();
  }

  final _formKey = GlobalKey<FormState>();
  bool _termsAgreed = false;
  bool _hasCouponCode = false;
  String _selectedCountry = 'INDIA';
  String _selectedState = 'Andaman and Nicobar Islands';
  String _selectedLanguage = 'English';
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  List<dynamic> dataList = [];
  List<dynamic> dropdowncountryItems = [];
  List<dynamic> dropdownstateitem = [];
  bool isLoading = true;
  String? selectedValue;
  String? selectedValue1;
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  final List<dynamic> data = [];
  @override
  void dispose() {
    _couponController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> fetchCountryData() async {
    ApiHelper apiHelper = new ApiHelper();
    String response = await apiHelper.getApiResponse(
      "getCountry.php?timestamp=" + DateTime.now().toString(),
    );

    final Map<String, dynamic> jsonResponse = json.decode(response);

    final List<dynamic> data = jsonResponse['data'];
    print("Datas are...$data");

    setState(() {
      dropdowncountryItems = data;
      isLoading = false;
    });
    fetchDataState();
  }

  Future<void> fetchDataState() async {
    ApiHelper apiHelper = new ApiHelper();
    String response = await apiHelper.getApiResponse(
      "getState.php?timestamp=" +
          DateTime.now().toString() +
          "&countryid=$selectedValue",
    );

    final Map<String, dynamic> jsonResponse = json.decode(response);

    // Access the 'data' key from the JSON response
    final List<dynamic> data = jsonResponse['data'];
    print("Datas are...$data");

    setState(() {
      dropdownstateitem = data;
      isLoading = false;
    });
  }

  void Registration() async {
    var uuid = Uuid().v4();
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    Map<String, String> regdata = {
      "mobile": _mobileController.text.trim(),
      "password": _passwordController.text.trim(),
      "confirmpassword": _confirmPasswordController.text.trim(),
      "email": _emailController.text.trim(),
      "sp_reg_code": "0",
      "sp_reg_id": "0",
      "stateid": "$selectedValue",
      "country_id": "$selectedValue1",
      "uuid": uuid,
      "timestamp": timestamp,
    };

    ApiHelper api = ApiHelper();

    try {
      String regresponse = await api.postApiResponse(
        " UserAuthenticate.php",
        regdata,
      );

      print("Response: $regresponse");
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _launchTermsURL() async {
    const url = 'https://mysaving.in/index.php/web/termsCondition';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not launch terms and conditions page');
      }
    } catch (e) {
      _showSnackBar('Error launching URL: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _validateCoupon() {
    // Placeholder for coupon validation logic
    final coupon = _couponController.text.trim();
    if (coupon.isEmpty) {
      _showSnackBar('Please enter a coupon code');
    } else {
      // Simulate coupon validation (replace with actual API call)
      if (coupon == 'SAVE10') {
        _showSnackBar('Coupon applied successfully!');
      } else {
        _showSnackBar('Invalid coupon code');
      }
    }
  }

  void _submitForm() {
    if (!_termsAgreed) {
      _showSnackBar('Please agree to terms and conditions');
      return;
    }

    if (_formKey.currentState!.validate()) {
      print('Form Data:');
      print('Name: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Country: $_selectedCountry');
      print('State: $_selectedState');
      print('Mobile: ${_mobileController.text}');
      print('Coupon: ${_hasCouponCode ? _couponController.text : "None"}');
      print('Language: $_selectedLanguage');

      _launchTermsURL();

      _showSnackBar('Registration successful!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registartion"),
        backgroundColor: Color(0xFF037671),

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(color: Colors.white, Icons.arrow_back),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF252c45), Color(0xFF096c6c), Color(0xFF007a74)],
          ),
        ),
        child: SafeArea(
          child: Column(children: [_buildForm(), _buildBottomSection()]),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  validator:
                      (value) =>
                          value!.trim().isEmpty
                              ? 'Please enter your name'
                              : null,
                ),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Please enter your email';
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                _buildCountryDropdown(),
                _buildStateDropdown(),
                _buildTextField(
                  controller: _mobileController,
                  label: 'Mobile Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                _buildCouponSection(),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: !_showPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed:
                        () => setState(() => _showPassword = !_showPassword),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter a password';
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: !_showConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed:
                        () => setState(
                          () => _showConfirmPassword = !_showConfirmPassword,
                        ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                _buildLanguageDropdown(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(4),
      ),

      // DropdownButtonFormField<String>(
      //   dropdownColor: const Color(0xFF096c6c),
      //   style: const TextStyle(color: Colors.white),
      //   value: _selectedCountry,
      //   decoration: const InputDecoration(
      //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //     border: InputBorder.none,
      //   ),
      //   icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      //   onChanged: (String? newValue) {
      //     setState(() {
      //       _selectedCountry = newValue!;
      //     });
      //   },
      child:
          dropdowncountryItems.isEmpty
              ? CircularProgressIndicator()
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  hint: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Text(
                      'Select a Country',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  dropdownColor: const Color(0xFF096c6c),
                  style: const TextStyle(color: Colors.white),
                  value: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                    fetchDataState();
                  },

                  //     style: TextStyle(
                  // color: Colors.black,
                  // fontSize: 16,),
                  items:
                      dropdowncountryItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'],
                          child: Text(
                            item['country_name'],
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                ),
              ),
    );
  }

  Widget _buildStateDropdown() {
    return (dropdownstateitem.length > 0)
        ? Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white54),
            borderRadius: BorderRadius.circular(4),
          ),
          child:
              dropdownstateitem.isEmpty
                  ? CircularProgressIndicator()
                  : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      hint: Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Text(
                          'Select a Country',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      dropdownColor: const Color(0xFF096c6c),
                      style: const TextStyle(color: Colors.white),
                      value: selectedValue1,
                      onChanged: (value) {
                        setState(() {
                          selectedValue1 = value;
                        });
                      },

                      //     style: TextStyle(
                      // color: Colors.black,
                      // fontSize: 16,),
                      items:
                          dropdownstateitem.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['id'],
                              child: Text(
                                item['state_name'],
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
          // DropdownButtonFormField<String>(
          //   dropdownColor: const Color(0xFF096c6c),
          //   style: const TextStyle(color: Colors.white),
          //   value: _selectedState,
          //   decoration: const InputDecoration(
          //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //     border: InputBorder.none,
          //   ),
          //   icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          //   onChanged: (String? newValue) {
          //     setState(() {
          //       _selectedState = newValue!;
          //     });
          //   },
          //   items:
          //       <String>[
          //         'Andaman and Nicobar Islands',
          //         'Andhra Pradesh',
          //         'Delhi',
          //         'Gujarat',
          //         'Karnataka',
          //         'Maharashtra',
          //       ].map<DropdownMenuItem<String>>((String value) {
          //         return DropdownMenuItem<String>(value: value, child: Text(value));
          //       }).toList(),
          //   validator: (value) => value == null ? 'Please select a state' : null,
          // ),
        )
        : Container();
  }

  Widget _buildCouponSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do you have promotional coupon code ?',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _hasCouponCode = true),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _hasCouponCode ? Colors.white : Colors.transparent,
                    border: Border.all(color: Colors.white54),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color:
                          _hasCouponCode
                              ? const Color(0xFF096c6c)
                              : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _hasCouponCode = false),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: !_hasCouponCode ? Colors.white : Colors.transparent,
                    border: Border.all(color: Colors.white54),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'No',
                    style: TextStyle(
                      color:
                          !_hasCouponCode
                              ? const Color(0xFF096c6c)
                              : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_hasCouponCode) const SizedBox(height: 16),
        if (_hasCouponCode)
          Row(
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: TextFormField(
                    controller: _couponController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: const InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: TextStyle(color: Colors.black38),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007a74), Color(0xFF096c6c)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextButton(
                    onPressed: _validateCoupon,
                    child: const Text(
                      'Validate',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (_hasCouponCode) const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: const Color(0xFF096c6c),
        style: const TextStyle(color: Colors.white),
        value: _selectedLanguage,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        onChanged: (String? newValue) {
          setState(() {
            _selectedLanguage = newValue!;
          });
        },
        items:
            <String>[
              'English',
              'Hindi',
              'Tamil',
              'Telugu',
              'Marathi',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        validator: (value) => value == null ? 'Please select a language' : null,
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Checkbox(
                value: _termsAgreed,
                onChanged: (bool? value) {
                  setState(() {
                    _termsAgreed = value ?? false;
                  });
                },
                side: const BorderSide(color: Colors.white),
                checkColor: Colors.white,
                activeColor: const Color(0xFF096c6c),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  // onTap: _launchTermsURL, // Open terms URL when text is tapped
                  child: const Text(
                    'I agree to terms and conditions',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, proceed
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Processing Data')));
                    _submitForm;
                    final name = _nameController.text;
                    final email = _emailController.text;
                    final mobile = _mobileController.text;
                    final password = _passwordController.text;
                    final confirmpass = _confirmPasswordController.text;
                    final coupen = _couponController.text;
                    final country = selectedValue.toString();
                    final state = selectedValue1.toString();
                    final language = "English";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => OtpRegistration(
                              name: name,
                              email: email,
                              mobile: mobile,
                              password: password,
                              confirmpass: confirmpass,
                              coupen: coupen,
                              country: country,
                              state: state,
                              language: language,
                            ),
                      ),
                    );
                  }
                },

                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Color(0xFF096c6c),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Do you have an account?',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  //  Registration();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SaveApp()),
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: const Center(child: Text('Login Screen')),
//     );
//   }
// }
