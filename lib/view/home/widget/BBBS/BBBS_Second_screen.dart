import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/BBBS/Mobile_Recharge_page_BBS/Mobile_landing_Recharge.dart'
    show MobileRechargeScreen;

// Route name constant
const String rechargeRoute = '/recharge';

// Recharge Model (optional - can be used in RechargeScreen)
class RechargeOption {
  final String title;
  final IconData icon;
  final Color color;
  final String subtitle;

  RechargeOption({
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle = '',
  });
}

// Sample data (can be moved to provider or separate file later)
final List<RechargeOption> rechargeOptions = [
  RechargeOption(
    title: 'Mobile Recharge',
    icon: Icons.phone_android,
    color: Colors.blue,
    subtitle: 'Prepaid & Postpaid',
  ),
  RechargeOption(
    title: 'DTH Recharge',
    icon: Icons.tv,
    color: Colors.orange,
    subtitle: 'Airtel, Tata Play, DishTV',
  ),
  RechargeOption(
    title: 'Fastag Recharge',
    icon: Icons.directions_car,
    color: Colors.green,
    subtitle: 'Instant top-up',
  ),
  RechargeOption(
    title: 'Electricity Bill',
    icon: Icons.lightbulb,
    color: Colors.amber,
    subtitle: 'Pay bills quickly',
  ),
  RechargeOption(
    title: 'Broadband',
    icon: Icons.wifi,
    color: Colors.purple,
    subtitle: 'ACT, Jio, Airtel',
  ),
];

void main() {
  runApp(const BankingApp());
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banking App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[100],
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      
      onGenerateRoute: (settings) {
        if (settings.name == rechargeRoute) {
          return PageRouteBuilder(
            settings: settings,
            transitionDuration: const Duration(milliseconds: 450),
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const RechargeScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(0.0, 0.3);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;

              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        }
        return null;
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const BankingHomePage(),
        rechargeRoute: (context) => MobileRechargeScreen(),
      },
    );
  }
}

class BankingHomePage extends StatefulWidget {
  const BankingHomePage({super.key});

  @override
  State<BankingHomePage> createState() => _BankingHomePageState();
}

class _BankingHomePageState extends State<BankingHomePage> {
  int _selectedIndex = 0;

  // Advanced navigation function
  void _navigateToRecharge(BuildContext context) {
    Navigator.pushNamed(
      context,
      rechargeRoute,
      arguments: 'recharge_icon', // optional: can be used for Hero
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAccountCard(),
                  const SizedBox(height: 20),
                  _buildServicesGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              const Expanded(
                child: Text(
                  'What would you like to do today?',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Savings Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'My Cards',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'XXXXXXXXXXXX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('View Balance'),
          ),
          const SizedBox(height: 8),
          const Text(
            'IBAN: xxxXXXXXXc-bank',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Statement',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.white30),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Manage',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.white30),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Services',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTabBar(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildServiceRow([
                  _ServiceItem(Icons.phone_android, 'Fund Transfer', false),
                  _ServiceItem(Icons.payment, 'Bill Payments', true),
                  _ServiceItem(
                    Icons.refresh,
                    'Recharge',
                    true, // Highlighted
                    onTap: () => _navigateToRecharge(context),
                    heroTag: 'recharge_icon', // for Hero animation
                  ),
                ]),
                const SizedBox(height: 16),
                _buildServiceRow([
                  _ServiceItem(
                    Icons.account_balance_wallet,
                    'My Accounts',
                    false,
                  ),
                  _ServiceItem(Icons.credit_card, 'Cards & Forex', false),
                  _ServiceItem(Icons.local_offer, 'Loans', false),
                ]),
                const SizedBox(height: 16),
                _buildServiceRow([
                  _ServiceItem(Icons.security, 'Invest & Insure', false),
                  _ServiceItem(Icons.sticky_note_2, 'Trade on', false),
                  _ServiceItem(Icons.explore, 'Discover', false),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          _buildTab('Transact', true),
          _buildTab('Invest & Insure', false),
          _buildTab('Shop', false),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFB71C1C) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: TextButton(
          onPressed: () {},
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFFB71C1C) : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceRow(List<_ServiceItem> items) {
    return Row(
      children:
          items
              .map((item) => Expanded(child: _buildServiceItem(item)))
              .toList(),
    );
  }

  Widget _buildServiceItem(_ServiceItem item) {
    return GestureDetector(
      onTap: item.onTap ?? () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Hero(
                  tag: item.heroTag ?? 'service_${item.label.toLowerCase()}',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          item.isHighlighted
                              ? const Color(0xFF8B1C1C)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          item.isHighlighted
                              ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                              : null,
                    ),
                    child: Icon(
                      item.icon,
                      color:
                          item.isHighlighted ? Colors.white : Colors.grey[700],
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    fontWeight:
                        item.isHighlighted
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (item.isHighlighted)
            Positioned(
              right: 4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.account_balance_wallet, 'Earn Coins', 1),
              _buildNavItem(Icons.chat, 'Nisha for Pay', 2),
              _buildNavItem(Icons.local_offer, 'Offers', 3),
              _buildNavItem(Icons.account_circle, 'Rewards', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFB71C1C) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFB71C1C) : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// Updated Service Item class
class _ServiceItem {
  final IconData icon;
  final String label;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final String? heroTag;

  _ServiceItem(
    this.icon,
    this.label,
    this.isHighlighted, {
    this.onTap,
    this.heroTag,
  });
}

// Your existing RechargeScreen (example)
class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharge & Bill Payments'),
        backgroundColor: const Color(0xFFB71C1C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: rechargeOptions.length,
          itemBuilder: (context, index) {
            final option = rechargeOptions[index];
            return Column(
              children: [
                Hero(
                  tag: 'recharge_${option.title.toLowerCase()}',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: option.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(option.icon, color: option.color, size: 36),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  option.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (option.subtitle.isNotEmpty)
                  Text(
                    option.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
