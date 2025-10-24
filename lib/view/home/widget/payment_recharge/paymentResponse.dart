import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weipl_checkout_flutter/weipl_checkout_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentResponse {
  final String statusCode;
  final String statusMessage;
  final String description;
  final String transactionId;
  final String orderId;
  final String customerId;
  final String amount;
  final String mobileInfo;
  final String txnDateTime;
  final String uuid;
  final String hashValue;
  final String merchantCode;

  PaymentResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.description,
    required this.transactionId,
    required this.orderId,
    required this.customerId,
    required this.amount,
    required this.mobileInfo,
    required this.txnDateTime,
    required this.uuid,
    required this.hashValue,
    required this.merchantCode,
  });

  factory PaymentResponse.fromResponse(dynamic response) {
    if (response == null || response['msg'] == null) {
      throw Exception('Invalid response format');
    } 

    List<String> parts = response['msg'].split('|');
    if (parts.length < 16) {
      throw Exception('Insufficient response parts: ${parts.length}');
    }

    return PaymentResponse(
      statusCode: parts[0],
      statusMessage: parts[1],
      description: parts[2],
      transactionId: parts[3],
      orderId: parts[4],
      customerId: parts[5],
      amount: parts[6],
      mobileInfo: parts[7],
      txnDateTime: parts[8],
      uuid: parts[14],
      hashValue: parts[15],
      merchantCode: response['merchant_code'] ?? '',
    );
  }

  bool get isSuccess => statusCode == "0300" && statusMessage == "SUCCESS";

  String get transactionDetails =>
      "Transaction ID: $transactionId\n"
      "Order ID: $orderId\n"
      "Customer ID: $customerId\n"
      "Transaction Date: $txnDateTime\n"
      "Message: $statusMessage";
}

class UpiApp {
  final String name;
  final String packageName;
  final String iosScheme;
  final String displayName;

  UpiApp({
    required this.name,
    required this.packageName,
    required this.iosScheme,
    required this.displayName,
  });

  static List<UpiApp> get availableApps => [
        UpiApp(
          name: 'gpay',
          packageName: 'com.google.android.apps.nfc.payment',
          iosScheme: 'gpay',
          displayName: 'Google Pay',
        ),
        UpiApp(
          name: 'phonepe',
          packageName: 'com.phonepe.app',
          iosScheme: 'phonepe',
          displayName: 'PhonePe',
        ),
        UpiApp(
          name: 'paytm',
          packageName: 'net.one97.paytm',
          iosScheme: 'paytm',
          displayName: 'Paytm',
        ),
        UpiApp(
          name: 'bhim',
          packageName: 'in.org.npci.upiapp',
          iosScheme: 'bhim',
          displayName: 'BHIM UPI',
        ),
        UpiApp(
          name: 'mobikwik',
          packageName: 'com.mobikwik_new',
          iosScheme: 'mobikwik',
          displayName: 'MobiKwik',
        ),
      ];
}

class WeiplPaymentHandler {
  WeiplCheckoutFlutter? _wlCheckoutFlutter;
  Function(PaymentResponse)? _onSuccess;
  Function(String)? _onError;
  Function(PaymentResponse)? _onFailure;

  void initialize({
    required Function(PaymentResponse) onSuccess,
    required Function(String) onError,
    required Function(PaymentResponse) onFailure,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onFailure = onFailure;
    _wlCheckoutFlutter = WeiplCheckoutFlutter();
    _wlCheckoutFlutter!.on(WeiplCheckoutFlutter.wlResponse, _handlePaymentResponse);
  }

  void _handlePaymentResponse(dynamic response) {
    try {
      final paymentResponse = PaymentResponse.fromResponse(response);
      if (paymentResponse.isSuccess) {
        _storePaymentSuccess(paymentResponse);
        _onSuccess?.call(paymentResponse);
      } else {
        _onFailure?.call(paymentResponse);
      }
      _updatePaymentStatus(paymentResponse);
    } catch (e) {
      _onError?.call('Error processing payment response: $e');
    }
  }

  Future<void> _storePaymentSuccess(PaymentResponse response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_transaction_id', response.transactionId);
      await prefs.setString('last_order_id', response.orderId);
      await prefs.setString('last_customer_id', response.customerId);
      await prefs.setString('last_transaction_date', response.txnDateTime);
      await prefs.setString('last_paid_amount', response.amount);
    } catch (e) {
      _onError?.call('Error storing payment success details: $e');
    }
  }

  Future<void> _updatePaymentStatus(PaymentResponse response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('final_payment_status', response.isSuccess ? "1" : "0");
      await prefs.setString('transaction_details', response.transactionDetails);
      await prefs.setString('final_payment_message', response.statusMessage);
    } catch (e) {
      _onError?.call('Error updating payment status: $e');
    }
  }

  Future<void> openPaymentGateway({
    required String token,
    required String merchantCode,
    required String customerId,
    required String mobileNumber,
    required String transactionId,
    required double amount,
    String? consumerEmailId,
    bool enableUpiRedirect = true,
  }) async {
    try {
      if (_wlCheckoutFlutter == null) {
        throw Exception('Payment handler not initialized. Call initialize() first.');
      }

      String deviceID = Platform.isAndroid ? "AndroidSH2" : "iOSSH2";
      var reqJson = {
        "features": {
          "enableAbortResponse": true,
          "enableExpressPay": true,
          "enableInstrumentDeRegistration": true,
          "enableMerTxnDetails": true,
        },
        "consumerData": {
          "deviceId": deviceID,
          "token": token,
          "paymentMode": enableUpiRedirect ? "upi" : "all",
          "merchantLogoUrl": "https://www.paynimo.com/CompanyDocs/company-logo-vertical.png",
          "merchantId": merchantCode,
          "currency": "INR",
          "consumerId": customerId,
          "consumerMobileNo": mobileNumber,
          "txnId": transactionId,
          "items": [
            {
              "itemId": "first",
              "amount": amount.toStringAsFixed(2),
              "comAmt": "0",
            },
          ],
          "customStyle": {
            "PRIMARY_COLOR_CODE": "#45beaa",
            "SECONDARY_COLOR_CODE": "#FFFFFF",
            "BUTTON_COLOR_CODE_1": "#2d8c8c",
            "BUTTON_COLOR_CODE_2": "#FFFFFF",
          },
          "upiConfiguration": {
            "vpa": "",
            "enableVpaValidation": true,
            "hideVpaField": false,
          },
        },
      };

      if (consumerEmailId != null && consumerEmailId.isNotEmpty) {
        reqJson["consumerData"]?["consumerEmailId"] = consumerEmailId;
      }

      _wlCheckoutFlutter!.open(reqJson);
    } catch (e) {
      _onError?.call('Failed to open payment gateway: $e');
    }
  }

  Future<void> redirectToUpiApp({
    required String upiId,
    required String merchantName,
    required String transactionId,
    required double amount,
    String? upiAppName,
  }) async {
    try {
      String upiUrl =
          'upi://pay?pa=$upiId&pn=$merchantName&tr=$transactionId&am=${amount.toStringAsFixed(2)}&cu=INR&tn=Recharge Payment';
      if (upiAppName != null) {
        final upiApp = UpiApp.availableApps.firstWhere(
          (app) => app.name == upiAppName,
          orElse: () => UpiApp.availableApps.first,
        );
        String appSpecificUrl = Platform.isAndroid
            ? 'intent://pay?${Uri.parse(upiUrl).query}#Intent;scheme=upi;package=${upiApp.packageName};end'
            : '${upiApp.iosScheme}://pay?${Uri.parse(upiUrl).query}';
        if (await canLaunch(appSpecificUrl)) {
          await launch(appSpecificUrl);
          return;
        }
      }
      if (await canLaunch(upiUrl)) {
        await launch(upiUrl);
      } else {
        throw Exception('No UPI apps available');
      }
    } catch (e) {
      _onError?.call('Failed to open UPI app: $e');
    }
  }

  Future<List<UpiApp>> getAvailableUpiApps() async {
    List<UpiApp> availableApps = [];
    for (UpiApp app in UpiApp.availableApps) {
      try {
        String testUrl = Platform.isAndroid
            ? 'intent://pay?#Intent;scheme=upi;package=${app.packageName};end'
            : '${app.iosScheme}://';
        if (await canLaunch(testUrl)) {
          availableApps.add(app);
        }
      } catch (e) {
        // Skip apps that can't be launched
      }
    }
    return availableApps;
  }

  Future<void> showUpiAppSelector({
    required BuildContext context,
    required String upiId,
    required String merchantName,
    required String transactionId,
    required double amount,
  }) async {
    final availableApps = await getAvailableUpiApps();
    if (availableApps.isEmpty) {
      _onError?.call('No UPI apps available on this device');
      return;
    }

    if (availableApps.length == 1) {
      await redirectToUpiApp(
        upiId: upiId,
        merchantName: merchantName,
        transactionId: transactionId,
        amount: amount,
        upiAppName: availableApps.first.name,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Choose UPI App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableApps
              .map((app) => ListTile(
                    title: Text(app.displayName),
                    onTap: () {
                      Navigator.pop(context);
                      redirectToUpiApp(
                        upiId: upiId,
                        merchantName: merchantName,
                        transactionId: transactionId,
                        amount: amount,
                        upiAppName: app.name,
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void dispose() {
    _wlCheckoutFlutter = null;
    _onSuccess = null;
    _onError = null;
    _onFailure = null;
  }
}