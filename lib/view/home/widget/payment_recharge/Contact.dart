import 'dart:convert';

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
      final response = await apiHelper.postApiResponse(
        'PostTransactionata.php',
        rechargeRequest.toJson(),
      );

      print('Raw API Response: $response');
      final jsonResponse = json.decode(response);
      print('Parsed JSON Response: $jsonResponse');

      if (jsonResponse['status'] == 'success' ||
          jsonResponse['status'] == '1' ||
          jsonResponse['status'] == '2') {
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
      print('Error processing payment: $e');
    }
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
                                            fontSize: 18, // Reduced from 20
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
                                            fontSize: 13, // Reduced from 14
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
                                  SizedBox(width: 8), // Add spacing
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
                                        fontSize: 10, // Reduced from 11
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
                    padding: EdgeInsets.all(16), // Reduced from 20
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 75, // Reduced from 85
                              height: 75, // Reduced from 85
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    plan['color'] as Color,
                                    (plan['color'] as Color).withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  18,
                                ), // Reduced from 20
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
                                            fontSize: 16, // Reduced from 18
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
                                              fontSize: 10, // Reduced from 11
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
                            SizedBox(width: 16), // Reduced from 20
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // First Row: Validity and Savings
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
                                              fontSize: 11, // Reduced from 12
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
                                  // Description
                                  Text(
                                    plan['description'] as String,
                                    style: TextStyle(
                                      fontSize: 14, // Reduced from 16
                                      color: Color(0xFF1A202C),
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                    maxLines: 2, // Changed from 1 to 2
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  // Benefits
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
                                                          fontSize:
                                                              11, // Reduced from 12
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
                                          fontSize: 10, // Reduced from 11
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
                              width: 45, // Reduced from 50
                              height: 45, // Reduced from 50
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
                                                  size: 20, // Reduced from 24
                                                )
                                                : Icon(
                                                  Icons.add_circle_outline,
                                                  color: Color(0xFF718096),
                                                  size: 20, // Reduced from 24
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
                        // Feature chips in a separate row
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
