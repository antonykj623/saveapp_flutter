import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:new_project_2025/view/home/widget/insurance/insurance_database/Insurance_list_page/insurance_list_page.dart';
import 'package:new_project_2025/view_model/Accountfiles/CashAccount.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

// Placeholder imports for navigation (replace with actual paths)
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
import 'package:new_project_2025/view/home/widget/password_manger/password_list_screen/password_list_screens.dart';
import 'package:new_project_2025/view/home/widget/website_link_page/Website_link_page.dart';
import 'package:new_project_2025/view/home/widget/Emergency_numbers_screen/Emergency_screen.dart';
import 'package:new_project_2025/view/home/dream_page/dream_main_page/dream_page_main.dart';
import 'package:new_project_2025/view_model/VisitingCard/your businessCard.dart';
import 'package:new_project_2025/view/home/dream_page/dream_class/db_class.dart';

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
  int _currentCarouselIndex = 0;
  String selectedYear = '2025';
  final List<String> years = ['2023', '2024', '2025', '2026'];
  bool isDarkTheme = true;

  final List<String> _carouselImages = [
    'https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg',
    'https://media.istockphoto.com/id/2064972148/photo/ai-concept-controlling-technological-tools-intelligent-robots-development-of-an-artificial.jpg?s=2048x2048&w=is&k=20&c=CSIqn-EAtpdA58shd1RpRY3Bmt5u0RbSQxBFwkYuxP8=',
    'https://media.istockphoto.com/id/1182567852/photo/ai-artificial-intelligence-central-computer-processors-cpu-concept.jpg?s=2048x2048&w=is&k=20&c=QrkunbqSqCgjGwt2wghydHuyyR_yOV1fIUaXs6Ip7bg=',
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

    _animationController.forward();
    _cardAnimationController.forward();

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

  void _toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
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
          // Header
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
          // Chart content
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
                        gradient: LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                          // begin: Alignment.homosexuals,
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
          // Action buttons
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
    return Scaffold(
      backgroundColor:
          isDarkTheme ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: Container(
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
                children: [_buildHomePage(), const ReportScreen(), More()],
              ),
            ),
            _buildBottomNavBar(),
            if (!isDarkTheme) _buildAndroidNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDarkTheme
                  ? [
                    const Color(0xFF008080).withOpacity(0.8),
                    const Color(0xFF20B2AA).withOpacity(0.6),
                  ]
                  : [const Color(0xFFCFECEC), const Color(0xFFE0ECEC)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008080).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        top: 50.0,
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isDarkTheme
                        ? [Colors.white, Colors.grey]
                        : [Colors.teal.shade100, Colors.teal.shade300],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Color(0xFF008080),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Personal App',
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : const Color(0xFF008080),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Your financial companion',
                style: TextStyle(
                  color:
                      isDarkTheme
                          ? Colors.white.withOpacity(0.8)
                          : const Color(0xFF008080).withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildAppBarButton(Icons.notifications_none, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationScreen()),
            );
          }),
          const SizedBox(width: 12),
          _buildAppBarButton(Icons.settings, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          }),
          const SizedBox(width: 12),
          _buildAppBarButton(Icons.brightness_6, _toggleTheme),
        ],
      ),
    );
  }

  Widget _buildAppBarButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDarkTheme
                ? Colors.white.withOpacity(0.15)
                : Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDarkTheme
                  ? Colors.white.withOpacity(0.2)
                  : Colors.teal.withOpacity(0.2),
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDarkTheme ? Colors.white : Colors.teal,
          size: 24,
        ),
        onPressed: onPressed,
      ),
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
    return Column(
      children: [
        const SizedBox(height: 10),
        CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            aspectRatio: 16 / 9,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          items:
              _carouselImages.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF008080).withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors:
                                          isDarkTheme
                                              ? [
                                                Colors.grey.shade800,
                                                Colors.grey.shade600,
                                              ]
                                              : [
                                                Colors.grey.shade300,
                                                Colors.grey.shade100,
                                              ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors:
                                          isDarkTheme
                                              ? [
                                                Colors.grey.shade800,
                                                Colors.grey.shade600,
                                              ]
                                              : [
                                                Colors.grey.shade300,
                                                Colors.grey.shade100,
                                              ],
                                    ),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF008080),
                                          ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              _carouselImages.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentCarouselIndex == entry.key ? 24.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:
                        _currentCarouselIndex == entry.key
                            ? const Color(0xFF008080)
                            : (isDarkTheme
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.5)),
                  ),
                );
              }).toList(),
        ),
      ],
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
    return AnimatedNotchBottomBar(
      notchBottomBarController: _notchController,
      color: const Color(0xFF008080),
      showLabel: true,
      notchColor: isDarkTheme ? Colors.white : Colors.teal.shade100,
      kIconSize: 24.0,
      kBottomRadius: 40.0,
      itemLabelStyle: TextStyle(
        fontSize: 14,
        color: isDarkTheme ? Colors.white : Colors.black54,
        fontWeight: FontWeight.w500,
      ),
      bottomBarItems: [
        const BottomBarItem(
          inActiveItem: Icon(Icons.home, color: Colors.white70),
          activeItem: Icon(Icons.home, color: Colors.white),
          itemLabel: 'Home',
        ),
        const BottomBarItem(
          inActiveItem: Icon(Icons.description_outlined, color: Colors.white70),
          activeItem: Icon(Icons.description_outlined, color: Colors.white),
          itemLabel: 'Report',
        ),
        const BottomBarItem(
          inActiveItem: Icon(Icons.more_horiz, color: Colors.white70),
          activeItem: Icon(Icons.more_horiz, color: Colors.white),
          itemLabel: 'More',
        ),
      ],
      onTap: (index) {
        _changePage(index);
      },
    );
  }

  Widget _buildAndroidNavBar() {
    return Container(
      height: 48,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.arrow_back, color: Colors.white),
          Icon(Icons.circle_outlined, color: Colors.white),
          Icon(Icons.crop_square, color: Colors.white),
        ],
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
          MaterialPageRoute(builder: (context) => PasswordListPage()),
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
          MaterialPageRoute(builder: (context) => AssetDetailScreen()),
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
          MaterialPageRoute(builder: (context) => Liabilities()),
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
          MaterialPageRoute(builder: (context) => Tasks()),
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
      onPressed: (BuildContext context) => debugPrint('Mobile Recharge tapped'),
    ),
    CategoryItem(
      icon: Icons.satellite_alt,
      label: 'DTH Recharge',
      iconColor: Colors.teal,
      onPressed: (BuildContext context) => debugPrint('DTH Recharge tapped'),
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

class More extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'More Screen',
        style: TextStyle(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
          fontSize: 20,
        ),
      ),
    );
  }
}
