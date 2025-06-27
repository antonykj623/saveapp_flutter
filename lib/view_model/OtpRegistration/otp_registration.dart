
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../services/API_services/API_services.dart';

class OtpRegistration extends StatefulWidget {

  final String  name,email, password,confirmpass,coupen,mobile,country,state,language;
  const OtpRegistration({Key? key, required this.name, required this.email, required this.password, required this.confirmpass, required this.coupen, required this.mobile,required this.country,required this.state, required this.language}) : super(key: key);

  @override
  State<OtpRegistration> createState() => _SlidebleListState( this.name,  this.email, this.password, this.confirmpass, this.coupen, this.mobile, this.country,this.state,this.language);
}

class _SlidebleListState extends State<OtpRegistration> {
  String? otp = "";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final String  name,email, password,confirmpass,coupen,mobile,country,state,language;
  _SlidebleListState( this.name,  this.email, this.password, this.confirmpass, this.coupen, this.mobile,this.country,this.state,this.language);

  void showOtpDialog(BuildContext context, String otp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Your OTP Code"),
          content: Text(
            otp,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
@override

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    otp = generateFourDigitOTP();
    showOtpDialog(context, otp ?? "no otp");
  });

}
  String generateFourDigitOTP() {
    var rng = Random();
    int otp = 1000 + rng.nextInt(9000); // Ensures number is between 1000 and 9999
    return otp.toString();
  }
  void Registration() async {
    var uuid = Uuid().v4(); // generates a random UUID
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    Map<String, String> regdata = {
      "mobile": mobile,
      "password": password,
      "confirmpassword":confirmpass,
      "email":email,
      "sp_reg_code":"0",
      "sp_reg_id":"0",
      "language":language,
      "stateid":state,
      "country_id":country,
      "uuid": uuid,
      "timestamp": timestamp,
    };

    ApiHelper api = ApiHelper();

    try {

      String regresponse = await api.postApiResponse("UserAuthenticate.php", regdata);

      print("Response: $regresponse");

    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var now_date;
    String _result = "";
    // String otpCode = generateFourDigitOTP();
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Registration')),
     body: Form(

         key: _formKey,
  child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/otpimage.jpg'),
            SizedBox(height: 20),
            TextFormField(
              controller: _otpController,
              decoration: InputDecoration(
                hintText: 'Enter OTP Code',
                border: OutlineInputBorder(),


              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please Enter Otp';
                }
                return null;
              },

              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if(_otpController.text == "" && _otpController.text == otp){
                  _otpController.text = "Please enter a valid OTP";
                }
                else{
                  Registration();
                  print("Otp is correct $otp");
                }
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't get Otp code? "),
                TextButton(onPressed: () {}, child: Text('Resend')),
              ],
            ),
          ],
        )
     ),
    );
  }
}