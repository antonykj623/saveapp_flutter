import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:weipl_checkout_flutter/weipl_checkout_flutter.dart';
import 'package:crypto/crypto.dart'; // For SHA-512 hashing if needed
import 'package:http/http.dart' as http;

class WeiplPaymentScreen extends StatefulWidget {
  final String token;
  final String merchantId;
  final String customerId;
  final String transactionId;
  final double amount;
  final String mobileNumber;


  const WeiplPaymentScreen({
    Key? key,
    required this.token,
    required this.merchantId,
    required this.customerId,
    required this.transactionId,
    required this.amount,
    required this.mobileNumber,
  }) : super(key: key);

  @override
  _WeiplPaymentScreenState createState() => _WeiplPaymentScreenState();
}

class _WeiplPaymentScreenState extends State<WeiplPaymentScreen> {
  WeiplCheckoutFlutter wlCheckoutFlutter = WeiplCheckoutFlutter();

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  void _initializePayment() {
    print('🎯 ===== INITIALIZING WEIPL PAYMENT =====');
    print('🎫 Using Token: ${widget.token}');
    print('💰 Amount: ${widget.amount}');
    print('📱 Mobile: ${widget.mobileNumber}');

    // Set up response handler
    wlCheckoutFlutter.on(
      WeiplCheckoutFlutter.wlResponse,
      _handlePaymentResponse,
    );

    // Launch payment after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      _launchPaymentGateway();
    });
  }

  void _launchPaymentGateway() {
    try {
      String deviceID = "";

      // Validate platform and assign deviceId
      if (Platform.isAndroid) {
        deviceID = "AndroidSH2"; // Use supported deviceId
      } else if (Platform.isIOS) {
        deviceID = "iOSSH2"; // Use supported deviceId
      } else {
        throw Exception('Unsupported platform');
      }

      // Validate input parameters
      if (widget.token.isEmpty ||
          widget.merchantId.isEmpty ||
          widget.customerId.isEmpty ||
          widget.transactionId.isEmpty ||
          widget.mobileNumber.isEmpty ||
          widget.amount <= 0) {
        throw Exception('Invalid input parameters for payment');
      }

      // Create payment request JSON with complete and validated fields
      var reqJson = {
        "features": {
          "enableAbortResponse": true,
          "enableExpressPay": true,
          "enableInstrumentDeRegistration": true,
          "enableMerTxnDetails": true,
        },
        "consumerData": {
          "deviceId": deviceID,
          "token": widget.token,
          "paymentMode": 'all',
          "merchantLogoUrl":
              "https://www.paynimo.com/CompanyDocs/company-logo-vertical.png",
          "merchantId": widget.merchantId,
          "currency": "INR",
          "consumerId": widget.customerId,
          "consumerMobileNo": widget.mobileNumber,
          "txnId": widget.transactionId,
          "items": [
            {
              "itemId": "first",
              "amount": widget.amount.toStringAsFixed(2),
              "comAmt": "0",
            },
          ],
          "customStyle": {
            "PRIMARY_COLOR_CODE": "#45beaa",
            "SECONDARY_COLOR_CODE": "#FFFFFF",
            "BUTTON_COLOR_CODE_1": "#2d8c8c",
            "BUTTON_COLOR_CODE_2": "#FFFFFF",
          },
        },
      };

      print('🎯 ===== WEIPL REQUEST JSON =====');
      print('📦 Request: ${jsonEncode(reqJson)}');
      print('🎯 ===== LAUNCHING PAYMENT GATEWAY =====');

      // Launch the payment gateway
      wlCheckoutFlutter.open(reqJson);
    } catch (e) {
      print('❌ Error launching payment gateway: $e');
      _showErrorMessage('Failed to launch payment gateway: $e');
    }
  }

  void _handlePaymentResponse(Map<dynamic, dynamic> response) {
    print('🎯 ===== WEIPL PAYMENT RESPONSE =====');
    print('📥 Response: $response');

    try {
      String status = response['status']?.toString().toLowerCase() ?? '';
      String message = response['msg']?.toString() ?? 'Unknown error';

      if (status == 'success' || status == '1') {
        print('✅ Payment successful!');
        _handleSuccessfulPayment(response);
      } else if (status == 'failure' || status == '0') {
        print('❌ Payment failed: $message');
        _handleFailedPayment(response);
      } else if (status == 'cancel') {
        print('⚠️ Payment cancelled by user');
        _handleCancelledPayment(response);
      } else {
        print('❓ Unknown payment status: $status');
        _handleUnknownResponse(response);
      }
    } catch (e) {
      print('❌ Error processing payment response: $e');
      _showErrorMessage('Error processing payment response: $e');
    }
  }

  void _handleSuccessfulPayment(Map<dynamic, dynamic> response) {
    Navigator.pop(context); // Close payment screen

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text('Payment Successful!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mobile: ${widget.mobileNumber}'),
                Text('Amount: ₹${widget.amount.toStringAsFixed(2)}'),
                Text('Transaction ID: ${widget.transactionId}'),
                SizedBox(height: 10),
                Text('Response: ${response.toString()}'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _handleFailedPayment(Map<dynamic, dynamic> response) {
    Navigator.pop(context); // Close payment screen

    String errorMessage = response['msg']?.toString() ?? 'Payment failed';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 30),
                SizedBox(width: 10),
                Text('Payment Failed'),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: Text('Retry'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _handleCancelledPayment(Map<dynamic, dynamic> response) {
    Navigator.pop(context); // Close payment screen

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment cancelled by user'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleUnknownResponse(Map<dynamic, dynamic> response) {
    Navigator.pop(context); // Close payment screen

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Payment Status Unknown'),
            content: Text('Response: ${response.toString()}'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Gateway'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Initializing Payment Gateway...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Mobile: ${widget.mobileNumber}'),
                    Text('Amount: ₹${widget.amount.toStringAsFixed(2)}'),
                    Text('Transaction ID: ${widget.transactionId}'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    wlCheckoutFlutter.clear(); // Clean up the payment gateway
    super.dispose();
  }
}

// Updated _generatePaymentHash function
Future<String?> _generatePaymentHash(
  String merchantCode,
  String txnId,
  String amount,
  String customerId,
  String phone,
  String saltKey,
) async {
  try {
    print('🔐 ===== STARTING HASH GENERATION PROCESS =====');
    print('🏪 Merchant Code: "$merchantCode"');
    print('💳 Transaction ID: "$txnId"');
    print('💰 Amount: "$amount"');
    print('👤 Customer ID: "$customerId"');
    print('📱 Phone: "$phone"');
    print('🔑 Salt Key: "$saltKey"');

    // Validate inputs
    if (merchantCode.isEmpty ||
        txnId.isEmpty ||
        amount.isEmpty ||
        customerId.isEmpty ||
        phone.isEmpty ||
        saltKey.isEmpty) {
      print('❌ VALIDATION ERROR: One or more required fields are empty');
      return null;
    }

    // Construct hash string with all required fields
    String hashString =
        "$merchantCode|$txnId|$amount|$customerId|$phone|||||||0|||||$saltKey";

    print('📝 Hash String: "$hashString"');
    print('📏 Hash String Length: ${hashString.length}');

    // Generate SHA-512 hash (if required by the payment gateway)
    var bytes = utf8.encode(hashString);
    var hash = sha512.convert(bytes).toString();
    print('🔒 Generated SHA-512 Hash: "$hash"');

    // Alternatively, call the generateHash.php API if that's what your gateway requires
    final apiHelper = ApiHelper();
    Map<String, String> formData = {'data': hashString};
    print('📤 Hash Generation Request Data: $formData');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    print('⏰ Request Timestamp: $timestamp');

    final response = await apiHelper.postApiResponse(
      'generateHash.php?q=$timestamp',
      formData,
    );

    print('📥 ===== HASH GENERATION API RESPONSE =====');
    print('📦 Raw Response: "$response"');

    if (response.isNotEmpty) {
      try {
        final jsonResponse = jsonDecode(response);
        print('📊 Parsed JSON: $jsonResponse');

        String? hashToken;
        if (jsonResponse['value'] != null) {
          hashToken = jsonResponse['value'].toString();
          print('✅ Found token in "value" key: "$hashToken"');
        } else if (jsonResponse['token'] != null) {
          hashToken = jsonResponse['token'].toString();
          print('✅ Found token in "token" key: "$hashToken"');
        } else if (jsonResponse['hash'] != null) {
          hashToken = jsonResponse['hash'].toString();
          print('✅ Found token in "hash" key: "$hashToken"');
        }

        if (hashToken != null && hashToken.isNotEmpty && hashToken != 'null') {
          print('🎯 ===== TOKEN EXTRACTED SUCCESSFULLY =====');
          print('✅ Generated Hash Token: "$hashToken"');
          print('📏 Token Length: ${hashToken.length}');
          return hashToken;
        } else {
          print('❌ No valid token found in response');
          return null;
        }
      } catch (parseError) {
        print('❌ JSON Parse Error: $parseError');
        return null;
      }
    } else {
      print('❌ Empty response from hash generation API');
      return null;
    }
  } catch (e) {
    print('❌ Hash generation error: $e');
    return null;
  }
}
