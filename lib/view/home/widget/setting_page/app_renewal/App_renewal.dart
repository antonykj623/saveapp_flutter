import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show debugPrint; // For debug logging

class AppRenewalScreen extends StatefulWidget {
  @override
  _AppRenewalScreenState createState() => _AppRenewalScreenState();
}

class _AppRenewalScreenState extends State<AppRenewalScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  String _phoneNumber = '';
  String _memberStatus = 'Loading...';
  String _dateOfActivation = 'Loading...';
  String _dateOfExpiry = 'Loading...';
  bool _isLoading = true;
  String _errorMessage = '';
  final ApiHelper _apiHelper = ApiHelper();

  // Trial period related variables
  bool _isTrialActive = false;
  int _trialDaysRemaining = 0;
  String _trialStartDate = '';
  String _joinDate = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchUserProfileAndDST();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _fetchUserProfileAndDST() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Step 1: Fetch user profile
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Token not found. Please login again.';
        });
        debugPrint('Error: Token not found in SharedPreferences');
        return;
      }

      String response = await _apiHelper.postApiResponse(
        "getUserDetails.php",
        {},
      );
      debugPrint('getUserDetails.php Response: $response'); // Log response
      var profileData = json.decode(response);
      if (profileData['status'] == 1) {
        _phoneNumber = profileData['data']['mobile']?.toString() ?? '';
        debugPrint('Extracted Phone Number: $_phoneNumber'); // Log phone number
        if (_phoneNumber.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Phone number not found in profile.';
          });
          debugPrint('Error: Phone number not found in profile data');
          return;
        }

        // Step 2: Fetch DST data
        await _fetchDSTData(_phoneNumber);
      } else {
        // If getUserDetails status != 1, call trial period validation API
        debugPrint('getUserDetails.php status != 1, checking trial period...');
        await _validateTrialPeriod();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching profile: $e';
      });
      debugPrint('Exception in _fetchUserProfileAndDST: $e');
    }
  }

  Future<void> _validateTrialPeriod() async {
    try {
      // Get current time in milliseconds since epoch (Unix time)
      int currentMillis = DateTime.now().millisecondsSinceEpoch;
      debugPrint('Current timestamp in milliseconds: $currentMillis');

      final url = Uri.parse(
        'https://mysaving.in/IntegraAccount/api/validateTrialPeriod.php?timestamp=$currentMillis',
      );
      debugPrint('Trial Validation API URL: $url');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      debugPrint('Token for Trial Validation API: $token');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('validateTrialPeriod.php Status Code: ${response.statusCode}');
      debugPrint('validateTrialPeriod.php Response: ${response.body}');

      if (response.statusCode == 200) {
        var trialData = json.decode(response.body);
        if (trialData['status'] == 1) {
          // Parse trial data
          _joinDate = trialData['data']['join_date'] ?? '';
          _trialStartDate = trialData['data']['trialstart_date'] ?? '';
          _isTrialActive = true;
          _memberStatus = 'trial';

          debugPrint('API Response - Join Date: $_joinDate');
          debugPrint('API Response - Trial Start Date: $_trialStartDate');

          // Calculate remaining days based on join_date - current_date
          if (_joinDate.isNotEmpty) {
            try {
              DateTime joinDateTime = DateTime.parse(_joinDate);
              DateTime currentDate = DateTime.now();

              // Calculate days remaining: join_date - current_date
              _trialDaysRemaining = joinDateTime.difference(currentDate).inDays;

              // Ensure it doesn't go negative
              if (_trialDaysRemaining < 0) {
                _trialDaysRemaining = 0;
              }

              debugPrint('Join Date: $joinDateTime');
              debugPrint('Current Date: $currentDate');
              debugPrint(
                'Calculated Trial Days Remaining: $_trialDaysRemaining',
              );

              // Format activation date (use trial start date if available, otherwise join date)
              DateTime activationDate =
                  _trialStartDate.isNotEmpty
                      ? DateTime.parse(_trialStartDate)
                      : joinDateTime;
              _dateOfActivation = DateFormat(
                'dd-MM-yyyy',
              ).format(activationDate);

              // Remove expiry date calculation - we don't need it anymore
              _dateOfExpiry = ''; // Clear this since we're not showing it

              debugPrint('Formatted Activation Date: $_dateOfActivation');
            } catch (e) {
              debugPrint('Error calculating trial dates: $e');
              _dateOfActivation = 'N/A';
              _dateOfExpiry = '';
              _trialDaysRemaining = 0;
            }
          } else {
            // Fallback if join date is not available
            _trialDaysRemaining = 0;
            _dateOfActivation = 'N/A';
            _dateOfExpiry = '';
          }

          setState(() {
            _isLoading = false;
          });

          debugPrint('Final Trial Days Remaining: $_trialDaysRemaining');
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = trialData['message'] ?? 'Trial validation failed.';
          });
          debugPrint(
            'Error: validateTrialPeriod.php failed with message: ${trialData['message']}',
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to validate trial period: ${response.statusCode}';
        });
        debugPrint(
          'Error: validateTrialPeriod.php failed with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error validating trial period: $e';
      });
      debugPrint('Exception in _validateTrialPeriod: $e');
    }
  }

  Future<void> _fetchDSTData(String phoneNumber) async {
    try {
      final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      debugPrint('Generated Timestamp: $timestamp'); // Log timestamp
      final url = Uri.parse(
        'https://mysaving.in/IntegraAccount/api/getDSTByPhoneNumber.php?mobile=$phoneNumber&timestamp=$timestamp',
      );
      debugPrint('DST API URL: $url'); // Log URL

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      debugPrint('Token for DST API: $token'); // Log token

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint(
        'getDSTByPhoneNumber.php Status Code: ${response.statusCode}',
      ); // Log status code
      debugPrint(
        'getDSTByPhoneNumber.php Response: ${response.body}',
      ); // Log full response

      if (response.statusCode == 200) {
        var dstData = json.decode(response.body);
        if (dstData['status'] == 1 &&
            dstData['data'] != null &&
            dstData['data']['member_status'] == 'active') {
          _memberStatus = dstData['data']['member_status'] ?? 'N/A';
          debugPrint('Member Status: $_memberStatus'); // Log member status
          // Step 3: Fetch payment details if member_status is active
          await _fetchPaymentDetails();
        } else {
          // Handle case when status is 0 or data is null
          if (dstData['status'] == 0 || dstData['data'] == null) {
            debugPrint('DST API returned no data, checking trial period...');
            await _validateTrialPeriod();
          } else {
            setState(() {
              _isLoading = false;
              _memberStatus = dstData['data']?['member_status'] ?? 'N/A';
              _errorMessage =
                  dstData['message'] ??
                  'Member status is not active or failed to fetch DST data.';
            });
            debugPrint(
              'Error: getDSTByPhoneNumber.php failed with message: ${dstData['message']} or member_status: ${_memberStatus}',
            );
          }
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch DST data: ${response.statusCode}';
        });
        debugPrint(
          'Error: getDSTByPhoneNumber.php failed with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching DST data: $e';
      });
      debugPrint('Exception in _fetchDSTData: $e');
    }
  }

  Future<void> _fetchPaymentDetails() async {
    try {
      final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      debugPrint('Payment Details Timestamp: $timestamp'); // Log timestamp
      final url = Uri.parse(
        'https://mysaving.in/IntegraAccount/api/getpaymentDetails.php?timestamp=$timestamp',
      );
      debugPrint('Payment Details API URL: $url'); // Log URL

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      debugPrint('Token for Payment Details API: $token'); // Log token

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint(
        'getpaymentDetails.php Status Code: ${response.statusCode}',
      ); // Log status code
      debugPrint(
        'getpaymentDetails.php Response: ${response.body}',
      ); // Log full response

      if (response.statusCode == 200) {
        var paymentData = json.decode(response.body);
        if (paymentData['status'] == 1) {
          setState(() {
            // Format sales_date (e.g., "2021-07-19 22:12:38" to "19-07-2021")
            _dateOfActivation =
                paymentData['data']['sales_date'] != null
                    ? DateFormat(
                      'dd-MM-yyyy',
                    ).format(DateTime.parse(paymentData['data']['sales_date']))
                    : 'N/A';
            // Format expe_date (e.g., "2022-07-19" to "19-07-2022")
            _dateOfExpiry =
                paymentData['data']['expe_date'] != null
                    ? DateFormat(
                      'dd-MM-yyyy',
                    ).format(DateTime.parse(paymentData['data']['expe_date']))
                    : 'N/A';
            _isLoading = false;
          });
          debugPrint(
            'Date of Activation: $_dateOfActivation',
          ); // Log activation date
          debugPrint('Date of Expiry: $_dateOfExpiry'); // Log expiry date
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage =
                paymentData['message'] ?? 'Failed to fetch payment details.';
          });
          debugPrint(
            'Error: getpaymentDetails.php failed with message: ${paymentData['message']}',
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to fetch payment details: ${response.statusCode}';
        });
        debugPrint(
          'Error: getpaymentDetails.php failed with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching payment details: $e';
      });
      debugPrint('Exception in _fetchPaymentDetails: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: _buildContent(),
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

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Text(
            'App Renewal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeaderCard(),
          SizedBox(height: 30),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
              : _buildRenewalCard(),
          Spacer(),
          _buildRenewButton(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _isTrialActive
                        ? [Color(0xFFFF9800), Color(0xFFFF5722)]
                        : [Color(0xFF00D4AA), Color(0xFF00A8E8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_isTrialActive
                          ? Color(0xFFFF9800)
                          : Color(0xFF00D4AA))
                      .withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _isTrialActive ? Icons.access_time_rounded : Icons.apps_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(height: 16),
          Text(
            _isTrialActive ? 'Trial Access' : 'Premium Access',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _isTrialActive
                ? 'You have $_trialDaysRemaining days remaining in your trial'
                : 'Unlock all features with your renewal',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            _isTrialActive ? 'Trial Start Date' : 'Date of Activation',
            _dateOfActivation,
            Icons.calendar_today_rounded,
            Color(0xFF00D4AA),
          ),
          // Remove the Trial Expiry Date section completely for trial users
          if (!_isTrialActive) ...[
            SizedBox(height: 24),
            Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
            SizedBox(height: 24),
            _buildInfoRow(
              'Date of Expiry',
              _dateOfExpiry,
              Icons.schedule_rounded,
              Color(0xFFFF6B6B),
            ),
          ],
          if (_isTrialActive) ...[
            SizedBox(height: 24),
            Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
            SizedBox(height: 24),
            _buildInfoRow(
              'Days Remaining',
              '$_trialDaysRemaining days',
              Icons.hourglass_bottom_rounded,
              Color(0xFFFF9800),
            ),
          ],
          SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _isTrialActive
                        ? [Color(0xFFFFF3E0), Color(0xFFFFE0B2)]
                        : [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        _isTrialActive ? Color(0xFFFF9800) : Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscription Status',
                        style: TextStyle(
                          color: Color(0xFFE65100),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _isTrialActive
                            ? 'You are in trial period'
                            : _memberStatus == 'active'
                            ? 'Your subscription is active'
                            : 'Your subscription has expired',
                        style: TextStyle(
                          color: Color(0xFFBF360C),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRenewButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showRenewalDialog();
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      _isTrialActive
                          ? [Color(0xFFFF9800), Color(0xFFFF5722)]
                          : [Color(0xFF00D4AA), Color(0xFF00A8E8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isTrialActive
                            ? Color(0xFFFF9800)
                            : Color(0xFF00D4AA))
                        .withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isTrialActive
                        ? Icons.upgrade_rounded
                        : Icons.refresh_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    _isTrialActive ? 'Upgrade Now' : 'Renew Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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

  void _showRenewalDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PaymentConfirmationDialog(
          dateOfExpiry: _dateOfExpiry,
          isTrialUpgrade: _isTrialActive,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}

// Payment Confirmation Dialog Widget
class PaymentConfirmationDialog extends StatefulWidget {
  final String dateOfExpiry;
  final bool isTrialUpgrade;

  PaymentConfirmationDialog({
    required this.dateOfExpiry,
    this.isTrialUpgrade = false,
  });

  @override
  _PaymentConfirmationDialogState createState() =>
      _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<PaymentConfirmationDialog>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _shimmerController;
  late AnimationController _rippleController;
  late AnimationController _progressController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _progressAnimation;

  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _bounceController.forward();
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shimmerController.dispose();
    _rippleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              margin: EdgeInsets.all(20),
              child: Material(
                elevation: 20,
                borderRadius: BorderRadius.circular(24),
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.grey.shade50],
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
                  child:
                      _isSuccess
                          ? _buildSuccessContent()
                          : _buildPaymentContent(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentContent() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            widget.isTrialUpgrade
                                ? [Color(0xFFFF9800), Color(0xFFFF5722)]
                                : [Color(0xFF00D4AA), Color(0xFF00A8E8)],
                        transform: GradientRotation(_shimmerAnimation.value),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.payment_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.isTrialUpgrade
                      ? 'Upgrade Confirmation'
                      : 'Payment Confirmation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea).withOpacity(0.1),
                  Color(0xFF764ba2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFF667eea).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Total Price',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color:
                            widget.isTrialUpgrade
                                ? Color(0xFFFF9800)
                                : Color(0xFF00D4AA),
                      ),
                    ),
                    Text(
                      '826.0',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      ' INR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildPaymentDetail('Subscription Plan', 'Premium Annual'),
          SizedBox(height: 12),
          _buildPaymentDetail('Duration', '12 Months'),
          SizedBox(height: 12),
          _buildPaymentDetail('Payment Method', 'UPI / Card'),
          if (widget.isTrialUpgrade) ...[
            SizedBox(height: 12),
            _buildPaymentDetail('Current Status', 'Trial User'),
          ],
          SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _processPayment,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: 50,
                    decoration: BoxDecoration(
                      gradient:
                          _isProcessing
                              ? LinearGradient(
                                colors: [Colors.grey, Colors.grey],
                              )
                              : LinearGradient(
                                colors:
                                    widget.isTrialUpgrade
                                        ? [Color(0xFFFF9800), Color(0xFFFF5722)]
                                        : [
                                          Color(0xFF00D4AA),
                                          Color(0xFF00A8E8),
                                        ],
                              ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isTrialUpgrade
                                  ? Color(0xFFFF9800)
                                  : Color(0xFF00D4AA))
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child:
                          _isProcessing
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Processing...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.security_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    widget.isTrialUpgrade
                                        ? 'Confirm Upgrade'
                                        : 'Confirm Payment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, color: Colors.grey[500], size: 16),
              SizedBox(width: 6),
              Text(
                'Secured by 256-bit SSL encryption',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120 * _rippleAnimation.value,
                    height: 120 * _rippleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (widget.isTrialUpgrade
                              ? Color(0xFFFF9800)
                              : Color(0xFF00D4AA))
                          .withOpacity(0.2 * (1 - _rippleAnimation.value)),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            widget.isTrialUpgrade
                                ? [Color(0xFFFF9800), Color(0xFFFF5722)]
                                : [Color(0xFF00D4AA), Color(0xFF00A8E8)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            widget.isTrialUpgrade
                ? 'Upgrade Successful!'
                : 'Payment Successful!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Text(
            widget.isTrialUpgrade
                ? 'Your account has been upgraded to\npremium successfully'
                : 'Your premium subscription has been\nactivated successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (widget.isTrialUpgrade
                      ? Color(0xFFFF9800)
                      : Color(0xFF00D4AA))
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSuccessDetail('Transaction ID', '#TXN826071425'),
                SizedBox(height: 12),
                _buildSuccessDetail('Valid Until', widget.dateOfExpiry),
                SizedBox(height: 12),
                _buildSuccessDetail('Plan', 'Premium Annual'),
                if (widget.isTrialUpgrade) ...[
                  SizedBox(height: 12),
                  _buildSuccessDetail('Previous Status', 'Trial'),
                ],
              ],
            ),
          ),
          SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      widget.isTrialUpgrade
                          ? [Color(0xFFFF9800), Color(0xFFFF5722)]
                          : [Color(0xFF00D4AA), Color(0xFF00A8E8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color:
                widget.isTrialUpgrade ? Color(0xFFFF5722) : Color(0xFF00A8E8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color:
                widget.isTrialUpgrade ? Color(0xFFFF9800) : Color(0xFF00D4AA),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _processPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate payment processing
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });

    _rippleController.forward();
    HapticFeedback.lightImpact();
  }
}
