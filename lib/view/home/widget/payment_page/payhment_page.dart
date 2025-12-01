import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/payment_page/Month_date/Moth_datepage.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'add_payment/add_paymet.dart';
import 'payment_class/payment_class.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage>
    with TickerProviderStateMixin {
  String selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  List<Payment> payments = [];
  double total = 0;
  final ScrollController _verticalScrollController = ScrollController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fabController;
  late AnimationController _waveController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fabAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isLoading = false;
  double _animatedTotal = 0;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _loadPayments();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(_waveController);

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _slideController.forward();
    _fabController.forward();
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 4 + 2,
          speed: random.nextDouble() * 0.5 + 0.2,
          color:
              [
                Colors.purple.withOpacity(0.3),
                Colors.blue.withOpacity(0.3),
                Colors.cyan.withOpacity(0.3),
              ][random.nextInt(3)],
        ),
      );
    }
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _fabController.dispose();
    _waveController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    _fadeController.reset();

    try {
      List<Map<String, dynamic>> paymentsList = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTS");
      List<Map<String, dynamic>> accountSettings = await DatabaseHelper()
          .getAllData("TABLE_ACCOUNTSETTINGS");

      Map<String, String> setupIdToAccountName = {};
      for (var account in accountSettings) {
        try {
          final dataValue = account["data"];
          if (dataValue is String && dataValue.isNotEmpty) {
            Map<String, dynamic> accountData = jsonDecode(dataValue);
            String setupId = account['keyid'].toString();
            String accountName = accountData['Accountname'].toString();
            setupIdToAccountName[setupId] = accountName;
          }
        } catch (e) {
          print('Error parsing account settings: $e');
        }
      }

      final uniqueDebitEntries = <String, Map<String, dynamic>>{};
      for (var mp in paymentsList) {
        if (mp['ACCOUNTS_VoucherType'] == 1 &&
            mp['ACCOUNTS_type'] == 'debit' &&
            DateFormat(
                  'yyyy-MM',
                ).format(DateFormat('dd/MM/yyyy').parse(mp['ACCOUNTS_date'])) ==
                selectedYearMonth) {
          uniqueDebitEntries[mp['ACCOUNTS_entryid'].toString()] = mp;
        }
      }

      setState(() {
        payments =
            uniqueDebitEntries.values.map((mp) {
              String debitSetupId = mp['ACCOUNTS_setupid'].toString();
              String accountName =
                  setupIdToAccountName[debitSetupId] ??
                  'Unknown Account (ID: $debitSetupId)';

              String paymentMode = 'Cash';
              try {
                var creditEntry = paymentsList.firstWhere(
                  (entry) =>
                      entry['ACCOUNTS_VoucherType'] == 1 &&
                      entry['ACCOUNTS_type'] == 'credit' &&
                      entry['ACCOUNTS_entryid'].toString() ==
                          mp['ACCOUNTS_entryid'].toString(),
                );
                String creditSetupId =
                    creditEntry['ACCOUNTS_setupid'].toString();
                paymentMode = setupIdToAccountName[creditSetupId] ?? 'Cash';
              } catch (e) {
                print(
                  'Could not find credit entry for payment ID ${mp['ACCOUNTS_entryid']}: $e',
                );
              }

              // FIX: Safe parsing for large amounts using helper method
              double amount = _safeParseDouble(mp['ACCOUNTS_amount']);

              return Payment(
                id: int.parse(mp['ACCOUNTS_entryid']),
                date: mp['ACCOUNTS_date'],
                accountName: accountName,
                amount: amount,
                paymentMode: paymentMode,
                remarks: mp['ACCOUNTS_remarks'] ?? '',
              );
            }).toList();

        // FIX: Safe total calculation with precision handling
        total = _calculateTotal(payments);

        _isLoading = false;
      });

      _animateTotal();
      _fadeController.forward();
    } catch (e) {
      print('Error loading payments: $e');
      if (mounted) {
        _showStyledSnackBar('Error loading payments: $e', Colors.red);
      }
      setState(() {
        payments = [];
        total = 0;
        _isLoading = false;
      });
    }
  }

  String _formatAmount(double amount) {
    try {
      // Handle very large numbers
      if (amount.isInfinite || amount.isNaN) {
        return '0.00';
      }

      if (amount >= 10000000) {
        // Crores
        return '${(amount / 10000000).toStringAsFixed(2)} Cr';
      } else if (amount >= 100000) {
        // Lakhs
        return '${(amount / 100000).toStringAsFixed(2)} L';
      } else if (amount >= 1000) {
        // Thousands with Indian formatting
        final formatter = NumberFormat('#,##,###.##', 'en_IN');
        return formatter.format(amount);
      } else {
        // Less than 1000
        return amount.toStringAsFixed(2);
      }
    } catch (e) {
      print('Error formatting amount: $e');
      return '0.00';
    }
  }

  double _safeParseDouble(dynamic value, {double defaultValue = 0.0}) {
    try {
      if (value == null) return defaultValue;

      String strValue = value.toString().replaceAll(',', '').trim();

      if (strValue.isEmpty) return defaultValue;

      double parsed = double.parse(strValue);

      if (parsed.isInfinite || parsed.isNaN) {
        return defaultValue;
      }

      return parsed;
    } catch (e) {
      print('Error parsing double from $value: $e');
      return defaultValue;
    }
  }

  double _calculateTotal(List<Payment> paymentList) {
    if (paymentList.isEmpty) return 0.0;

    try {
      // Use BigInt for very large amounts to avoid precision loss
      // Convert to smallest unit (paise) for calculation
      int totalPaise = 0;

      for (var payment in paymentList) {
        if (payment.amount.isInfinite || payment.amount.isNaN) {
          continue;
        }
        // Convert to paise (multiply by 100) and add
        totalPaise += (payment.amount * 100).round();
      }

      // Convert back to rupees
      double total = totalPaise / 100.0;

      // Validate result
      if (total.isInfinite || total.isNaN) {
        return 0.0;
      }

      return total;
    } catch (e) {
      print('Error calculating total: $e');
      return 0.0;
    }
  }

  void _animateTotal() {
    double targetTotal = total;

    // Validate total before animation
    if (targetTotal.isInfinite || targetTotal.isNaN) {
      targetTotal = 0.0;
    }

    // For large amounts, skip animation and set directly
    if (targetTotal > 999999999) {
      if (mounted) {
        setState(() {
          _animatedTotal = targetTotal;
        });
      }
      return;
    }

    int steps = 60;
    int stepDuration = 30;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: i * stepDuration), () {
        if (mounted) {
          setState(() {
            _animatedTotal = (targetTotal * i) / steps;
          });
        }
      });
    }
  }

  void _showStyledSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.red ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showMonthYearPicker() {
    final yearMonthParts = selectedYearMonth.split('-');
    final initialYear = int.parse(yearMonthParts[0]);
    final initialMonth = int.parse(yearMonthParts[1]);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.7,
            end: 1.0,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.elasticOut)),
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple[50]!,
                      Colors.blue[50]!,
                      Colors.white,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: MonthYearPicker(
                  initialMonth: initialMonth,
                  initialYear: initialYear,
                  onDateSelected: (int month, int year) {
                    setState(() {
                      selectedYearMonth =
                          '$year-${month.toString().padLeft(2, '0')}';
                      _fadeController.reset();
                      _loadPayments();
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDisplayMonth() {
    final parts = selectedYearMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthName = DateFormat('MMMM').format(DateTime(2022, month));
    return '$monthName $year';
  }

  void _navigateToEditPayment(Payment payment) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                AddPaymentVoucherPage(payment: payment),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );

    if (result == true) {
      _fadeController.reset();
      _loadPayments();
    }
  }

  void _updateTotalAfterChange() {
    setState(() {
      total = _calculateTotal(payments);
      _animatedTotal = total;
    });
  }

  void _deletePayment(int id) async {
    try {
      final db = await DatabaseHelper().database;

      await db.delete(
        "TABLE_ACCOUNTS",
        where: "ACCOUNTS_VoucherType = ? AND ACCOUNTS_entryid = ?",
        whereArgs: [1, id.toString()],
      );

      await db.delete(
        "TABLE_WALLET",
        where: "data LIKE ?",
        whereArgs: ['%"paymentEntryId":"$id"%'],
      );

      final isBalanced = await DatabaseHelper().validateDoubleEntry();
      if (!isBalanced) {
        throw Exception('Double-entry accounting is unbalanced after deletion');
      }

      // Reload payments and recalculate total
      _fadeController.reset();
      await _loadPayments();
      _updateTotalAfterChange();

      if (mounted) {
        _showStyledSnackBar('Payment deleted successfully! ✨', Colors.green);
      }
    } catch (e) {
      print('Error deleting payment: $e');
      if (mounted) {
        _showStyledSnackBar('Error deleting payment: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isMediumScreen = size.width >= 360 && size.width < 400;

    final titleFontSize =
        isSmallScreen
            ? 20.0
            : isMediumScreen
            ? 22.0
            : 24.0;
    final headerFontSize =
        isSmallScreen
            ? 11.0
            : isMediumScreen
            ? 12.0
            : 13.0;
    final contentFontSize =
        isSmallScreen
            ? 10.5
            : isMediumScreen
            ? 11.0
            : 11.5;
    final totalFontSize =
        isSmallScreen
            ? 20.0
            : isMediumScreen
            ? 22.0
            : 24.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Animated Floating Particles Background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  animation: _particleController.value,
                ),
                size: Size(size.width, size.height),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER SECTION with Wave Animation
                AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return ClipPath(
                      clipper: WaveClipper(_waveAnimation.value),
                      child: Container(
                        width: size.width,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.02,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple[700]!,
                              Colors.deepPurple[600]!,
                              Colors.blue[600]!,
                              Colors.cyan[500]!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Animated Back Button
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: size.width * 0.11,
                                    height: size.width * 0.11,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.white,
                                        size: isSmallScreen ? 20 : 22,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: size.width * 0.03),

                            // Title with 3D rotating icon
                            Expanded(
                              child: Row(
                                children: [
                                  AnimatedBuilder(
                                    animation: _rotationAnimation,
                                    builder: (context, child) {
                                      return Transform(
                                        alignment: Alignment.center,
                                        transform:
                                            Matrix4.identity()
                                              ..setEntry(3, 2, 0.001)
                                              ..rotateY(
                                                _rotationAnimation.value,
                                              ),
                                        child: Container(
                                          padding: EdgeInsets.all(
                                            isSmallScreen ? 8.0 : 10.0,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.1),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            color: Colors.white,
                                            size: isSmallScreen ? 20 : 24,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: size.width * 0.03),
                                  Flexible(
                                    child: ShaderMask(
                                      shaderCallback:
                                          (bounds) => LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.white.withOpacity(0.9),
                                            ],
                                          ).createShader(bounds),
                                      child: Text(
                                        'Payment Journal',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: titleFontSize,
                                          letterSpacing: 0.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              offset: const Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Animated Refresh Button
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: size.width * 0.11,
                                    height: size.width * 0.11,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.white,
                                        size: isSmallScreen ? 22 : 26,
                                      ),
                                      onPressed: () {
                                        _fadeController.reset();
                                        _loadPayments();
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: size.height * 0.015),

                // MONTH SELECTOR with Slide Animation
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                    child: InkWell(
                      onTap: _showMonthYearPicker,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.045),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.purple[50]!,
                              Colors.blue[50]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.purple[100]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                isSmallScreen ? 12.0 : 14.0,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.purple[500]!,
                                    Colors.deepPurple[600]!,
                                    Colors.blue[500]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.date_range_rounded,
                                color: Colors.white,
                                size: isSmallScreen ? 22 : 24,
                              ),
                            ),
                            SizedBox(width: size.width * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Period',
                                    style: TextStyle(
                                      fontSize: contentFontSize,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getDisplayMonth(),
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 17 : 19,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.purple[800],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.purple[700],
                                      size: isSmallScreen ? 24 : 28,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.015),

                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.15),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.purple[100]!,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child:
                            _isLoading
                                ? _buildShimmerLoading()
                                : payments.isEmpty
                                ? _buildEmptyState()
                                : Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.purple[600]!,
                                            Colors.deepPurple[700]!,
                                            Colors.blue[600]!,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.purple.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: _buildHeaderCell(
                                              'Date',
                                              headerFontSize,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: _buildHeaderCell(
                                              'Accounts',
                                              headerFontSize,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: _buildHeaderCell(
                                              'Amount',
                                              headerFontSize,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: _buildHeaderCell(
                                              'Actions',
                                              headerFontSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // TABLE CONTENT
                                    Expanded(
                                      child: _buildJournalList(contentFontSize),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.015),

                // TOTAL AMOUNT CARD with Glow Effect
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.01,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.98 + (_pulseAnimation.value - 1) * 0.5,
                          child: Container(
                            width: size.width,
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05,
                              vertical: size.height * 0.025,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  // PAYMENT PAGE: Green colors
                                  Colors.green[500]!,
                                  Colors.teal[500]!,
                                  Colors.cyan[500]!,

                                  // RECEIPT PAGE: Teal colors
                                  // Colors.teal[500]!,
                                  // Colors.green[500]!,
                                  // Colors.lightGreen[500]!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(
                                    0.4,
                                  ), // or Colors.teal for receipt
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.teal.withOpacity(
                                    0.3,
                                  ), // or Colors.green for receipt
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                        isSmallScreen ? 10.0 : 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.account_balance_wallet_rounded,
                                        color: Colors.white,
                                        size: isSmallScreen ? 24 : 28,
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.03),
                                    Text(
                                      'Total Payments', // or 'Total Receipts' for receipt page
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 15 : 17,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                ShaderMask(
                                  shaderCallback:
                                      (bounds) => LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.white.withOpacity(0.95),
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    '₹${_formatAmount(_animatedTotal)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: totalFontSize,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.2),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.08),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: size.height * 0.01,
        ), // Add bottom padding
        child: ScaleTransition(
          scale: _fabAnimation,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: isSmallScreen ? 64 : 68,
                  height: isSmallScreen ? 64 : 68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        // PAYMENT PAGE: Purple colors
                        Colors.purple[600]!,
                        Colors.deepPurple[700]!,
                        Colors.blue[600]!,

                        // RECEIPT PAGE: Green colors
                        // Colors.green[600]!,
                        // Colors.teal[700]!,
                        // Colors.cyan[600]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(
                          0.5,
                        ), // or Colors.green for receipt
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.blue.withOpacity(
                          0.3,
                        ), // or Colors.teal for receipt
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const AddPaymentVoucherPage(), // or AddReceiptVoucherPage()
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.8,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.elasticOut,
                                ),
                              ),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                        ),
                      ).then((result) {
                        if (result == true) {
                          _fadeController.reset();
                          _loadPayments(); // or _loadReceipts()
                        }
                      });
                    },
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 32 : 36,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double fontSize) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[200]!, Colors.grey[100]!],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.grey[300]!,
                          Colors.grey[100]!,
                          Colors.grey[300]!,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment(_shimmerAnimation.value - 1, 0),
                        end: Alignment(_shimmerAnimation.value, 0),
                      ).createShader(bounds);
                    },
                    child: Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.grey[300]!,
                          Colors.grey[100]!,
                          Colors.grey[300]!,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment(_shimmerAnimation.value - 1, 0),
                        end: Alignment(_shimmerAnimation.value, 0),
                      ).createShader(bounds);
                    },
                    child: Container(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 24.0 : 28.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple[100]!,
                          Colors.blue[100]!,
                          Colors.cyan[100]!,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: isSmallScreen ? 60 : 70,
                      color: Colors.purple[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [Colors.purple[600]!, Colors.blue[600]!],
                        ).createShader(bounds),
                    child: Text(
                      'No Payments Yet',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 22 : 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap the + button to add your first payment',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.purple[400],
                          size: 32,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJournalList(double fontSize) {
    return ListView.builder(
      controller: _verticalScrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: _buildJournalEntry(payments[index], index, fontSize),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJournalEntry(Payment payment, int index, double fontSize) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.purple[50]!.withOpacity(0.3)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.purple[100]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // DEBIT ROW
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.red[50]!.withOpacity(0.4)],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDataCell(
                      payment.date,
                      fontSize,
                      isFirst: true,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.purple[400]!, Colors.blue[400]!],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildDataCell(
                      payment.accountName,
                      fontSize,
                      isDebit: false,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildDataCell(
                      '₹${_formatAmount(payment.amount)} Dr',
                      fontSize,
                      isAmount: true,
                      isDebit: true,
                    ),
                  ),
                  Expanded(flex: 2, child: _buildActionCell(payment, fontSize)),
                ],
              ),
            ),

            // CREDIT ROW
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.green[50]!.withOpacity(0.4)],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDataCell('', fontSize, isFirst: true),
                  ),
                  Container(
                    width: 2,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.purple[400]!, Colors.blue[400]!],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildDataCell(
                      '     To ${payment.paymentMode}',
                      fontSize,
                      isCredit: false,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildDataCell(
                      '₹${_formatAmount(payment.amount)} Cr',
                      fontSize,
                      isAmount: true,
                      isCredit: true,
                    ),
                  ),
                  Expanded(flex: 2, child: _buildDataCell('', fontSize)),
                ],
              ),
            ),

            // REMARKS ROW
            if (payment.remarks != null && payment.remarks!.isNotEmpty)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.purple[50]!],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[200]!, Colors.purple[200]!],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notes_rounded,
                        size: 16,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Remarks: ${payment.remarks}',
                        style: TextStyle(
                          fontSize: fontSize - 0.5,
                          color: Colors.blue[900],
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text,
    double fontSize, {
    bool isFirst = false,
    bool isDebit = false,
    bool isCredit = false,
    bool isAmount = false,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Align(
        alignment:
            isAmount
                ? Alignment.centerRight
                : isFirst
                ? Alignment.center
                : Alignment.centerLeft,
        child: Text(
          text,
          textAlign:
              isAmount
                  ? TextAlign.right
                  : isFirst
                  ? TextAlign.center
                  : TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight:
                isDebit || isCredit || isAmount
                    ? FontWeight.w700
                    : FontWeight.w500,
            color:
                isDebit
                    ? Colors.red[700]
                    : isCredit
                    ? Colors.green[700]
                    : isAmount
                    ? Colors.green[800]
                    : Colors.grey[800],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(Payment payment, double fontSize) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[500]!, Colors.blue[700]!],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _navigateToEditPayment(payment),
                  child: Center(
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 16 : 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red[500]!, Colors.red[700]!],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showDeleteConfirmation(payment.id!),
                  child: Center(
                    child: Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 16 : 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.7,
            end: 1.0,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.elasticOut)),
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                width: size.width * 0.85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.red[50]!, Colors.orange[50]!],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(size.width * 0.06),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: EdgeInsets.all(
                              isSmallScreen ? 16.0 : 18.0,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange[500]!, Colors.red[500]!],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: isSmallScreen ? 36 : 40,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            colors: [Colors.red[700]!, Colors.orange[700]!],
                          ).createShader(bounds),
                      child: Text(
                        'Confirm Delete',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    Text(
                      'Are you sure you want to delete this payment? This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 15,
                        color: Colors.grey[700],
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: isSmallScreen ? 48 : 52,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w700,
                                  fontSize: isSmallScreen ? 15 : 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: isSmallScreen ? 48 : 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red[600]!, Colors.red[800]!],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deletePayment(id);
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: isSmallScreen ? 15 : 16,
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
          ),
        );
      },
    );
  }
}

// Custom Wave Clipper for Header
class WaveClipper extends CustomClipper<Path> {
  final double animation;

  WaveClipper(this.animation);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);

    final firstControlPoint = Offset(
      size.width / 4,
      size.height - 30 + 20 * math.sin(animation * 2 * math.pi),
    );
    final firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(
      size.width * 3 / 4,
      size.height - 30 - 20 * math.sin(animation * 2 * math.pi),
    );
    final secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => true;
}

// Particle class for background animation
class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}

// Custom Painter for Floating Particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position
      particle.y = (particle.y - particle.speed * 0.01) % 1.0;

      final paint =
          Paint()
            ..color = particle.color
            ..style = PaintingStyle.fill;

      final offset = Offset(
        particle.x * size.width +
            math.sin(animation * 2 * math.pi + particle.y * 10) * 20,
        particle.y * size.height,
      );

      canvas.drawCircle(offset, particle.size, paint);

      // Draw glow effect
      final glowPaint =
          Paint()
            ..color = particle.color.withOpacity(0.1)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(offset, particle.size * 3, glowPaint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
