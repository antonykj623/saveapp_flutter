import 'dart:math' as math;
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/view/home/dream_page/dream_class/db_class.dart';
import 'package:new_project_2025/view/home/widget/DTH_screen/DTHScreen.dart';
import 'package:new_project_2025/view/home/widget/DTH_screen/d_t_h_recharge_dashboard.dart';
import 'package:new_project_2025/view/home/widget/More_page/More_page.dart';
import 'package:new_project_2025/view/home/widget/carousel_slider/caroselSlider.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/addinsurance.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/insurancelistpage.dart';
import 'package:new_project_2025/view/home/widget/password_manger/password_manger/password_list_screen/Edit_password/Edit_password_screen.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/Recharge_screen.dart';
import 'package:new_project_2025/view/home/widget/report_screen/My_net_worth/my_net_worth.dart';
import 'package:new_project_2025/view/home/widget/setting_page/backup_and%20_restore/ex_re.dart';
import 'package:new_project_2025/view_model/Accountfiles/CashAccount.dart';
import 'package:new_project_2025/view_model/Task/createtask.dart';
import 'package:new_project_2025/view_model/Task/tasklist.dart';
import 'package:new_project_2025/view_model/assets/AssetListPage.dart';
import 'package:new_project_2025/view_model/liability_lists/liabilitylist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:new_project_2025/view/home/widget/Notification_page.dart';
import 'package:new_project_2025/view/home/widget/setting_page/setting_page.dart'
    show SettingsScreen;
import 'package:new_project_2025/view/home/widget/payment_page/payhment_page.dart';
import 'package:new_project_2025/view/home/widget/Receipt/Receipt_screen.dart';
import 'package:new_project_2025/view/home/widget/wallet_page/wallet_page.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Main_budget_screen.dart';
import 'package:new_project_2025/view/home/widget/Bank/bank_page/Bank_page.dart';
import 'package:new_project_2025/view/home/widget/report_screen/report_screen.dart';
import 'package:new_project_2025/view_model/Accountfiles/ExpenseAccount.dart';
import 'package:new_project_2025/view_model/Accountfiles/IncomeAccount.dart';
import 'package:new_project_2025/view_model/Accountfiles/InvestmentAccount.dart';
import 'package:new_project_2025/view_model/AccountSet_up/accountsetup.dart';
import 'package:new_project_2025/view_model/Billing/blling.dart';
import 'package:new_project_2025/view_model/CashBank/cashBank.dart';
import 'package:new_project_2025/view_model/Journal/journal.dart';
import 'package:new_project_2025/view_model/investment11/investment.dart';
import 'package:new_project_2025/view_model/DocumentManager/documentManager.dart';
import 'package:new_project_2025/view_model/My Diary/diary.dart';
import 'package:new_project_2025/view_model/Task/task.dart';
import 'package:new_project_2025/view_model/VisitingCard/visitingcard.dart';
import 'package:new_project_2025/view_model/Liabilities/listofLiabilities.dart';
import 'package:new_project_2025/view/home/widget/investment/Assetdetails_page/assets_details_screen.dart';
import 'package:new_project_2025/view/home/widget/website_link_page/Website_link_page.dart';
import 'package:new_project_2025/view/home/widget/Emergency_numbers_screen/Emergency_screen.dart';
import 'package:new_project_2025/view/home/dream_page/dream_main_page/dream_page_main.dart';
import 'package:new_project_2025/view_model/VisitingCard/your businessCard.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SaveApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SaveApp extends StatefulWidget {
  const SaveApp({Key? key}) : super(key: key);

  @override
  State<SaveApp> createState() => _SaveAppState();
}

class _SaveAppState extends State<SaveApp> with TickerProviderStateMixin {
  late AnimationController _networthPulseController;
  late Animation<double> _networthPulseAnimation;
  late NotchBottomBarController _notchController;
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  String selectedYear = '2025';
  final List<String> years = ['2023', '2024', '2025', '2026'];
  bool isDarkTheme = true;
  bool _isLoadingTheme = true;

  Map<String, double> assetBalances = {};
  Map<String, double> liabilityBalances = {};
  bool isLoadingNetworth = true;

  double get totalAssets {
    try {
      if (assetBalances.isEmpty) return 0.0;

      double sum = 0.0;
      assetBalances.forEach((key, value) {
        if (value != null && !value.isNaN && !value.isInfinite) {
          sum += value;
        }
      });

      return (sum.isNaN || sum.isInfinite) ? 0.0 : sum;
    } catch (e) {
      print('Error calculating total assets: $e');
      return 0.0;
    }
  }

  double get totalLiabilities {
    try {
      if (liabilityBalances.isEmpty) return 0.0;

      double sum = 0.0;
      liabilityBalances.forEach((key, value) {
        if (value != null && !value.isNaN && !value.isInfinite) {
          sum += value;
        }
      });

      return (sum.isNaN || sum.isInfinite) ? 0.0 : sum;
    } catch (e) {
      print('Error calculating total liabilities: $e');
      return 0.0;
    }
  }

  double get networth {
    try {
      final assets = totalAssets;
      final liabilities = totalLiabilities;

      if (assets.isNaN || assets.isInfinite) return 0.0;
      if (liabilities.isNaN || liabilities.isInfinite) return 0.0;

      final net = assets - liabilities;
      return (net.isNaN || net.isInfinite) ? 0.0 : net;
    } catch (e) {
      print('Error calculating networth: $e');
      return 0.0;
    }
  }

  Future<void> _initializeUserInitialDate() async {
    final prefs = await SharedPreferences.getInstance();

    // Optional: Only call once per user or if not set
    bool hasSyncedInitialDate =
        prefs.getBool('has_synced_initial_date') ?? false;
    if (hasSyncedInitialDate) {
      print("Initial date already synced. Skipping API call.");
      return;
    }

    try {
      // Example: Set initial date to 1st April of current financial year (India)
      DateTime now = DateTime.now();
      int year = now.month >= 4 ? now.year : now.year - 1;
      String initialDate = "01-04-$year"; // Format: DD-MM-YYYY

      final result = await ApiHelper().updateInitialDate(
        initialDate: initialDate,
      );

      if (result['status'] == 1 || result['success'] == true) {
        await prefs.setBool('has_synced_initial_date', true);
        print("Initial date synced successfully: $initialDate");

        // Optional: Show a subtle toast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Financial year setup completed!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        print("API Warning: ${result['message']}");
      }
    } catch (e) {
      print("Failed to sync initial date: $e");
      // Don't block app if API fails — it's not critical
    }
  }

  Future<void> _loadNetworthBalances() async {
    try {
      final List<String> assetTypes = [
        'Cash',
        'Bank',
        'Asset Account',
        'Investment',
        'Customers',
      ];
      final List<String> liabilityTypes = [
        'Liability Account',
        'Credit Card',
        'Suppliers',
      ];

      final accounts = await DatabaseHelper().getAllData(
        'TABLE_ACCOUNTSETTINGS',
      );
      Map<String, double> assets = {};
      Map<String, double> liabilities = {};

      for (String liabilityType in liabilityTypes) {
        liabilities[liabilityType] = 0.0;
      }

      for (var account in accounts) {
        try {
          String dataString = account['data']?.toString() ?? '{}';
          Map<String, dynamic> data = jsonDecode(dataString);
          String accountType = data['Accounttype']?.toString() ?? '';
          double openingBalance =
              double.tryParse(data['balance']?.toString() ?? '0') ?? 0.0;

          if (assetTypes.contains(accountType)) {
            assets[accountType] = (assets[accountType] ?? 0.0) + openingBalance;
          } else if (liabilityTypes.contains(accountType)) {
            liabilities[accountType] =
                (liabilities[accountType] ?? 0.0) + openingBalance;
          }
        } catch (e) {
          print('Error parsing account: $e');
        }
      }

      final transactions = await DatabaseHelper().getAllData('TABLE_ACCOUNTS');

      for (var transaction in transactions) {
        try {
          String setupId = transaction['ACCOUNTS_setupid']?.toString() ?? '';
          double amount =
              double.tryParse(
                transaction['ACCOUNTS_amount']?.toString() ?? '0',
              ) ??
              0.0;
          String type =
              transaction['ACCOUNTS_type']?.toString().toLowerCase() ?? '';
          String accountType = await _getAccountTypeFromSetupId(setupId);

          if (accountType.isEmpty) continue;

          if (assetTypes.contains(accountType)) {
            if (type == 'debit') {
              assets[accountType] = (assets[accountType] ?? 0.0) + amount;
            } else if (type == 'credit') {
              assets[accountType] = (assets[accountType] ?? 0.0) - amount;
            }
          } else if (liabilityTypes.contains(accountType)) {
            if (type == 'debit') {
              liabilities[accountType] =
                  (liabilities[accountType] ?? 0.0) - amount;
            } else if (type == 'credit') {
              liabilities[accountType] =
                  (liabilities[accountType] ?? 0.0) + amount;
            }
          }
        } catch (e) {
          print('Error parsing transaction: $e');
        }
      }

      setState(() {
        assetBalances = assets;
        liabilityBalances = liabilities;
        isLoadingNetworth = false;
        _debugNetworthValues();
      });
    } catch (e) {
      print('Error loading net worth: $e');
      setState(() {
        isLoadingNetworth = false;
      });
    }
  }

  // Real Income & Expenditure Data
  List<FinancialData> _monthlyData = [];
  bool _isLoadingChartData = false;
  Future<String> _getAccountTypeFromSetupId(String setupId) async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query(
        'TABLE_ACCOUNTSETTINGS',
        where: 'keyid = ?',
        whereArgs: [setupId],
      );

      if (result.isNotEmpty) {
        String dataString = result.first['data']?.toString() ?? '{}';
        Map<String, dynamic> data = jsonDecode(dataString);
        return data['Accounttype']?.toString() ?? '';
      }
      return '';
    } catch (e) {
      print('Error getting account type: $e');
      return '';
    }
  }

  final List<String> _carouselImages = [
    'assets/caro1.jpg',
    'assets/caro2.jpg',
    'assets/caro3.jpg',
    'assets/caro4.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _loadThemePreference().then((_) {
      _animationController.forward();
      _cardAnimationController.forward();
      _loadMonthlyIncomeExpenditure();
      _loadNetworthBalances(); // Add this line
    });
    _initializeUserInitialDate();
    _networthPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _networthPulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _networthPulseController,
        curve: Curves.easeInOut,
      ),
    );
    _pageController = PageController(initialPage: 0);
    _notchController = NotchBottomBarController(index: 0);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.bounceOut,
      ),
    );

    _loadThemePreference().then((_) {
      _animationController.forward();
      _cardAnimationController.forward();
      _loadMonthlyIncomeExpenditure(); // Load real data
    });

    ExpenseAccountHelper.insertExpenseAccounts();
    IncomeAccount.addIncomeAccount();
    CashAccountHelper.insertDefaultAccounts();
    InvestmentAccount.insertInvestmentAccount();
    TargetCategoryService.addDefaultTargetCategories();
  }

  // Load real Income & Expenditure data month-wise for the selected year
  Future<void> _loadMonthlyIncomeExpenditure() async {
    setState(() {
      _isLoadingChartData = true;
    });

    try {
      final db = await DatabaseHelper().database;
      final accounts = await db.query('TABLE_ACCOUNTSETTINGS');

      // Initialize monthly data for 12 months
      Map<int, double> monthlyIncome = {};
      Map<int, double> monthlyExpenditure = {};

      for (int i = 1; i <= 12; i++) {
        monthlyIncome[i] = 0;
        monthlyExpenditure[i] = 0;
      }

      int year = int.parse(selectedYear);

      for (var account in accounts) {
        final data = account['data'];
        if (data is String) {
          Map<String, dynamic> accountData = jsonDecode(data);
          String accountType =
              accountData['Accounttype'].toString().toLowerCase();

          if (accountType != 'income account' &&
              accountType != 'expense account') {
            continue;
          }

          final transactions = await db.rawQuery(
            '''
            SELECT * FROM TABLE_ACCOUNTS 
            WHERE ACCOUNTS_setupid = ? 
            AND ACCOUNTS_VoucherType IN (1, 2)
            ''',
            [account['keyid'].toString()],
          );

          for (var tx in transactions) {
            try {
              String dateStr = tx['ACCOUNTS_date'].toString();
              DateTime txDate = DateFormat('dd/MM/yyyy').parse(dateStr);

              // Only process transactions from selected year
              if (txDate.year != year) continue;

              int month = txDate.month;
              double amount = double.parse(tx['ACCOUNTS_amount'].toString());
              String transactionType =
                  tx['ACCOUNTS_type'].toString().toLowerCase();

              if (accountType == 'income account') {
                // Income = Credits - Debits
                if (transactionType == 'credit') {
                  monthlyIncome[month] = (monthlyIncome[month] ?? 0) + amount;
                } else if (transactionType == 'debit') {
                  monthlyIncome[month] = (monthlyIncome[month] ?? 0) - amount;
                }
              } else {
                // Expense = Debits - Credits
                if (transactionType == 'debit') {
                  monthlyExpenditure[month] =
                      (monthlyExpenditure[month] ?? 0) + amount;
                } else if (transactionType == 'credit') {
                  monthlyExpenditure[month] =
                      (monthlyExpenditure[month] ?? 0) - amount;
                }
              }
            } catch (e) {
              print('Error parsing transaction: $e');
            }
          }
        }
      }

      // Create chart data
      List<FinancialData> chartData = [];
      List<String> monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      for (int i = 1; i <= 12; i++) {
        chartData.add(
          FinancialData(
            monthNames[i - 1],
            monthlyIncome[i] ?? 0,
            monthlyExpenditure[i] ?? 0,
          ),
        );
      }

      setState(() {
        _monthlyData = chartData;
        _isLoadingChartData = false;
      });

      print('Chart data loaded for year $selectedYear');
    } catch (e) {
      print('Error loading monthly income/expenditure: $e');
      setState(() {
        _isLoadingChartData = false;
      });
    }
  }

  @override
  void dispose() {
    _networthPulseController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    _cardAnimationController.dispose();
    _notchController.dispose();
    super.dispose();
  }

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
      _notchController.index = index;
    });
  }

  Future<void> _saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_preferred_theme', isDark);
      debugPrint('Theme saved: ${isDark ? "Dark" : "Light"}');
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool? savedTheme = prefs.getBool('user_preferred_theme');

      setState(() {
        isDarkTheme = savedTheme ?? true;
        _isLoadingTheme = false;
      });

      debugPrint('Theme loaded: ${isDarkTheme ? "Dark" : "Light"}');
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
      setState(() {
        isDarkTheme = true;
        _isLoadingTheme = false;
      });
    }
  }

  void _toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
    _saveThemePreference(isDarkTheme);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Theme changed to ${isDarkTheme ? "Dark" : "Light"} mode',
        ),
        backgroundColor: isDarkTheme ? Colors.grey[800] : Colors.teal,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showChartDialog() {
    HapticFeedback.mediumImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: _buildChartDialogContent(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworthCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _networthPulseAnimation]),
      builder: (context, child) {
        // Clamp scale value to prevent issues
        final safeScale = _scaleAnimation.value.clamp(0.0, 2.0);

        return Transform.scale(
          scale: safeScale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: (isDarkTheme
                          ? const Color(0xFF2C5F8D)
                          : const Color(0xFF1976D2))
                      .withOpacity(
                        0.3 * _networthPulseAnimation.value.clamp(0.0, 1.0),
                      ),
                  blurRadius:
                      25 * _networthPulseAnimation.value.clamp(0.0, 1.0),
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Enhanced gradient background
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isDarkTheme
                                ? [
                                  const Color(0xFF1A237E),
                                  const Color(0xFF283593),
                                  const Color(0xFF3949AB),
                                ]
                                : [
                                  const Color(0xFFE3F2FD),
                                  const Color(0xFFBBDEFB),
                                  const Color(0xFF90CAF9),
                                ],
                      ),
                    ),
                  ),

                  // Animated pattern overlay
                  Positioned.fill(
                    child: CustomPaint(
                      painter: NetworthPatternPainter(
                        isDarkTheme: isDarkTheme,
                        animation: _networthPulseAnimation.value.clamp(
                          0.0,
                          1.0,
                        ),
                      ),
                    ),
                  ),

                  // Shimmer effect - FIXED
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: -2.0, end: 2.0),
                      duration: const Duration(milliseconds: 3000),
                      builder: (context, value, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Transform.translate(
                            offset: Offset(value * 250, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.15),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        if (mounted) {
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted) setState(() {});
                          });
                        }
                      },
                    ),
                  ),

                  // Main content
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyNetworthScreen(),
                          ),
                        ).then((_) {
                          if (mounted) {
                            _loadNetworthBalances();
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(24),
                      splashColor: Colors.white.withOpacity(0.1),
                      highlightColor: Colors.white.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Animated icon - FIXED
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 1800),
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) {
                                    // Clamp all animation values
                                    final safeValue = value.clamp(0.0, 1.0);

                                    return Transform.rotate(
                                      angle: safeValue * 6.28,
                                      child: Transform.scale(
                                        scale: 0.85 + (0.15 * safeValue),
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors:
                                                  isDarkTheme
                                                      ? [
                                                        Colors.white
                                                            .withOpacity(0.25),
                                                        Colors.white
                                                            .withOpacity(0.15),
                                                      ]
                                                      : [
                                                        const Color(
                                                          0xFF1976D2,
                                                        ).withOpacity(0.2),
                                                        const Color(
                                                          0xFF1976D2,
                                                        ).withOpacity(0.1),
                                                      ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isDarkTheme
                                                        ? Colors.white
                                                        : const Color(
                                                          0xFF1976D2,
                                                        ))
                                                    .withOpacity(0.3),
                                                blurRadius:
                                                    12 *
                                                    _networthPulseAnimation
                                                        .value
                                                        .clamp(0.0, 1.0),
                                                spreadRadius:
                                                    3 *
                                                    (_networthPulseAnimation
                                                                .value
                                                                .clamp(
                                                                  0.0,
                                                                  1.0,
                                                                ) -
                                                            1)
                                                        .abs(),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            color:
                                                isDarkTheme
                                                    ? Colors.white
                                                    : const Color(0xFF1976D2),
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // View Details button - FIXED
                                Flexible(
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    curve: Curves.easeOutBack,
                                    builder: (context, value, child) {
                                      final safeValue = value.clamp(0.0, 1.0);

                                      return Transform.translate(
                                        offset: Offset(30 * (1 - safeValue), 0),
                                        child: Opacity(
                                          opacity: safeValue,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors:
                                                    isDarkTheme
                                                        ? [
                                                          Colors.white
                                                              .withOpacity(
                                                                0.25,
                                                              ),
                                                          Colors.white
                                                              .withOpacity(
                                                                0.15,
                                                              ),
                                                        ]
                                                        : [
                                                          const Color(
                                                            0xFF1976D2,
                                                          ).withOpacity(0.2),
                                                          const Color(
                                                            0xFF1976D2,
                                                          ).withOpacity(0.1),
                                                        ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              border: Border.all(
                                                color: (isDarkTheme
                                                        ? Colors.white
                                                        : const Color(
                                                          0xFF1976D2,
                                                        ))
                                                    .withOpacity(0.3),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'View Details',
                                                    style: TextStyle(
                                                      color:
                                                          isDarkTheme
                                                              ? Colors.white
                                                              : const Color(
                                                                0xFF1976D2,
                                                              ),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.3,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color:
                                                      isDarkTheme
                                                          ? Colors.white
                                                          : const Color(
                                                            0xFF1976D2,
                                                          ),
                                                  size: 14,
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
                            const SizedBox(height: 24),

                            // Title - FIXED
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) {
                                final safeValue = value.clamp(0.0, 1.0);

                                return Opacity(
                                  opacity: safeValue,
                                  child: Transform.translate(
                                    offset: Offset(0, 15 * (1 - safeValue)),
                                    child: Text(
                                      'My NetWorth',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            isDarkTheme
                                                ? Colors.white.withOpacity(0.9)
                                                : const Color(0xFF1565C0),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),

                            // Net Worth Value - FIXED
                            isLoadingNetworth
                                ? Container(
                                  height: 50,
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isDarkTheme
                                            ? Colors.white
                                            : const Color(0xFF1976D2),
                                      ),
                                    ),
                                  ),
                                )
                                : LayoutBuilder(
                                  builder: (context, constraints) {
                                    final safeNetworth =
                                        (networth.isNaN || networth.isInfinite)
                                            ? 0.0
                                            : networth;

                                    return TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        begin: 0.0,
                                        end: safeNetworth,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 2000,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) {
                                        final displayValue =
                                            (value.isNaN || value.isInfinite)
                                                ? 0.0
                                                : value;

                                        String formattedValue =
                                            '₹${displayValue.toStringAsFixed(2)}';

                                        double fontSize = 38;
                                        if (formattedValue.length > 15) {
                                          fontSize = 28;
                                        } else if (formattedValue.length > 12) {
                                          fontSize = 32;
                                        }

                                        return SizedBox(
                                          width: constraints.maxWidth,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: ShaderMask(
                                              shaderCallback:
                                                  (bounds) => LinearGradient(
                                                    colors:
                                                        isDarkTheme
                                                            ? [
                                                              Colors.white,
                                                              Colors.white
                                                                  .withOpacity(
                                                                    0.9,
                                                                  ),
                                                            ]
                                                            : [
                                                              const Color(
                                                                0xFF0D47A1,
                                                              ),
                                                              const Color(
                                                                0xFF1976D2,
                                                              ),
                                                            ],
                                                  ).createShader(bounds),
                                              child: Text(
                                                formattedValue,
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 1.2,
                                                  height: 1.2,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),

                            const SizedBox(height: 20),

                            // Assets and Liabilities Row
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      child: _buildNetworthItem(
                                        'Assets',
                                        totalAssets,
                                        Colors.green,
                                        Icons.trending_up_rounded,
                                        true,
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 60,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            (isDarkTheme
                                                    ? Colors.white
                                                    : const Color(0xFF1976D2))
                                                .withOpacity(0.1),
                                            (isDarkTheme
                                                    ? Colors.white
                                                    : const Color(0xFF1976D2))
                                                .withOpacity(0.3),
                                            (isDarkTheme
                                                    ? Colors.white
                                                    : const Color(0xFF1976D2))
                                                .withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 110,
                                      child: _buildNetworthItem(
                                        'Liabilities',
                                        totalLiabilities,
                                        Colors.red,
                                        Icons.trending_down_rounded,
                                        false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildNetworthItem(
    String label,
    double amount,
    Color color,
    IconData icon,
    bool isLeft,
  ) {
    final safeAmount =
        (amount == null || amount.isNaN || amount.isInfinite) ? 0.0 : amount;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Clamp animation value
        final safeValue = value.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(
            isLeft ? -40 * (1 - safeValue) : 40 * (1 - safeValue),
            0,
          ),
          child: Opacity(
            opacity: safeValue,
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment:
                    isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon and Label Row
                  SizedBox(
                    width: 110,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment:
                          isLeft
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                      children: [
                        AnimatedBuilder(
                          animation: _networthPulseAnimation,
                          builder: (context, child) {
                            final pulseValue = _networthPulseAnimation.value
                                .clamp(0.0, 1.0);

                            return Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8 * pulseValue,
                                    spreadRadius: 1 * (pulseValue - 1).abs(),
                                  ),
                                ],
                              ),
                              child: Icon(icon, color: color, size: 12),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkTheme
                                      ? Colors.white.withOpacity(0.85)
                                      : const Color(0xFF424242),
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Amount Container
                  SizedBox(
                    width: 110,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: safeAmount),
                      duration: const Duration(milliseconds: 2000),
                      curve: Curves.easeOutCubic,
                      builder: (context, animValue, child) {
                        final displayValue =
                            (animValue == null ||
                                    animValue.isNaN ||
                                    animValue.isInfinite)
                                ? 0.0
                                : animValue;

                        String formattedAmount;
                        try {
                          formattedAmount =
                              '₹${displayValue.toStringAsFixed(2)}';
                        } catch (e) {
                          formattedAmount = '₹0.00';
                        }

                        double fontSize = 11;
                        int length = formattedAmount.length;
                        if (length <= 8) {
                          fontSize = 14;
                        } else if (length <= 10) {
                          fontSize = 13;
                        } else if (length <= 12) {
                          fontSize = 12;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  isDarkTheme
                                      ? [
                                        Colors.white.withOpacity(0.15),
                                        Colors.white.withOpacity(0.08),
                                      ]
                                      : [
                                        Colors.white.withOpacity(0.9),
                                        Colors.white.withOpacity(0.7),
                                      ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isDarkTheme
                                      ? Colors.white.withOpacity(0.2)
                                      : color.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formattedAmount,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      isDarkTheme
                                          ? Colors.white
                                          : const Color(0xFF1565C0),
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  Widget _buildChartDialogContent(BuildContext context) {
    // Calculate totals from real data
    double totalIncome = 0;
    double totalExpenditure = 0;

    for (var data in _monthlyData) {
      totalIncome += data.income;
      totalExpenditure += data.expense;
    }

    double netProfitLoss = totalIncome - totalExpenditure;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDarkTheme ? Colors.grey.shade800 : Colors.white,
            isDarkTheme ? Colors.grey.shade900 : Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF008080).withOpacity(0.8),
                  const Color(0xFF20B2AA).withOpacity(0.6),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Financial Analytics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Income vs Expenditure',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedYear,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 16,
                              ),
                              dropdownColor: const Color(0xFF008080),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedYear = newValue;
                                  });
                                  Navigator.of(context).pop();
                                  _loadMonthlyIncomeExpenditure();
                                  Future.delayed(
                                    Duration(milliseconds: 300),
                                    () {
                                      _showChartDialog();
                                    },
                                  );
                                }
                              },
                              items:
                                  years.map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.all(6),
                            constraints: BoxConstraints(),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Income',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totalIncome.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.purple.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Expense',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totalExpenditure.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Net Profit/Loss
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    netProfitLoss >= 0
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      netProfitLoss >= 0
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    netProfitLoss >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: netProfitLoss >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${netProfitLoss >= 0 ? "Profit" : "Loss"}: ₹${netProfitLoss.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: netProfitLoss >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  _isLoadingChartData
                      ? Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFF008080),
                        ),
                      )
                      : Container(
                        decoration: BoxDecoration(
                          color:
                              isDarkTheme ? Colors.grey.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SfCartesianChart(
                            plotAreaBorderWidth: 0,
                            primaryXAxis: CategoryAxis(
                              majorGridLines: const MajorGridLines(width: 0),
                              axisLine: const AxisLine(width: 0),
                              labelStyle: TextStyle(
                                color:
                                    isDarkTheme
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            primaryYAxis: NumericAxis(
                              numberFormat: NumberFormat.compact(),
                              majorGridLines: MajorGridLines(
                                width: 0.5,
                                color:
                                    isDarkTheme
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade200,
                              ),
                              axisLine: const AxisLine(width: 0),
                              labelStyle: TextStyle(
                                color:
                                    isDarkTheme
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            legend: Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CartesianSeries<FinancialData, String>>[
                              ColumnSeries<FinancialData, String>(
                                name: 'Income',
                                dataSource: _monthlyData,
                                xValueMapper:
                                    (FinancialData data, _) => data.month,
                                yValueMapper:
                                    (FinancialData data, _) => data.income,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF81C784),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 0.4,
                                spacing: 0.1,
                                borderRadius: BorderRadius.circular(8),
                                animationDuration: 2000,
                                enableTooltip: true,
                              ),
                              ColumnSeries<FinancialData, String>(
                                name: 'Expense',
                                dataSource: _monthlyData,
                                xValueMapper:
                                    (FinancialData data, _) => data.month,
                                yValueMapper:
                                    (FinancialData data, _) => data.expense,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF9C27B0),
                                    Color(0xFFBA68C8),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 0.4,
                                spacing: 0.1,
                                borderRadius: BorderRadius.circular(8),
                                animationDuration: 2000,
                                enableTooltip: true,
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkTheme ? Colors.grey.shade900 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Year: $selectedYear',
                      style: TextStyle(
                        color:
                            isDarkTheme
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time data from your accounts',
                      style: TextStyle(
                        color:
                            isDarkTheme
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isDarkTheme
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF008080), Color(0xFF20B2AA)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF008080).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Chart data refreshed successfully!',
                              ),
                              backgroundColor: const Color(0xFF008080),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.of(context).pop();
                          _loadMonthlyIncomeExpenditure();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Refresh',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTheme) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF00897B), Color(0xFF00796B)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDarkTheme ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDarkTheme
                      ? [
                        const Color(0xFF0A0A0A),
                        const Color(0xFF1A1A1A),
                        const Color(0xFF0A0A0A),
                      ]
                      : [
                        const Color(0xFFF5F5F5),
                        const Color(0xFFE0ECEC),
                        const Color(0xFFF5F5F5),
                      ],
            ),
          ),
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildHomePage(), ReportScreen(), More()],
                ),
              ),
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.6, 1.0],
          colors:
              isDarkTheme
                  ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                    const Color(0xFF533483),
                  ]
                  : [
                    const Color(0xFFE3FDFD),
                    const Color(0xFFCBF1F5),
                    const Color(0xFFA6E3E9),
                    const Color(0xFF71C9CE),
                  ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDarkTheme
                    ? const Color(0xFF533483).withOpacity(0.3)
                    : const Color(0xFF71C9CE).withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color:
                isDarkTheme
                    ? Colors.black.withOpacity(0.2)
                    : Colors.white.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 12.0,
        right: 12.0,
        bottom: 12.0,
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAnimatedLogo(),
                  const SizedBox(width: 8),
                  Expanded(child: _buildAnimatedTitle()),
                  _buildActionButtons(),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEnhancedButton(Icons.notifications_none_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationScreen()),
          );
        }, const Color(0xFFFF6B6B)),
        const SizedBox(width: 4),
        _buildEnhancedButton(Icons.settings_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
        }, const Color(0xFF4ECDC4)),
        const SizedBox(width: 4),
        _buildThemeToggleButton(),
      ],
    );
  }

  Widget _buildEnhancedButton(
    IconData icon,
    VoidCallback onPressed,
    Color accentColor,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: GestureDetector(
            onTapDown: (_) => HapticFeedback.lightImpact(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
                maxWidth: 36,
                maxHeight: 36,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withOpacity(0.2),
                    accentColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Icon(icon, color: accentColor, size: 16),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeToggleButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: GestureDetector(
            onTapDown: (_) => HapticFeedback.mediumImpact(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
                maxWidth: 36,
                maxHeight: 36,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDarkTheme
                          ? [
                            const Color(0xFFFFA726).withOpacity(0.3),
                            const Color(0xFFFF7043).withOpacity(0.2),
                          ]
                          : [
                            const Color(0xFF3F51B5).withOpacity(0.3),
                            const Color(0xFF9C27B0).withOpacity(0.2),
                          ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDarkTheme
                          ? const Color(0xFFFFA726).withOpacity(0.4)
                          : const Color(0xFF3F51B5).withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDarkTheme
                            ? const Color(0xFFFFA726).withOpacity(0.3)
                            : const Color(0xFF3F51B5).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    _toggleTheme();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child: child,
                        );
                      },
                      child: Icon(
                        isDarkTheme
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        key: ValueKey(isDarkTheme),
                        color:
                            isDarkTheme
                                ? const Color(0xFFFFA726)
                                : const Color(0xFF3F51B5),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2000),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDarkTheme
                          ? [
                            const Color(0xFFFF6B6B),
                            const Color(0xFF4ECDC4),
                            const Color(0xFF45B7D1),
                          ]
                          : [
                            const Color(0xFF667EEA),
                            const Color(0xFF764BA2),
                            const Color(0xFFF093FB),
                          ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDarkTheme
                            ? const Color(0xFF4ECDC4).withOpacity(0.4)
                            : const Color(0xFF667EEA).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 3000),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, ringValue, child) {
                      return Container(
                        width: 32 + (8 * math.sin(ringValue * 6.28)),
                        height: 32 + (8 * math.sin(ringValue * 6.28)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/appicon.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                          size: 24,
                        );
                      },
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

  Widget _buildAnimatedTitle() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors:
                            isDarkTheme
                                ? [Colors.white, const Color(0xFF4ECDC4)]
                                : [
                                  const Color(0xFF667EEA),
                                  const Color(0xFF764BA2),
                                ],
                      ).createShader(bounds),
                  child: Text(
                    'My Personal App',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your financial companion',
                  style: TextStyle(
                    color:
                        isDarkTheme
                            ? Colors.white.withOpacity(0.8)
                            : const Color(0xFF667EEA).withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomePage() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCarouselSlider(),
                  const SizedBox(height: 20),
                  _buildNetworthCard(),
                  const SizedBox(height: 10),
                  _buildSectionHeader('💰 My Money'),
                  _buildCategoryGrid(_moneyCategories),

                  // Add Net Worth Card here (after My Money section)
                  // const SizedBox(height: 10),
                  // _buildNetworthCard(),
                  _buildSectionHeader('🏠 My Belongings'),
                  _buildCategoryGrid(_belongingsCategories),
                  _buildSectionHeader('✨ My Life'),
                  _buildCategoryGrid(_lifeCategories),
                  _buildSectionHeader('🔧 Utilities'),
                  _buildCategoryGrid(_utilitiesCategories),
                  _buildSectionHeader('🎯 Financial Analytics'),
                  _buildChartButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarouselSlider() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ModernCarouselSlider(
        images: _carouselImages,
        isDarkTheme: isDarkTheme,
      ),
    );
  }

  Widget _buildChartButton() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Hero(
            tag: 'chart-button',
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF008080),
                    Color(0xFF20B2AA),
                    Color(0xFF008080),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF008080).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showChartDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.analytics,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Financial Analytics',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'View real-time income & expense data',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _debugNetworthValues() {
    print('=== NetWorth Debug ===');
    print('Asset Balances: $assetBalances');
    print('Liability Balances: $liabilityBalances');
    print(
      'Total Assets: $totalAssets (isNaN: ${totalAssets.isNaN}, isInfinite: ${totalAssets.isInfinite})',
    );
    print(
      'Total Liabilities: $totalLiabilities (isNaN: ${totalLiabilities.isNaN}, isInfinite: ${totalLiabilities.isInfinite})',
    );
    print(
      'NetWorth: $networth (isNaN: ${networth.isNaN}, isInfinite: ${networth.isInfinite})',
    );
    print('==================');
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDarkTheme ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<CategoryItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDarkTheme
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () {
              if (item.onPressed != null) {
                item.onPressed!(context);
              } else {
                debugPrint('${item.label} tapped');
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: item.iconColor, size: 40),
                const SizedBox(height: 5),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color:
                isDarkTheme
                    ? Colors.black.withOpacity(0.25)
                    : Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    isDarkTheme
                        ? [
                          const Color(0xFF1E1E2E).withOpacity(0.95),
                          const Color(0xFF16213E).withOpacity(0.9),
                        ]
                        : [
                          Colors.white.withOpacity(0.95),
                          const Color(0xFFF8F9FA).withOpacity(0.9),
                        ],
              ),
              border: Border.all(
                color:
                    isDarkTheme
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavItem(
                    0,
                    Icons.home_rounded,
                    'Home',
                    const Color(0xFF4FC3F7),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    1,
                    Icons.trending_up_rounded,
                    'Reports',
                    const Color(0xFF66BB6A),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    2,
                    Icons.explore_rounded,
                    'More',
                    const Color(0xFFFF7043),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color primaryColor,
  ) {
    bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _changePage(index);
      },
      child: Container(
        height: 65,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient:
                isActive
                    ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor.withOpacity(0.8),
                        primaryColor.withOpacity(0.6),
                      ],
                    )
                    : null,
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: isActive ? 24 : 22,
                  color:
                      isActive
                          ? Colors.white
                          : isDarkTheme
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isActive ? 10 : 9,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isActive
                            ? Colors.white
                            : isDarkTheme
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<CategoryItem> _moneyCategories = [
    CategoryItem(
      icon: Icons.credit_card,
      label: 'Payments',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentsPage()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.receipt,
      label: 'Receipts',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReceiptsPage()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.account_balance_wallet,
      label: 'Wallet',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WalletPage()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.business_center,
      label: 'Budget',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BudgetScreen()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.account_balance,
      label: 'Bank',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BankVoucherListScreen()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.book,
      label: 'Journal',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Journal()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.description,
      label: 'Billing',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Billing()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.monetization_on,
      label: 'Cash and Bank',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Cashbank()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.calculate,
      label: 'Account Setup',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Accountsetup()),
        );
      },
    ),
  ];

  final List<CategoryItem> _belongingsCategories = [
    CategoryItem(
      icon: Icons.trending_up,
      label: 'Investment',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Investment()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.lock,
      label: 'Password Manager',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => listpasswordData()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.description,
      label: 'Document Manager',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Documentmanager()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.account_balance_wallet,
      label: 'Asset',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AssetListPage()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.note_alt,
      label: 'Liability',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LiabilityListPage()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.security,
      label: 'Insurance',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InsuranceListPage()),
        );
      },
    ),
  ];

  final List<CategoryItem> _lifeCategories = [
    CategoryItem(
      icon: Icons.task_alt,
      label: 'Task',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskListPage()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.book,
      label: 'Diary',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Diary()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.add_circle_outline,
      label: 'Dream',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyDreamScreen()),
        );
      },
    ),
  ];

  final List<CategoryItem> _utilitiesCategories = [
    CategoryItem(
      icon: Icons.smartphone,
      label: 'Mobile Recharge',
      iconColor: Colors.teal,
      onPressed:
          (BuildContext context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MobileRechargeScreen()),
          ),
    ),
    CategoryItem(
      icon: Icons.satellite_alt,
      label: 'DTH Recharge',
      iconColor: Colors.teal,
      onPressed:
          (BuildContext context) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DTHRechargeDashboard()),
          ),
    ),
    CategoryItem(
      icon: Icons.contact_mail,
      label: 'Visiting Card',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddVisitingCard()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.link,
      label: 'Website Links',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WebLinksListPage()),
        );
      },
    ),
    CategoryItem(
      icon: Icons.warning,
      label: 'Emergency Numbers',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmergencyNumbersScreen()),
        );
      },
    ),
  ];
}

class CategoryItem {
  final IconData icon;
  final String label;
  final Color iconColor;
  final void Function(BuildContext context)? onPressed;

  CategoryItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.onPressed,
  });
}

class FinancialData {
  final String month;
  final double income;
  final double expense;

  FinancialData(this.month, this.income, this.expense);
}
