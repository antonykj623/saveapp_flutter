import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/app/Modules/login/login_page.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/Rechargeapiclass.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/Request_class.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/payment_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    with TickerProviderStateMixin {
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

  static const List<String> arroperators = ["Airtel", "Vi", "Jio", "BSNL"];
  static const List<String> arroperator_code = ["AT", "VI", "RJ", "CG"];
  static const List<String> arrspkey = ["3", "37", "116", "4"];

  @override
  void initState() {
    super.initState();
    void _debugTestPaymentCredentials() {
      _testGetPaymentCredentials();
    }

    _immediateTestPaymentCredentials();

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
    _tabController.dispose();
    _heroController.dispose();
    _listController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
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

      // STEP 1: Call PostTransactionata.php
      print('🚀 STEP 1: Initiating PostTransactionata.php API call...');
      print('📤 Request Data: ${rechargeRequest.toJson()}');

      final response = await apiHelper.postApiResponse(
        'PostTransactionata.php',
        rechargeRequest.toJson(),
      );

      print('📥 Raw API Response (PostTransactionata.php): $response');

      // Parse the response
      final jsonResponse = await _parseJsonInIsolate(response);
      print('✅ Parsed JSON Response (PostTransactionata.php): $jsonResponse');

      if (jsonResponse['status'] == 'success' ||
          jsonResponse['status'] == '1' ||
          jsonResponse['status'] == '2') {
        // Save the API response to SharedPreferences
        await prefs.setString('payment_status', jsonResponse['status']);
        await prefs.setString('payment_message', jsonResponse['message'] ?? '');
        if (jsonResponse['id'] != null) {
          await prefs.setInt('payment_id', jsonResponse['id']);
        }

        print('💾 Saved payment data to SharedPreferences');

        // STEP 2: Call getPaymentCredentials.php API - This is where you want to see the response
        print('🚀 STEP 2: Initiating getPaymentCredentials.php API call...');
        print(
          '🌐 Full API URL: https://mysaving.in/IntegraAccount/api/getPaymentCredentials.php',
        );

        try {
          final credentialsResponse = await apiHelper.getApiResponse(
            'getPaymentCredentials.php',
          );

          // ✅ THIS IS THE MAIN DEBUG OUTPUT YOU WANT TO SEE
          print('🎯 ===== PAYMENT CREDENTIALS RESPONSE START =====');
          print('📥 Raw Response: $credentialsResponse');
          print('📏 Response Length: ${credentialsResponse.length}');
          print('🎯 ===== PAYMENT CREDENTIALS RESPONSE END =====');

          if (credentialsResponse.isEmpty) {
            print('❌ Error: getPaymentCredentials.php returned empty response');
            _showErrorSnackBar(
              'Failed to fetch payment credentials: Empty response',
            );
          } else {
            try {
              final credentialsJson = await _parseJsonInIsolate(
                credentialsResponse,
              );

              // ✅ PARSED JSON DEBUG OUTPUT
              print('🎯 ===== PARSED PAYMENT CREDENTIALS START =====');
              print('📊 Parsed JSON: $credentialsJson');

              // Extract specific fields if they exist
              if (credentialsJson.containsKey('merchantcode')) {
                print('🏪 Merchant Code: ${credentialsJson['merchantcode']}');
              }
              if (credentialsJson.containsKey('saltkey')) {
                print('🔐 Salt Key: ${credentialsJson['saltkey']}');
              }
              if (credentialsJson.containsKey('transactionid')) {
                print('💳 Transaction ID: ${credentialsJson['transactionid']}');
              }
              if (credentialsJson.containsKey('customerid')) {
                print('👤 Customer ID: ${credentialsJson['customerid']}');
              }
              print('🎯 ===== PARSED PAYMENT CREDENTIALS END =====');

              // Save credentials to SharedPreferences for later use
              await prefs.setString('payment_credentials', credentialsResponse);
              print('💾 Saved payment credentials to SharedPreferences');
            } catch (parseError) {
              print(
                '❌ Error parsing getPaymentCredentials response: $parseError',
              );
              print(
                '📄 Raw response that failed to parse: $credentialsResponse',
              );
              _showErrorSnackBar(
                'Failed to parse payment credentials: $parseError',
              );
            }
          }
        } catch (apiError) {
          print('❌ Error fetching payment credentials: $apiError');
          print('🔍 API Error Details: ${apiError.toString()}');
          _showErrorSnackBar('Failed to fetch payment credentials: $apiError');
        }

        // Close loading dialog and show success
        Navigator.pop(context);
        _showPaymentSuccessDialog(planData, paymentType, totalAmount);
      } else {
        Navigator.pop(context);
        _showErrorSnackBar(
          'Payment failed: ${jsonResponse['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Payment error: $e');
      print('❌ Error processing payment: $e');
    }
  }

  Future<void> _testGetPaymentCredentials() async {
    print('🧪 TESTING: getPaymentCredentials.php API call...');

    try {
      final apiHelper = ApiHelper();
      final response = await apiHelper.getApiResponse(
        'getPaymentCredentials.php',
      );

      print('🎯 ===== TEST RESPONSE START =====');
      print('📥 Raw Response: $response');
      print('📏 Response Length: ${response.length}');

      if (response.isNotEmpty) {
        try {
          final jsonResponse = await _parseJsonInIsolate(response);
          print('📊 Parsed JSON: $jsonResponse');
        } catch (e) {
          print('❌ Failed to parse JSON: $e');
        }
      }
      print('🎯 ===== TEST RESPONSE END =====');
    } catch (e) {
      print('❌ Test API call failed: $e');
    }
  }

  Future<void> _immediateTestPaymentCredentials() async {
    print('🧪 IMMEDIATE TEST: Calling getPaymentCredentials.php directly...');
    print(
      '🌐 Testing URL: https://mysaving.in/IntegraAccount/api/getPaymentCredentials.php',
    );

    try {
      final apiHelper = ApiHelper();

      // Add timestamp to track the request
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      print('⏰ Request started at: $timestamp');

      final response = await apiHelper.getApiResponse(
        'getPaymentCredentials.php',
      );

      final endTime = DateTime.now().millisecondsSinceEpoch;
      print('⏰ Request completed at: $endTime (took ${endTime - timestamp}ms)');

      print('🎯 ===== IMMEDIATE TEST RESPONSE START =====');
      print('📥 Raw Response: $response');
      print('📏 Response Length: ${response.length}');
      print('🔍 Response Type: ${response.runtimeType}');
      print('📋 Response is Empty: ${response.isEmpty}');

      if (response.isNotEmpty) {
        try {
          final jsonResponse = await _parseJsonInIsolate(response);
          print('📊 Parsed JSON: $jsonResponse');

          // Check for specific fields
          if (jsonResponse is Map<String, dynamic>) {
            print(
              '🏪 Merchant Code: ${jsonResponse['merchantcode'] ?? 'Not found'}',
            );
            print('🔐 Salt Key: ${jsonResponse['saltkey'] ?? 'Not found'}');
            print(
              '💳 Transaction ID: ${jsonResponse['transactionid'] ?? 'Not found'}',
            );
            print(
              '👤 Customer ID: ${jsonResponse['customerid'] ?? 'Not found'}',
            );
          }
        } catch (parseError) {
          print('❌ JSON Parse Error: $parseError');
          print('📄 Raw response that failed to parse: "$response"');
        }
      } else {
        print('⚠️ Empty response received from API');
      }
      print('🎯 ===== IMMEDIATE TEST RESPONSE END =====');

      // Show result in a snackbar too
      if (response.isNotEmpty) {
        _showSuccessSnackBar(
          'API Response received! Check console for details.',
        );
      } else {
        _showErrorSnackBar('Empty response from getPaymentCredentials API');
      }
    } catch (e) {
      print('❌ Immediate test API call failed: $e');
      print('🔍 Error details: ${e.toString()}');
      print('📋 Error type: ${e.runtimeType}');
      _showErrorSnackBar('API test failed: $e');
    }
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

  void _showPaymentSuccessDialog(
    Map<String, dynamic> planData,
    String paymentType,
    double totalAmount,
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
                    'Your recharge has been completed successfully',
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
                        _buildSuccessDetailRow(
                          'Transaction ID',
                          '#TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        ),
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
}

// PaymentOption class to define payment method details
class PaymentOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final double charges;
  final bool isRecommended;

  PaymentOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.charges,
    this.isRecommended = false,
  });
}

// PaymentTypeDialog class to display payment options
class PaymentTypeDialog extends StatefulWidget {
  final double amount;
  final Function(String paymentType, double totalAmount) onPaymentSelected;

  const PaymentTypeDialog({
    Key? key,
    required this.amount,
    required this.onPaymentSelected,
  }) : super(key: key);

  @override
  _PaymentTypeDialogState createState() => _PaymentTypeDialogState();
}

class _PaymentTypeDialogState extends State<PaymentTypeDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String? selectedPaymentType;
  final List<PaymentOption> paymentOptions = [
    PaymentOption(
      id: 'upi',
      title: 'UPI',
      subtitle: '(no convenience charges)',
      icon: Icons.account_balance_wallet,
      gradient: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      charges: 0.0,
      isRecommended: true,
    ),
    PaymentOption(
      id: 'net_banking',
      title: 'NET Banking',
      subtitle: '(payment gateway charge @1.5% applicable)',
      icon: Icons.account_balance,
      gradient: [Color(0xFF2196F3), Color(0xFF0D47A1)],
      charges: 1.5,
    ),
    PaymentOption(
      id: 'debit_card',
      title: 'Debit Card',
      subtitle: '(payment gateway charge @0.4% applicable)',
      icon: Icons.credit_card,
      gradient: [Color(0xFF9C27B0), Color(0xFF4A148C)],
      charges: 0.4,
    ),
    PaymentOption(
      id: 'credit_card',
      title: 'Credit Card',
      subtitle: '(payment gateway charge @2.1% applicable)',
      icon: Icons.credit_card_outlined,
      gradient: [Color(0xFFFF5722), Color(0xFFBF360C)],
      charges: 2.1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double _calculateTotalAmount(double charges) {
    if (charges == 0) return widget.amount;
    return widget.amount + (widget.amount * charges / 100);
  }

  void _selectPaymentType(PaymentOption option) {
    setState(() {
      selectedPaymentType = option.id;
    });
    HapticFeedback.mediumImpact();
  }

  void _proceedWithPayment() {
    if (selectedPaymentType != null) {
      final selectedOption = paymentOptions.firstWhere(
        (option) => option.id == selectedPaymentType,
      );
      final totalAmount = _calculateTotalAmount(selectedOption.charges);
      widget.onPaymentSelected(selectedOption.id, totalAmount);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double dialogHeight = screenHeight * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            constraints: BoxConstraints(maxHeight: dialogHeight),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFFAFBFC), Color(0xFFF8F9FA)],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 40,
                  offset: Offset(0, 20),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(32, 32, 32, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Payment Type',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Amount to Pay',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '₹${widget.amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.payments,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Choose your preferred payment method',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4A5568),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ...paymentOptions.asMap().entries.map((entry) {
                          int index = entry.key;
                          PaymentOption option = entry.value;
                          bool isSelected = selectedPaymentType == option.id;

                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () => _selectPaymentType(option),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient:
                                      isSelected
                                          ? LinearGradient(
                                            colors: [
                                              option.gradient[0].withOpacity(
                                                0.1,
                                              ),
                                              option.gradient[1].withOpacity(
                                                0.05,
                                              ),
                                            ],
                                          )
                                          : LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Color(0xFFFAFBFC),
                                            ],
                                          ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? option.gradient[0]
                                            : Color(0xFFE2E8F0),
                                    width: isSelected ? 2.5 : 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          isSelected
                                              ? option.gradient[0].withOpacity(
                                                0.25,
                                              )
                                              : Colors.black.withOpacity(0.05),
                                      blurRadius: isSelected ? 20 : 10,
                                      offset: Offset(0, isSelected ? 8 : 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    if (option.isRecommended)
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
                                              colors: [
                                                Colors.orange,
                                                Colors.deepOrange,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              bottomLeft: Radius.circular(16),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'RECOMMENDED',
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
                                      padding: EdgeInsets.all(20),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: option.gradient,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: option.gradient[0]
                                                      .withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              option.icon,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  option.title,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1A202C),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  option.subtitle,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF718096),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                                SizedBox(height: 8),
                                                Wrap(
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Total: ',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Color(
                                                          0xFF4A5568,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '₹${_calculateTotalAmount(option.charges).toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            option.gradient[0],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (option.charges > 0) ...[
                                                      SizedBox(width: 8),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          '+${option.charges}%',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              gradient:
                                                  isSelected
                                                      ? LinearGradient(
                                                        colors: option.gradient,
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
                                                          color: option
                                                              .gradient[0]
                                                              .withOpacity(0.4),
                                                          blurRadius: 12,
                                                          offset: Offset(0, 4),
                                                        ),
                                                      ]
                                                      : [],
                                            ),
                                            child: Icon(
                                              isSelected
                                                  ? Icons.check_circle
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Color(0xFF718096),
                                              size: 20,
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
                        }).toList(),
                        SizedBox(height: 24),
                        Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  selectedPaymentType != null
                                      ? [Color(0xFF10B981), Color(0xFF059669)]
                                      : [Color(0xFFB0BEC5), Color(0xFF78909C)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    selectedPaymentType != null
                                        ? Color(0xFF10B981).withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed:
                                selectedPaymentType != null
                                    ? _proceedWithPayment
                                    : null,
                            child: Text(
                              'Proceed to Pay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'All transactions are secure and encrypted',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
