import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:new_project_2025/view/home/dream_page/dream_class/db_class.dart';
import 'package:new_project_2025/view/home/widget/DTH_screen/DTHScreen.dart';
import 'package:new_project_2025/view/home/widget/DTH_screen/d_t_h_recharge_dashboard.dart';
import 'package:new_project_2025/view/home/widget/More_page/More_page.dart';
import 'package:new_project_2025/view/home/widget/carousel_slider/caroselSlider.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/addinsurance.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/insurancelistpage.dart';
import 'package:new_project_2025/view/home/widget/password_manger/password_manger/password_list_screen/Edit_password/Edit_password_screen.dart';
import 'package:new_project_2025/view/home/widget/payment_recharge/Recharge_screen.dart';
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  bool isDarkTheme = true; // Default theme
  bool _isLoadingTheme = true; // Add loading state for theme

  final List<String> _carouselImages = [
    'assets/caro1.jpg',
    'assets/caro2.jpg',
    'assets/caro3.jpg',
    'assets/caro4.jpg',
  ];

  @override
  void initState() {
    super.initState();
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

    // Load theme preference FIRST before starting animations
    _loadThemePreference().then((_) {
      _animationController.forward();
      _cardAnimationController.forward();
    });

    // Initialize services
    ExpenseAccountHelper.insertExpenseAccounts();
    IncomeAccount.addIncomeAccount();
    CashAccountHelper.insertCashAccount();
    InvestmentAccount.insertInvestmentAccount();
    TargetCategoryService.addDefaultTargetCategories();
  }

  @override
  void dispose() {
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

  /// Save theme preference to SharedPreferences with unique key to persist across sessions
  Future<void> _saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_preferred_theme', isDark);
      debugPrint('Theme saved: ${isDark ? "Dark" : "Light"}');
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Load theme preference from SharedPreferences
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
        isDarkTheme = true; // Fallback to dark theme
        _isLoadingTheme = false;
      });
    }
  }

  /// Toggle theme and save preference
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

  Widget _buildChartDialogContent(BuildContext context) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Analytics',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Income vs Expenditure',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
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
                          ),
                          dropdownColor: const Color(0xFF008080),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedYear = newValue;
                              });
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
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.grey.shade800 : Colors.white,
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
                      minimum: 0,
                      maximum: 4000,
                      interval: 500,
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
                        dataSource: getChartData(),
                        xValueMapper: (FinancialData data, _) => data.month,
                        yValueMapper: (FinancialData data, _) => data.income,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
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
                        dataSource: getChartData(),
                        xValueMapper: (FinancialData data, _) => data.month,
                        yValueMapper: (FinancialData data, _) => data.expense,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
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
                      'Currency: USD',
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
                      'Last updated: May 2025',
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
                                'Chart exported successfully!',
                              ),
                              backgroundColor: const Color(0xFF008080),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.of(context).pop();
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
                          'Export',
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
                  _buildSectionHeader('💰 My Money'),
                  _buildCategoryGrid(_moneyCategories),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Financial Analytics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'View detailed charts and insights',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
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

  List<FinancialData> getChartData() {
    return [
      FinancialData('Jan', 2800, 2200),
      FinancialData('Feb', 3200, 2800),
      FinancialData('Mar', 2600, 2400),
      FinancialData('Apr', 3400, 3000),
      FinancialData('May', 2500, 3600),
      FinancialData('Jun', 3600, 2900),
      FinancialData('Jul', 3800, 3200),
      FinancialData('Aug', 3200, 2800),
      FinancialData('Sep', 2900, 2600),
      FinancialData('Oct', 3500, 3100),
      FinancialData('Nov', 3300, 2900),
      FinancialData('Dec', 3700, 3300),
    ];
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
