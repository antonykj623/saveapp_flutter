import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/app/Modules/login/login_page.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/Rechargeapiclass.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/Request_class.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/payment_type.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/weilpaymentscreen/paymentoption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weipl_checkout_flutter/weipl_checkout_flutter.dart';

class RechargePlansScreen extends StatefulWidget {
  final String mobileNumber;
  final String operator;
  final String circle;
  final Map<String, dynamic> operatorData;
  final MobilePlanResponse planResponse;

  const RechargePlansScreen({
    Key? key,
    required this.mobileNumber,
    required this.operator,
    required this.circle,
    required this.operatorData,
    required this.planResponse,
  }) : super(key: key);

  @override
  _RechargePlansScreenState createState() => _RechargePlansScreenState();
}

class _RechargePlansScreenState extends State<RechargePlansScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late AnimationController _heroController;
  late AnimationController _listController;
  late AnimationController _fabController;
  late Animation<double> _heroAnimation;
  late Animation<double> _listAnimation;
  late Animation<double> _fabAnimation;
  late Animation<double> _fabScaleAnimation;
  String selectedPlanId = '';
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  List<Map<String, dynamic>> convertedPlans = [];
  List<String> availableCategories = [];

  static const String rechargeBaseUrl = "https://mysaveapp.com/easyrecharge/";
  static const List<String> arroperators = ["Airtel", "Vi", "Jio", "BSNL"];
  static const List<String> arroperator_code = ["AT", "VI", "RJ", "CG"];
  static const List<String> arrspkey = ["3", "37", "116", "4"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _convertApiPlansToLocal();
    _setupCategories();

    _tabController = TabController(
      length: availableCategories.length,
      vsync: this,
    );

    _heroController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _listController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
    );
    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listController, curve: Curves.elasticOut),
    );

    _fabAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeInOut));

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeInOut));

    _heroController.forward();
    Future.delayed(Duration(milliseconds: 400), () {
      _listController.forward();
    });
    _fabController.repeat(reverse: true);

    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  void _convertApiPlansToLocal() {
    convertedPlans.clear();
    for (var category in widget.planResponse.categories) {
      for (var plan in category.plans) {
        final convertedPlan = MobilePlansApiService.convertApiPlanToLocal(
          plan,
          category.name.toLowerCase(),
        );
        convertedPlans.add(convertedPlan);
      }
    }
  }

  void _setupCategories() {
    Set<String> categorySet = {'all'};
    for (var category in widget.planResponse.categories) {
      String categoryName = category.name.toLowerCase();
      if (categoryName.contains('unlimited') ||
          categoryName.contains('combo')) {
        categorySet.add('unlimited');
      } else if (categoryName.contains('data') ||
          categoryName.contains('internet')) {
        categorySet.add('data');
      } else if (categoryName.contains('talktime') ||
          categoryName.contains('topup')) {
        categorySet.add('talktime');
      } else {
        categorySet.add('other');
      }
    }
    availableCategories = categorySet.toList();
    if (availableCategories.length < 4) {
      availableCategories = ['all', 'unlimited', 'data', 'talktime'];
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _heroController.dispose();
    _listController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('📱 App Lifecycle State: $state');
    if (state == AppLifecycleState.paused) {
      _fabController.stop();
      _heroController.stop();
      _listController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _fabController.repeat(reverse: true);
    }
  }

  List<Map<String, dynamic>> getFilteredPlans(String category) {
    var plans =
        convertedPlans.where((plan) {
          final matchesCategory =
              category == 'all' ? true : _planMatchesCategory(plan, category);
          final matchesSearch =
              searchQuery.isEmpty ||
              plan['amount'].toString().contains(searchQuery) ||
              (plan['description'] as String?)?.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ==
                  true ||
              (plan['benefits'] as List<dynamic>?)?.any(
                    (benefit) =>
                        (benefit as String?)?.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ) ==
                        true,
                  ) ==
                  true;
          return matchesCategory && matchesSearch;
        }).toList();

    plans.sort((a, b) {
      if (a['popular'] == true && b['popular'] != true) return -1;
      if (a['popular'] != true && b['popular'] == true) return 1;
      return (a['amount'] as int).compareTo(b['amount'] as int);
    });
    return plans;
  }

  bool _planMatchesCategory(Map<String, dynamic> plan, String category) {
    String planCategory = plan['category']?.toString().toLowerCase() ?? '';
    switch (category) {
      case 'unlimited':
        return planCategory.contains('unlimited') ||
            planCategory.contains('combo') ||
            (plan['calls'] as String?)?.toLowerCase().contains('unlimited') ==
                true;
      case 'data':
        return planCategory.contains('data') ||
            planCategory.contains('internet') ||
            (plan['data'] as String?)?.isNotEmpty == true;
      case 'talktime':
        return planCategory.contains('talktime') ||
            planCategory.contains('topup') ||
            (plan['talktime'] as double? ?? 0) > 0;
      default:
        return true;
    }
  }

  void _selectPlan(String planId, Map<String, dynamic> planData) {
    setState(() {
      selectedPlanId = planId;
    });
    HapticFeedback.mediumImpact();
    _showPaymentTypeDialog(planData);
  }

  void _showPaymentTypeDialog(Map<String, dynamic> planData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PaymentTypeDialog(
            amount: planData['amount'].toDouble(),
            onPaymentSelected: (paymentType, totalAmount) {
              _processPayment(planData, paymentType, totalAmount);
            },
          ),
    );
  }

  Future<Map<String, dynamic>> _parseJsonInIsolate(String response) async {
    return await compute((String data) {
      return json.decode(data) as Map<String, dynamic>;
    }, response);
  }

  Future<String> getRechargeApi(String url) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');

    if (token == null || token.isEmpty) {
      print('⚠️ Token is missing or empty');
      throw Exception('Authentication token is missing');
    }

    Map<String, String> headers = {
      "Authorization": token,
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final uri = Uri.parse(url);
    print('🌐 GET Request URL: $uri');
    print('📤 Headers: $headers');

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 404) {
        throw Exception(
          'Endpoint not found: ${response.statusCode} - ${response.body}',
        );
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: Access denied');
      } else {
        throw Exception(
          'Failed to fetch data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ GET Request Error: $e');
      rethrow;
    }
  }

  Future<String> postRechargeApi(
    String endpoint,
    Map<String, String> postData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');

    if (token == null || token.isEmpty) {
      print('⚠️ Token is missing or empty');
      throw Exception('Authentication token is missing');
    }

    Map<String, String> headers = {
      "Authorization": token,
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final url = Uri.parse(rechargeBaseUrl + endpoint);
    print('🌐 POST Request URL: $url');
    print('📤 Headers: $headers');
    print('📤 Body: $postData');

    try {
      final response = await http
          .post(url, headers: headers, body: postData)
          .timeout(Duration(seconds: 30));

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 404) {
        throw Exception(
          'Endpoint not found: ${response.statusCode} - ${response.body}',
        );
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: Access denied');
      } else {
        throw Exception(
          'Failed to post data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ POST Request Error: $e');
      rethrow;
    }
  }

  Future<void> _processPayment(
    Map<String, dynamic> planData,
    String paymentType,
    double totalAmount,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');

    if (userId == null || userId.isEmpty) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackBar('Please log in to continue.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    print(
      '🔔 Payment process initiated for user: $userId, amount: $totalAmount, payment type: $paymentType',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) =>
              _buildPaymentProcessingDialog(planData, paymentType, totalAmount),
    );

    try {
      int operatorIndex = arroperators.indexOf(widget.operatorData['name']);
      String spKey = operatorIndex != -1 ? arrspkey[operatorIndex] : '';

      if (!arroperators.contains(widget.operatorData['name']) ||
          spKey.isEmpty) {
        throw Exception('Invalid operator or spkey');
      }

      String? operatorCircle = MobilePlansApiService.circleCodes[widget.circle];
      if (operatorCircle == null) {
        throw Exception('Invalid circle');
      }

      final rechargeRequest = RechargeRequest(
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        mobileNumber: widget.mobileNumber,
        accountNumber: widget.mobileNumber,
        transactionId: '',
        operatorCircle: operatorCircle,
        amount: totalAmount.toStringAsFixed(2),
        rechargeAmount: planData['amount'].toString(),
        operatorName: widget.operatorData['name'],
        rpId: '',
        agentId: '',
        status: '2',
        rechargeType: '1',
        spKey: spKey,
        paymentStatus: '4',
        paymentMode: paymentType,
      );

      final apiHelper = ApiHelper();

      print('🚀 STEP 1: Initiating PostTransactionata.php API call...');
      print('📤 Request Data: ${rechargeRequest.toJson()}');

      final response = await apiHelper.postApiResponse(
        'PostTransactionata.php',
        rechargeRequest.toJson(),
      );

      print('📥 Raw API Response (PostTransactionata.php): $response');

      final jsonResponse = await _parseJsonInIsolate(response);
      print('✅ Parsed JSON Response (PostTransactionata.php): $jsonResponse');
      print(
        '🔍 Status Type: ${jsonResponse['status'].runtimeType}, Value: ${jsonResponse['status']}',
      );

      if (jsonResponse['status'].toString() == 'success' ||
          jsonResponse['status'].toString() == '1' ||
          jsonResponse['status'].toString() == '2') {
        await prefs.setString(
          'payment_status',
          jsonResponse['status'].toString(),
        );
        await prefs.setString('payment_message', jsonResponse['message'] ?? '');

        int? transactionId = int.tryParse(jsonResponse['id']?.toString() ?? '');
        if (transactionId != null) {
          await prefs.setInt('payment_id', transactionId);
        } else {
          print(
            '⚠️ Warning: Transaction ID is null or invalid: ${jsonResponse['id']}',
          );
        }

        print(
          '💾 Saved payment data to SharedPreferences (transactionId: $transactionId)',
        );

        print('🚀 STEP 2: Initiating getPaymentCredentials.php API call...');

        try {
          final credentialsResponse = await apiHelper.getApiResponse(
            'getPaymentCredentials.php',
          );

          print('🎯 ===== PAYMENT CREDENTIALS RESPONSE START =====');
          print('📥 Raw Response: $credentialsResponse');
          print('📏 Response Length: ${credentialsResponse.length}');
          print('🎯 ===== PAYMENT CREDENTIALS RESPONSE END =====');

          if (credentialsResponse.isEmpty) {
            print('❌ Error: getPaymentCredentials.php returned empty response');
            _showErrorSnackBar(
              'Failed to fetch payment credentials: Empty response',
            );
            Navigator.pop(context);
            return;
          }

          final credentialsJson = await _parseJsonInIsolate(
            credentialsResponse,
          );
          print('🎯 ===== PARSED PAYMENT CREDENTIALS START =====');
          print('📊 Parsed JSON: $credentialsJson');

          String merchantCode =
              credentialsJson['merchantcode']?.toString() ?? '';
          String saltKey = credentialsJson['saltkey']?.toString() ?? '';
          String customerId = credentialsJson['customerid']?.toString() ?? '';

          print('🏪 Merchant Code: $merchantCode');
          print('🔐 Salt Key: $saltKey');
          print('👤 Customer ID: $customerId');
          print('🎯 ===== PARSED PAYMENT CREDENTIALS END =====');

          if (merchantCode.isEmpty || saltKey.isEmpty || customerId.isEmpty) {
            print('❌ Error: Missing required payment credentials');
            _showErrorSnackBar('Failed to fetch valid payment credentials');
            Navigator.pop(context);
            return;
          }

          await prefs.setString('payment_credentials', credentialsResponse);
          print('💾 Saved payment credentials to SharedPreferences');

          print('🚀 STEP 3: Initiating generateHash.php API call...');
          String paidAmount = totalAmount.toStringAsFixed(2);

          String a =
              '$merchantCode|$transactionId|$paidAmount||$customerId|${widget.mobileNumber}|||||||||||$saltKey';

          Map<String, String> tokenPayload = {'data': a};
          print('📤 Token Generation Data: $a');

          final timestamp = apiHelper.getTimeStamp();
          print('⏰ Timestamp for generateHash.php: $timestamp');

          try {
            final tokenResponse = await apiHelper.postEcommerce(
              '${ApiHelper.generateHash}?q=$timestamp',
              formDataPayload: tokenPayload,
            );

            print('🎯 ===== TOKEN GENERATION RESPONSE START =====');
            print('📥 Raw Response (generateHash.php): $tokenResponse');
            print('📏 Response Length: ${tokenResponse.length}');
            print('🔍 Response Type: ${tokenResponse.runtimeType}');
            print('📋 Response is Empty: ${tokenResponse.isEmpty}');
            print('🎯 ===== TOKEN GENERATION RESPONSE END =====');

            if (tokenResponse.isEmpty) {
              print('❌ Error: generateHash.php returned empty response');
              _showErrorSnackBar('Failed to generate token: Empty response');
              Navigator.pop(context);
              return;
            }

            final tokenJson = await _parseJsonInIsolate(tokenResponse);
            print('✅ Parsed JSON Response (generateHash.php): $tokenJson');
            print('📊 JSON Response Keys: ${tokenJson.keys.join(", ")}');

            String? generatedToken =
                tokenJson['value']?.toString() ??
                tokenJson['hash']?.toString() ??
                tokenJson['token']?.toString() ??
                tokenJson['generated_hash']?.toString();

            if (generatedToken == null) {
              print('❌ Error: Token not found in response');
              print(
                '🔍 Available keys in response: ${tokenJson.keys.join(", ")}',
              );
              _showErrorSnackBar('Failed to generate token: Token not found');
              Navigator.pop(context);
              return;
            }

            print('🔑 Generated Token: $generatedToken');
            print('📏 Token Length: ${generatedToken.length}');

            await prefs.setString('payment_token', generatedToken);
            print('💾 Saved payment token to SharedPreferences');

            Navigator.pop(context);

            String deviceID = "";
            if (Platform.isAndroid) {
              deviceID = "AndroidSH2";
            } else if (Platform.isIOS) {
              deviceID = "iOSSH2";
            }

            var reqJson = {
              "features": {
                "enableAbortResponse": true,
                "enableExpressPay": true,
                "enableInstrumentDeRegistration": true,
                "enableMerTxnDetails": true,
              },
              "consumerData": {
                "deviceId": deviceID,
                "token": generatedToken,
                "paymentMode": "all",
                "merchantLogoUrl":
                    "https://www.paynimo.com/CompanyDocs/company-logo-vertical.png",
                "merchantId": merchantCode,
                "currency": "INR",
                "consumerId": customerId,
                "consumerMobileNo": widget.mobileNumber,
                "txnId": transactionId.toString(),
                "items": [
                  {"itemId": "first", "amount": paidAmount, "comAmt": "0"},
                ],
                "customStyle": {
                  "PRIMARY_COLOR_CODE": "#45beaa",
                  "SECONDARY_COLOR_CODE": "#FFFFFF",
                  "BUTTON_COLOR_CODE_1": "#2d8c8c",
                  "BUTTON_COLOR_CODE_2": "#FFFFFF",
                },
              },
            };

            print('🎯 ===== FULL PAYMENT GATEWAY REQUEST JSON START =====');
            print('📤 Full Payment Gateway Request JSON:');
            print(json.encode(reqJson));
            print('🎯 ===== FULL PAYMENT GATEWAY REQUEST JSON END =====');

            print('🔍 ===== JSON COMPONENTS VERIFICATION =====');
            print('🆔 Device ID: $deviceID');
            print('🔑 Token: $generatedToken');
            print('🏪 Merchant ID: $merchantCode');
            print('👤 Consumer ID: $customerId');
            print('📱 Consumer Mobile: ${widget.mobileNumber}');
            print('🆔 Transaction ID: $transactionId');
            print('💰 Amount: $paidAmount');
            print('🔍 ===== JSON COMPONENTS VERIFICATION END =====');

            WeiplCheckoutFlutter wlCheckoutFlutter = WeiplCheckoutFlutter();
            wlCheckoutFlutter.on(WeiplCheckoutFlutter.wlResponse, (response) {
              print('🎯 Payment Gateway Response: $response');
              handleResponse(response, planData, paymentType, totalAmount);
            });

            print('🚀 Opening payment gateway...');
            wlCheckoutFlutter.open(reqJson);
          } catch (tokenError) {
            print('❌ Error during generateHash.php API call: $tokenError');
            _showErrorSnackBar('Failed to generate token: $tokenError');
            Navigator.pop(context);
            return;
          }
        } catch (apiError) {
          print('❌ Error fetching payment credentials: $apiError');
          _showErrorSnackBar('Failed to fetch payment credentials: $apiError');
          Navigator.pop(context);
        }
      } else {
        print(
          '❌ PostTransactionata.php did not return a success status: ${jsonResponse['status']}',
        );
        Navigator.pop(context);
        _showErrorSnackBar(
          'Payment initiation failed: ${jsonResponse['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('❌ Critical error in payment process: $e');
      Navigator.pop(context);
      _showErrorSnackBar('Payment error: $e');
    }
  }

  void handleResponse(
    dynamic response,
    Map<String, dynamic> planData,
    String paymentType,
    double totalAmount,
  ) async {
    try {
      print('📥 Raw Payment Response: $response');

      if (response == null || response['msg'] == null) {
        print('❌ Invalid response format');
        _showErrorSnackBar('Payment response invalid');
        return;
      }

      List<String> parts = response['msg']!.split('|');

      if (parts.length < 16) {
        print('❌ Insufficient response parts: ${parts.length}');
        _showErrorSnackBar('Invalid payment response format');
        return;
      }

      String statusCode = parts[0];
      String statusMessage = parts[1];
      String description = parts[2];
      String transactionId = parts[3];
      String orderId = parts[4];
      String customerId = parts[5];
      String amount = parts[6];
      String mobileInfo = parts[7];
      String txnDateTime = parts[8];
      String uuid = parts[14];
      String hashValue = parts[15];

      String paymentStatus = "6"; // Default failed status
      String msg1 = "Transaction failed";

      if (statusCode.compareTo("0300") == 0) {
        if (statusMessage.compareTo("SUCCESS") == 0) {
          paymentStatus = "5";
          msg1 = "Your transaction is successful";
          print('✅ Payment Successful!');

          await _storePaymentSuccess(
            transactionId,
            orderId,
            customerId,
            txnDateTime,
            amount,
          );

          _showPaymentSuccessDialogWithDetails(
            planData,
            paymentType,
            totalAmount,
            transactionId,
            orderId,
            customerId,
            txnDateTime,
            statusMessage,
          );
        } else {
          paymentStatus = "6";
          msg1 = "Transaction failed: $statusMessage";
          print('❌ Payment Failed: $statusMessage');
          _showErrorSnackBar('Payment failed: $statusMessage');
        }
      } else {
        paymentStatus = "6";
        msg1 = "Transaction failed: $description";
        print('❌ Payment Failed with status code: $statusCode');
        _showErrorSnackBar('Payment failed: $description');
      }

      await updatePaymentStatus(transactionId, amount, paymentStatus, msg1);

      await _updatePaymentStatus1(
        paymentStatus,
        "Transaction ID: $transactionId\nOrder ID: $orderId\nCustomer ID: $customerId\nTransaction Date: $txnDateTime",
        msg1,
      );
    } catch (e) {
      print('❌ Error handling payment response: $e');
      _showErrorSnackBar('Error processing payment response: $e');
    }
  }

  Future<void> updatePaymentStatus(
    String transactionId,
    String amount,
    String paymentStatus,
    String msg,
  ) async {
    try {
      print('🚀 Initiating updatePaymentdetailsToRecharge.php API call...');

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final params = {
        'transaction_amount': amount,
        'paymentstatus': paymentStatus,
        'order_id': transactionId,
        'msg': msg,
        'timestamp': timestamp,
      };

      // Step 1: POST to updatePaymentdetailsToRecharge.php
      final postResponse = await postRechargeApi(
        'updatePaymentdetailsToRecharge.php?timestamp=$timestamp',
        params,
      );

      print('🎯 ===== UPDATE PAYMENT STATUS POST RESPONSE START =====');
      print('📥 Raw POST Response: $postResponse');
      print('📏 Response Length: ${postResponse.length}');
      print('🔍 Response Type: ${postResponse.runtimeType}');
      print('📋 Response is Empty: ${postResponse.isEmpty}');
      print('🎯 ===== UPDATE PAYMENT STATUS POST RESPONSE END =====');

      if (postResponse.isNotEmpty) {
        final postJsonResponse = await _parseJsonInIsolate(postResponse);
        print('✅ Parsed POST JSON Response: $postJsonResponse');
        print('📊 POST Response Keys: ${postJsonResponse.keys.join(", ")}');

        if (postJsonResponse['status'] == 'success' ||
            postJsonResponse['urltoLoad'] != null) {
          print('✅ POST Payment status updated successfully');

          // Step 2: Check for urltoLoad and handle different scenarios
          String? urltoLoad = postJsonResponse['urltoLoad']?.toString();
          if (urltoLoad != null && urltoLoad.isNotEmpty) {
            try {
              final uri = Uri.parse(urltoLoad);
              final message = uri.queryParameters['message'];
              print('🔍 Extracted message from urltoLoad: $message');

              // Handle Recharge Amount mismatch specifically
              if (message == 'Recharge Amount mismatch') {
                print('❌ Recharge Amount mismatch detected in urltoLoad');
                _showRechargeFailureDialog(
                  'Recharge Failed',
                  'Your payment was successful, but the recharge could not be completed due to an amount mismatch. Please contact customer support for assistance.',
                  transactionId,
                  amount,
                );
                return; // Skip GET request for amount mismatch
              }

              // Handle other error messages from urltoLoad
              if (message != null && message.toLowerCase().contains('failed')) {
                print('❌ Recharge failed message detected: $message');
                _showRechargeFailureDialog(
                  'Recharge Failed',
                  message,
                  transactionId,
                  amount,
                );
                return; // Skip GET request for failed recharges
              }

              // Proceed with GET request for successful cases or other scenarios
              print('🚀 Initiating GET request to urltoLoad: $urltoLoad');
              final getResponse = await getRechargeApi(urltoLoad);

              print('🎯 ===== URLTOLOAD GET RESPONSE START =====');
              print('📥 Raw GET Response: $getResponse');
              print('📏 Response Length: ${getResponse.length}');
              print('🔍 Response Type: ${getResponse.runtimeType}');
              print('📋 Response is Empty: ${getResponse.isEmpty}');
              print('🎯 ===== URLTOLOAD GET RESPONSE END =====');

              if (getResponse.isNotEmpty) {
                final getJsonResponse = await _parseJsonInIsolate(getResponse);
                print('✅ Parsed GET JSON Response: $getJsonResponse');
                print(
                  '📊 GET Response Keys: ${getJsonResponse.keys.join(", ")}',
                );

                // Check if GET response contains another urltoLoad (nested error)
                String? nestedUrlToLoad =
                    getJsonResponse['urltoLoad']?.toString();
                if (nestedUrlToLoad != null && nestedUrlToLoad.isNotEmpty) {
                  try {
                    final nestedUri = Uri.parse(nestedUrlToLoad);
                    final nestedMessage = nestedUri.queryParameters['message'];
                    print(
                      '🔍 Nested message from GET response urltoLoad: $nestedMessage',
                    );

                    if (nestedMessage == 'Recharge Amount mismatch') {
                      print('❌ Nested Recharge Amount mismatch detected');
                      _showRechargeFailureDialog(
                        'Recharge Failed',
                        'Your payment was successful, but the recharge could not be completed due to an amount mismatch. Please contact customer support for assistance.',
                        transactionId,
                        amount,
                      );
                      return;
                    } else if (nestedMessage != null) {
                      print('❌ Other nested error message: $nestedMessage');
                      _showRechargeFailureDialog(
                        'Recharge Failed',
                        'Your payment was successful, but the recharge could not be completed: $nestedMessage',
                        transactionId,
                        amount,
                      );
                      return;
                    }
                  } catch (nestedParseError) {
                    print(
                      '❌ Error parsing nested urltoLoad: $nestedParseError',
                    );
                  }
                }

                // Handle structured recharge response with status codes
                if (getJsonResponse.containsKey('status') &&
                    getJsonResponse.containsKey('account')) {
                  final rechargeStatus = getJsonResponse['status'];
                  final accountNumber =
                      getJsonResponse['account']?.toString() ?? '';
                  final rechargeAmount =
                      getJsonResponse['amount']?.toString() ?? '';
                  final rpid = getJsonResponse['rpid']?.toString() ?? '';
                  final message = getJsonResponse['msg']?.toString() ?? '';
                  final balance = getJsonResponse['bal']?.toString() ?? '';
                  final agentId = getJsonResponse['agentid']?.toString();
                  final opId = getJsonResponse['opid']?.toString();
                  final isRefundStatusShow =
                      getJsonResponse['isRefundStatusShow'] as bool?;
                  final errorCode = getJsonResponse['errorcode']?.toString();

                  print('🔍 Recharge Status Code: $rechargeStatus');
                  print('🔍 Account: $accountNumber');
                  print('🔍 Amount: $rechargeAmount');
                  print('🔍 Message: $message');
                  print('🔍 Error Code: $errorCode');
                  print('🔍 Agent ID: $agentId');
                  print('🔍 OP ID: $opId');
                  print('🔍 Refund Status Show: $isRefundStatusShow');

                  if (rechargeStatus == 2) {
                    // Status 2 = Recharge Successful
                    print('✅ Recharge completed successfully (Status: 2)');
                    await _storeRechargeSuccess(
                      accountNumber,
                      rechargeAmount,
                      rpid,
                      message,
                      balance,
                      agentId,
                      opId,
                      isRefundStatusShow,
                      errorCode,
                    );
                    _showRechargeSuccessDialog(
                      accountNumber,
                      rechargeAmount,
                      rpid,
                      message,
                      balance,
                      transactionId,
                    );

                    // Call updateRechargeStatus.php for successful recharge
                    print('🚀 Initiating updateRechargeStatus.php API call...');
                    final rechargeStatusParams = {
                      'timestamp':
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      'status': '1', // Success status for updateRechargeStatus
                      'id': transactionId,
                      'rp_id': rpid,
                      'agent_id': agentId ?? '',
                    };

                    try {
                      final rechargeStatusResponse = await postRechargeApi(
                        'https://mysaving.in/IntegraAccount/api/updateRechargeStatus.php',
                        rechargeStatusParams,
                      );

                      print(
                        '🎯 ===== UPDATE RECHARGE STATUS RESPONSE START =====',
                      );
                      print(
                        '📥 Raw Response (updateRechargeStatus.php): $rechargeStatusResponse',
                      );
                      print(
                        '📏 Response Length: ${rechargeStatusResponse.length}',
                      );
                      print(
                        '🔍 Response Type: ${rechargeStatusResponse.runtimeType}',
                      );
                      print(
                        '📋 Response is Empty: ${rechargeStatusResponse.isEmpty}',
                      );
                      print(
                        '🎯 ===== UPDATE RECHARGE STATUS RESPONSE END =====',
                      );

                      if (rechargeStatusResponse.isNotEmpty) {
                        final rechargeStatusJson = await _parseJsonInIsolate(
                          rechargeStatusResponse,
                        );
                        print(
                          '✅ Parsed JSON Response (updateRechargeStatus.php): $rechargeStatusJson',
                        );
                        print(
                          '📊 Response Keys: ${rechargeStatusJson.keys.join(", ")}',
                        );

                        if (rechargeStatusJson['status'] == 1 &&
                            rechargeStatusJson['message'] == 'Success') {
                          print(
                            '✅ updateRechargeStatus.php successful, proceeding to updateGenStatus.php',
                          );

                          // Call updateGenStatus.php
                          print(
                            '🚀 Initiating updateGenStatus.php API call...',
                          );
                          final genStatusParams = {
                            'timestamp':
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            'id': transactionId,
                          };

                          try {
                            final genStatusResponse = await postRechargeApi(
                              'https://mysaving.in/IntegraAccount/api/updateGenStatus.php',
                              genStatusParams,
                            );

                            print(
                              '🎯 ===== UPDATE GEN STATUS RESPONSE START =====',
                            );
                            print(
                              '📥 Raw Response (updateGenStatus.php): $genStatusResponse',
                            );
                            print(
                              '📏 Response Length: ${genStatusResponse.length}',
                            );
                            print(
                              '🔍 Response Type: ${genStatusResponse.runtimeType}',
                            );
                            print(
                              '📋 Response is Empty: ${genStatusResponse.isEmpty}',
                            );
                            print(
                              '🎯 ===== UPDATE GEN STATUS RESPONSE END =====',
                            );

                            if (genStatusResponse.isNotEmpty) {
                              final genStatusJson = await _parseJsonInIsolate(
                                genStatusResponse,
                              );
                              print(
                                '✅ Parsed JSON Response (updateGenStatus.php): $genStatusJson',
                              );
                              print(
                                '📊 Response Keys: ${genStatusJson.keys.join(", ")}',
                              );

                              if (genStatusJson['status'] == 'success') {
                                print(
                                  '✅ updateGenStatus.php completed successfully',
                                );
                                _showSuccessSnackBar(
                                  'Recharge and status updates completed successfully',
                                );
                              } else {
                                print(
                                  '❌ updateGenStatus.php failed: ${genStatusJson['message'] ?? 'Unknown error'}',
                                );
                                _showErrorSnackBar(
                                  'Failed to update general status: ${genStatusJson['message'] ?? 'Unknown error'}',
                                );
                              }
                            } else {
                              print(
                                '❌ Empty response from updateGenStatus.php',
                              );
                              _showErrorSnackBar(
                                'Empty response from general status update API',
                              );
                            }
                          } catch (genStatusError) {
                            print(
                              '❌ Error calling updateGenStatus.php: $genStatusError',
                            );
                            _showErrorSnackBar(
                              'Failed to update general status: $genStatusError',
                            );
                          }
                        } else {
                          print(
                            '❌ updateRechargeStatus.php failed: ${rechargeStatusJson['message'] ?? 'Unknown error'}',
                          );
                          _showErrorSnackBar(
                            'Failed to update recharge status: ${rechargeStatusJson['message'] ?? 'Unknown error'}',
                          );
                        }
                      } else {
                        print('❌ Empty response from updateRechargeStatus.php');
                        _showErrorSnackBar(
                          'Empty response from recharge status update API',
                        );
                      }
                    } catch (rechargeStatusError) {
                      print(
                        '❌ Error calling updateRechargeStatus.php: $rechargeStatusError',
                      );
                      _showErrorSnackBar(
                        'Failed to update recharge status: $rechargeStatusError',
                      );
                    }
                  } else if (rechargeStatus == 1) {
                    // Status 1 = Recharge Pending
                    print('⏳ Recharge is pending (Status: 1)');
                    _showRechargePendingDialog(
                      accountNumber,
                      rechargeAmount,
                      rpid,
                      message,
                      transactionId,
                    );

                    // Call updateRechargeStatus.php for pending recharge
                    print(
                      '🚀 Initiating updateRechargeStatus.php API call for pending...',
                    );
                    final rechargeStatusParams = {
                      'timestamp':
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      'status': '2', // Pending status for updateRechargeStatus
                      'id': transactionId,
                      'rp_id': rpid,
                      'agent_id': agentId ?? '',
                    };

                    try {
                      final rechargeStatusResponse = await postRechargeApi(
                        'https://mysaving.in/IntegraAccount/api/updateRechargeStatus.php',
                        rechargeStatusParams,
                      );

                      print(
                        '🎯 ===== UPDATE RECHARGE STATUS RESPONSE START =====',
                      );
                      print(
                        '📥 Raw Response (updateRechargeStatus.php): $rechargeStatusResponse',
                      );
                      print(
                        '📏 Response Length: ${rechargeStatusResponse.length}',
                      );
                      print(
                        '🔍 Response Type: ${rechargeStatusResponse.runtimeType}',
                      );
                      print(
                        '📋 Response is Empty: ${rechargeStatusResponse.isEmpty}',
                      );
                      print(
                        '🎯 ===== UPDATE RECHARGE STATUS RESPONSE END =====',
                      );

                      if (rechargeStatusResponse.isNotEmpty) {
                        final rechargeStatusJson = await _parseJsonInIsolate(
                          rechargeStatusResponse,
                        );
                        print(
                          '✅ Parsed JSON Response (updateRechargeStatus.php): $rechargeStatusJson',
                        );
                        print(
                          '📊 Response Keys: ${rechargeStatusJson.keys.join(", ")}',
                        );

                        if (rechargeStatusJson['status'] == 1 &&
                            rechargeStatusJson['message'] == 'Success') {
                          print(
                            '✅ updateRechargeStatus.php successful for pending status',
                          );
                        } else {
                          print(
                            '❌ updateRechargeStatus.php failed for pending: ${rechargeStatusJson['message'] ?? 'Unknown error'}',
                          );
                          _showErrorSnackBar(
                            'Failed to update pending recharge status: ${rechargeStatusJson['message'] ?? 'Unknown error'}',
                          );
                        }
                      } else {
                        print(
                          '❌ Empty response from updateRechargeStatus.php for pending',
                        );
                        _showErrorSnackBar(
                          'Empty response from recharge status update API for pending',
                        );
                      }
                    } catch (rechargeStatusError) {
                      print(
                        '❌ Error calling updateRechargeStatus.php for pending: $rechargeStatusError',
                      );
                      _showErrorSnackBar(
                        'Failed to update pending recharge status: $rechargeStatusError',
                      );
                    }
                  } else {
                    // Other status = Recharge Failed
                    print('❌ Recharge failed (Status: $rechargeStatus)');
                    _showRechargeFailureDialog(
                      'Recharge Failed',
                      message.isNotEmpty
                          ? message
                          : 'Recharge could not be completed. Please try again.',
                      transactionId,
                      rechargeAmount.isNotEmpty ? rechargeAmount : amount,
                    );

                    // Call updateRechargeStatus.php for failed recharge
                    print(
                      '🚀 Initiating updateRechargeStatus.php API call for failed...',
                    );
                    final rechargeStatusParams = {
                      'timestamp':
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      'status': '0', // Failed status for updateRechargeStatus
                      'id': transactionId,
                      'rp_id': rpid,
                      'agent_id': agentId ?? '',
                    };

                    try {
                      final rechargeStatusResponse = await postRechargeApi(
                        'https://mysaving.in/IntegraAccount/api/updateRechargeStatus.php',
                        rechargeStatusParams,
                      );

                      print(
                        '🎯 ===== UPDATE RECHARGE STATUS RESPONSE START =====',
                      );
                      print(
                        '📥 Raw Response (updateRechargeStatus.php): $rechargeStatusResponse',
                      );
                      print(
                        '📏 Response Length: ${rechargeStatusResponse.length}',
                      );
                      print(
                        '🔍 Response Type: ${rechargeStatusResponse.runtimeType}',
                      );
                      print(
                        '📋 Response is Empty: ${rechargeStatusResponse.isEmpty}',
                      );
                      print(
                        '🎯 ===== UPDATE RECHARGE STATUS RESPONSE END =====',
                      );

                      if (rechargeStatusResponse.isNotEmpty) {
                        final rechargeStatusJson = await _parseJsonInIsolate(
                          rechargeStatusResponse,
                        );
                        print(
                          '✅ Parsed JSON Response (updateRechargeStatus.php): $rechargeStatusJson',
                        );
                        print(
                          '📊 Response Keys: ${rechargeStatusJson.keys.join(", ")}',
                        );

                        if (rechargeStatusJson['status'] == 1 &&
                            rechargeStatusJson['message'] == 'Success') {
                          print(
                            '✅ updateRechargeStatus.php successful for failed status',
                          );
                        } else {
                          print(
                            '❌ updateRechargeStatus.php failed for failed: ${rechargeStatusJson['message'] ?? 'Unknown error'}',
                          );
                          _showErrorSnackBar(
                            'Failed to update failed recharge status: ${rechargeStatusJson['message'] ?? 'Unknown error'}',
                          );
                        }
                      } else {
                        print(
                          '❌ Empty response from updateRechargeStatus.php for failed',
                        );
                        _showErrorSnackBar(
                          'Empty response from recharge status update API for failed',
                        );
                      }
                    } catch (rechargeStatusError) {
                      print(
                        '❌ Error calling updateRechargeStatus.php for failed: $rechargeStatusError',
                      );
                      _showErrorSnackBar(
                        'Failed to update failed recharge status: $rechargeStatusError',
                      );
                    }
                  }
                  return;
                }

                // Fallback: Check legacy response format
                if (getJsonResponse['status'] == 'failed' ||
                    getJsonResponse['status'] == '0' ||
                    getJsonResponse['message']
                            ?.toString()
                            .toLowerCase()
                            .contains('failed') ==
                        true) {
                  print(
                    '❌ GET request indicates recharge failed: ${getJsonResponse['message']}',
                  );
                  _showRechargeFailureDialog(
                    'Recharge Failed',
                    'Your payment was successful, but the recharge could not be completed: ${getJsonResponse['message']?.toString() ?? 'Unknown error occurred'}',
                    transactionId,
                    amount,
                  );
                } else if (getJsonResponse['status'] == 'success' ||
                    getJsonResponse['status'] == '1') {
                  print('✅ GET request to urltoLoad successful');
                  _showSuccessSnackBar('Recharge completed successfully');
                } else {
                  print(
                    '⚠️ GET request returned unknown status: ${getJsonResponse['status']}',
                  );
                  _showErrorSnackBar(
                    'Recharge status unclear: ${getJsonResponse['message'] ?? 'Unknown response'}',
                  );
                }
              } else {
                print('❌ Empty GET response from urltoLoad');
                _showErrorSnackBar(
                  'Empty response from recharge verification API',
                );
              }
            } catch (getError) {
              print('❌ Error calling urltoLoad: $getError');
              _showErrorSnackBar('Failed to verify recharge status: $getError');
            }
          } else {
            print('✅ No urltoLoad provided, POST success assumed');
            _showSuccessSnackBar('Payment status updated successfully');
          }
        } else {
          print(
            '❌ Failed to update payment status (POST): ${postJsonResponse['message'] ?? 'Unknown error'}',
          );
          _showErrorSnackBar(
            'Failed to update payment status: ${postJsonResponse['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        print('❌ Empty POST response received');
        _showErrorSnackBar('Empty response from payment status update API');
      }
    } catch (e) {
      print('❌ Error calling updatePaymentdetailsToRecharge.php: $e');
      print('🔍 Error Details: ${e.toString()}');
      _showErrorSnackBar('Failed to update payment status: $e');
    }
  }

  Future<void> _storeRechargeSuccess(
    String accountNumber,
    String rechargeAmount,
    String rpid,
    String message,
    String balance,
    String? agentId, // Nullable to handle cases where agentid is not provided
    String? opId, // Nullable to handle cases where opid is not provided
    bool?
    isRefundStatusShow, // Nullable to handle cases where isRefundStatusShow is not provided
    String?
    errorCode, // Nullable to handle cases where errorcode is not provided
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('recharge_account', accountNumber);
      await prefs.setString('recharge_amount', rechargeAmount);
      await prefs.setString('recharge_rpid', rpid);
      await prefs.setString('recharge_message', message);
      await prefs.setString('recharge_balance', balance);
      await prefs.setString(
        'recharge_timestamp',
        DateTime.now().toIso8601String(),
      );

      // Store additional fields
      if (agentId != null) {
        await prefs.setString('recharge_agentid', agentId);
      } else {
        await prefs.remove('recharge_agentid'); // Clear if not provided
      }

      if (opId != null) {
        await prefs.setString('recharge_opid', opId);
      } else {
        await prefs.remove('recharge_opid'); // Clear if not provided
      }

      if (isRefundStatusShow != null) {
        await prefs.setBool('recharge_isRefundStatusShow', isRefundStatusShow);
      } else {
        await prefs.remove(
          'recharge_isRefundStatusShow',
        ); // Clear if not provided
      }

      if (errorCode != null) {
        await prefs.setString('recharge_errorcode', errorCode);
      } else {
        await prefs.remove('recharge_errorcode'); // Clear if not provided
      }

      print('💾 Recharge success details stored in SharedPreferences');
      print('📋 Stored Fields:');
      print('  - Account: $accountNumber');
      print('  - Amount: $rechargeAmount');
      print('  - RPID: $rpid');
      print('  - Message: $message');
      print('  - Balance: $balance');
      print('  - Agent ID: ${agentId ?? "Not provided"}');
      print('  - OP ID: ${opId ?? "Not provided"}');
      print('  - Refund Status Show: ${isRefundStatusShow ?? "Not provided"}');
      print('  - Error Code: ${errorCode ?? "Not provided"}');
    } catch (e) {
      print('❌ Error storing recharge success details: $e');
    }
  }

  void _showRechargeFailureDialog(
    String title,
    String message,
    String transactionId,
    String amount,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFFEF2F2)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFEF4444).withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A5568),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF8F9FA), Color(0xFFE2E8F0)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildSuccessDetailRow(
                          'Mobile Number',
                          widget.mobileNumber,
                        ),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Transaction ID', transactionId),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Amount', '₹$amount'),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Status', 'Failed'),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF6B7280),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Contact Support',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4285F4), Color(0xFF1a73e8)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4285F4).withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _storePaymentSuccess(
    String transactionId,
    String orderId,
    String customerId,
    String txnDateTime,
    String amount,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_transaction_id', transactionId);
      await prefs.setString('last_order_id', orderId);
      await prefs.setString('last_customer_id', customerId);
      await prefs.setString('last_transaction_date', txnDateTime);
      await prefs.setString('last_paid_amount', amount);
      print('💾 Payment success details stored in SharedPreferences');
    } catch (e) {
      print('❌ Error storing payment success details: $e');
    }
  }

  Future<void> _updatePaymentStatus1(
    String paymentStatus,
    String transactionDetails,
    String msg,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('final_payment_status', paymentStatus);
      await prefs.setString('transaction_details', transactionDetails);
      await prefs.setString('final_payment_message', msg);
      print('💾 Final payment status updated: $paymentStatus');
    } catch (e) {
      print('❌ Error updating payment status: $e');
    }
  }

  void _showRechargeSuccessDialog(
    String accountNumber,
    String rechargeAmount,
    String rpid,
    String message,
    String balance,
    String transactionId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF0FDF4)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Recharge Successful!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A5568),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF8F9FA), Color(0xFFE2E8F0)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildSuccessDetailRow('Mobile Number', accountNumber),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow(
                          'Recharge Amount',
                          '₹$rechargeAmount',
                        ),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Transaction ID', transactionId),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Recharge ID', rpid),
                        if (balance.isNotEmpty) ...[
                          Divider(height: 20, color: Color(0xFFCBD5E0)),
                          _buildSuccessDetailRow(
                            'Account Balance',
                            '₹$balance',
                          ),
                        ],
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Status', 'Successful'),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF10B981),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'View Receipt',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF10B981).withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Done',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showRechargePendingDialog(
    String accountNumber,
    String rechargeAmount,
    String rpid,
    String message,
    String transactionId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFFEF3C7)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFF59E0B).withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(Icons.pending, color: Colors.white, size: 40),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Recharge Pending',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    message.isNotEmpty
                        ? message
                        : 'Your recharge is being processed. You will receive a confirmation shortly.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A5568),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF8F9FA), Color(0xFFE2E8F0)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildSuccessDetailRow('Mobile Number', accountNumber),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow(
                          'Recharge Amount',
                          '₹$rechargeAmount',
                        ),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Transaction ID', transactionId),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Recharge ID', rpid),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Status', 'Pending'),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF6B7280),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Check Status',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFF59E0B).withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildPaymentProcessingDialog(
    Map<String, dynamic> planData,
    String paymentType,
    double totalAmount,
  ) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Color(0xFFFAFBFC)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4285F4), Color(0xFF1a73e8)],
                ),
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(Icons.payment, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Processing Payment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait while we process your payment of ₹${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFBFDBFE)),
              ),
              child: Text(
                _getPaymentTypeDisplayName(paymentType),
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1E40AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF1A202C),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getPaymentTypeDisplayName(String paymentType) {
    switch (paymentType) {
      case 'upi':
        return 'UPI Payment';
      case 'net_banking':
        return 'NET Banking';
      case 'debit_card':
        return 'Debit Card';
      case 'credit_card':
        return 'Credit Card';
      default:
        return 'Unknown';
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'ALL';
      case 'unlimited':
        return 'UNLIMITED';
      case 'data':
        return 'DATA';
      case 'talktime':
        return 'TALKTIME';
      case 'other':
        return 'OTHER';
      default:
        return category.toUpperCase();
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'all':
        return Icons.all_inclusive;
      case 'unlimited':
        return Icons.language;
      case 'data':
        return Icons.data_usage;
      case 'talktime':
        return Icons.account_balance_wallet;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A365D), Color(0xFF2D3748), Colors.white],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _heroAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _heroAnimation.value) * 50),
                    child: Opacity(
                      opacity: _heroAnimation.value.clamp(0.0, 1.0),
                      child: Container(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Choose Plan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        color: Colors.green,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        widget.operatorData['asset'] as String,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors:
                                                    widget.operatorData['gradient']
                                                        as List<Color>,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Center(
                                              child: Text(
                                                (widget.operatorData['name']
                                                    as String)[0],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.mobileNumber,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${widget.operatorData['name']} • ${widget.circle}',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 6),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'ACTIVE',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.orange,
                                          Colors.deepOrange,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${convertedPlans.length} PLANS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _listAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _listAnimation.value) * 30),
                      child: Opacity(
                        opacity: _listAnimation.value.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: Offset(0, -10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 4,
                                margin: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFF8F9FA), Colors.white],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search plans by amount, data or benefits...',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF718096),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    prefixIcon: Container(
                                      padding: EdgeInsets.all(12),
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF4285F4),
                                              Color(0xFF34A853),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
                                            ? IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                color: Color(0xFF718096),
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {
                                                  searchQuery = '';
                                                });
                                              },
                                            )
                                            : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFF8F9FA), Colors.white],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF4285F4),
                                        Color(0xFF1a73e8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFF4285F4,
                                        ).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Color(0xFF718096),
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  unselectedLabelStyle: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  isScrollable: availableCategories.length > 4,
                                  tabs:
                                      availableCategories.map((category) {
                                        return Tab(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _getCategoryIcon(category),
                                                size: 14,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                _getCategoryDisplayName(
                                                  category,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                              SizedBox(height: 8),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children:
                                      availableCategories.map((category) {
                                        return _buildGooglePayPlansList(
                                          category,
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGooglePayPlansList(String category) {
    final plans = getFilteredPlans(category);
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF8F9FA), Color(0xFFE2E8F0)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Color(0xFF718096),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No plans found',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF1A202C),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search terms or filters',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final isSelected = selectedPlanId == plan['id'];

        return AnimatedContainer(
          duration: Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
          margin: EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () => _selectPlan(plan['id'] as String, plan),
            child: Container(
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            Colors.white,
                            (plan['color'] as Color).withOpacity(0.03),
                            (plan['color'] as Color).withOpacity(0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : LinearGradient(
                          colors: [Colors.white, Color(0xFFFAFBFC)],
                        ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? (plan['color'] as Color) : Color(0xFFE2E8F0),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isSelected
                            ? (plan['color'] as Color).withOpacity(0.25)
                            : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 20 : 10,
                    offset: Offset(0, isSelected ? 8 : 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (plan['popular'] == true)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'POPULAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    plan['color'] as Color,
                                    (plan['color'] as Color).withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: (plan['color'] as Color).withOpacity(
                                      0.4,
                                    ),
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: -10,
                                    right: -10,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '₹${plan['amount']}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        if ((plan['data'] as String?)
                                                ?.isNotEmpty ??
                                            false)
                                          Text(
                                            plan['data'] as String,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                (plan['color'] as Color)
                                                    .withOpacity(0.1),
                                                (plan['color'] as Color)
                                                    .withOpacity(0.05),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: (plan['color'] as Color)
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            plan['validity'] as String,
                                            style: TextStyle(
                                              color: plan['color'] as Color,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      if (plan['savings'] != null) ...[
                                        SizedBox(width: 6),
                                        Flexible(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.green,
                                                  Colors.green.shade600,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green
                                                      .withOpacity(0.3),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              plan['savings'] as String,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    plan['description'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1A202C),
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Column(
                                    children:
                                        (plan['benefits'] as List<dynamic>)
                                            .take(2)
                                            .map<Widget>((benefit) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 3,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 4,
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            plan['color']
                                                                as Color,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        benefit as String,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Color(
                                                            0xFF4A5568,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          height: 1.3,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            })
                                            .toList(),
                                  ),
                                  if ((plan['benefits'] as List<dynamic>)
                                          .length >
                                      2)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        '+${(plan['benefits'] as List<dynamic>).length - 2} more benefits',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: plan['color'] as Color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                gradient:
                                    isSelected
                                        ? LinearGradient(
                                          colors: [
                                            plan['color'] as Color,
                                            (plan['color'] as Color)
                                                .withOpacity(0.8),
                                          ],
                                        )
                                        : LinearGradient(
                                          colors: [
                                            Color(0xFFF8F9FA),
                                            Color(0xFFE2E8F0),
                                          ],
                                        ),
                                shape: BoxShape.circle,
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: (plan['color'] as Color)
                                                .withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: Offset(0, 6),
                                          ),
                                        ]
                                        : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 8,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                              ),
                              child: AnimatedBuilder(
                                animation: _fabController,
                                builder: (context, child) {
                                  final scale =
                                      isSelected
                                          ? _fabScaleAnimation.value.clamp(
                                            0.5,
                                            2.0,
                                          )
                                          : 1.0;
                                  final opacity =
                                      isSelected
                                          ? _fabAnimation.value.clamp(0.0, 1.0)
                                          : 1.0;
                                  return Transform.scale(
                                    scale: scale,
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Center(
                                        child:
                                            isSelected
                                                ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                  size: 20,
                                                )
                                                : Icon(
                                                  Icons.add_circle_outline,
                                                  color: Color(0xFF718096),
                                                  size: 20,
                                                ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if ((plan['data'] as String?)?.isNotEmpty ??
                                  false)
                                _buildGooglePayFeatureChip(
                                  Icons.signal_cellular_4_bar,
                                  'DATA',
                                  plan['color'] as Color,
                                ),
                              if ((plan['calls'] as String?)
                                      ?.toLowerCase()
                                      .contains('unlimited') ??
                                  false) ...[
                                SizedBox(width: 6),
                                _buildGooglePayFeatureChip(
                                  Icons.call,
                                  'CALLS',
                                  plan['color'] as Color,
                                ),
                              ],
                              if ((plan['sms'] as String?)
                                      ?.toLowerCase()
                                      .contains('unlimited') ??
                                  false) ...[
                                SizedBox(width: 6),
                                _buildGooglePayFeatureChip(
                                  Icons.sms,
                                  'SMS',
                                  plan['color'] as Color,
                                ),
                              ],
                              if ((plan['subscriptions'] as List<dynamic>?)
                                      ?.isNotEmpty ??
                                  false) ...[
                                SizedBox(width: 6),
                                _buildGooglePayFeatureChip(
                                  Icons.play_circle_filled,
                                  'OTT',
                                  plan['color'] as Color,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              (plan['color'] as Color).withOpacity(0.05),
                              Colors.transparent,
                              (plan['color'] as Color).withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGooglePayFeatureChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialogWithDetails(
    Map<String, dynamic> planData,
    String paymentType,
    double totalAmount,
    String transactionId,
    String orderId,
    String customerId,
    String txnDateTime,
    String statusMessage,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF0FDF4)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Payment Successful! 🎉',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    statusMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A5568),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF8F9FA), Color(0xFFE2E8F0)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildSuccessDetailRow(
                          'Mobile Number',
                          widget.mobileNumber,
                        ),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow(
                          'Amount Paid',
                          '₹${totalAmount.toStringAsFixed(2)}',
                        ),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow(
                          'Payment Method',
                          _getPaymentTypeDisplayName(paymentType),
                        ),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Transaction ID', transactionId),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Order ID', orderId),
                        Divider(height: 20, color: Color(0xFFCBD5E0)),
                        _buildSuccessDetailRow('Transaction Date', txnDateTime),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF10B981),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'View Receipt',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF10B981).withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Done',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
