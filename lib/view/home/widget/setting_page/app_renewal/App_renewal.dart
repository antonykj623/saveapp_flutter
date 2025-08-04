import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

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

  @override
  void initState() {
    super.initState();

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
          _buildRenewalCard(),
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
                colors: [Color(0xFF00D4AA), Color(0xFF00A8E8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00D4AA).withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.apps_rounded, color: Colors.white, size: 40),
          ),
          SizedBox(height: 16),
          Text(
            'Premium Access',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Unlock all features with your renewal',
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
            'Date of Activation',
            '19-07-2021',
            Icons.calendar_today_rounded,
            Color(0xFF00D4AA),
          ),
          SizedBox(height: 24),
          Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
          SizedBox(height: 24),
          _buildInfoRow(
            'Date of Expiry',
            '19-07-2022',
            Icons.schedule_rounded,
            Color(0xFFFF6B6B),
          ),
          SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFFF9800),
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
                        'Renewal Required',
                        style: TextStyle(
                          color: Color(0xFFE65100),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your subscription has expired',
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
              // Show the new payment confirmation dialog
              _showRenewalDialog();
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00D4AA), Color(0xFF00A8E8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00D4AA).withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Renew Now',
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

  // Updated method with modern payment dialog
  void _showRenewalDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PaymentConfirmationDialog();
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
          // Header with animated icon
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
                        colors: [Color(0xFF00D4AA), Color(0xFF00A8E8)],
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
                  'Payment Confirmation',
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

          // Price display with animation
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
                        color: Color(0xFF00D4AA),
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

          // Payment details
          _buildPaymentDetail('Subscription Plan', 'Premium Annual'),
          SizedBox(height: 12),
          _buildPaymentDetail('Duration', '12 Months'),
          SizedBox(height: 12),
          _buildPaymentDetail('Payment Method', 'UPI / Card'),

          SizedBox(height: 32),

          // Action buttons
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
                                colors: [Color(0xFF00D4AA), Color(0xFF00A8E8)],
                              ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00D4AA).withOpacity(0.3),
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
                                    'Confirm Payment',
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

          // Security notice
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
          // Success animation
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple effect
                  Container(
                    width: 120 * _rippleAnimation.value,
                    height: 120 * _rippleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(
                        0xFF00D4AA,
                      ).withOpacity(0.2 * (1 - _rippleAnimation.value)),
                    ),
                  ),
                  // Success icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00D4AA), Color(0xFF00A8E8)],
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
            'Payment Successful!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 12),

          Text(
            'Your premium subscription has been\nactivated successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),

          SizedBox(height: 32),

          // Success details
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF00D4AA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSuccessDetail('Transaction ID', '#TXN826071425'),
                SizedBox(height: 12),
                _buildSuccessDetail('Valid Until', '19-07-2023'),
                SizedBox(height: 12),
                _buildSuccessDetail('Plan', 'Premium Annual'),
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
                  colors: [Color(0xFF00D4AA), Color(0xFF00A8E8)],
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
            color: Color(0xFF00A8E8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF00D4AA),
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

// Main app wrapper
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Renewal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AppRenewalScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(MyApp());
}
