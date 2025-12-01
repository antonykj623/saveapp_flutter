import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'dart:math' as math;

class MyNetworthScreen extends StatefulWidget {
  const MyNetworthScreen({super.key});

  @override
  State<MyNetworthScreen> createState() => _MyNetworthScreenState();
}

class _MyNetworthScreenState extends State<MyNetworthScreen>
    with TickerProviderStateMixin {
  Map<String, double> assetBalances = {};
  Map<String, double> liabilityBalances = {};
  bool isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

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

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadBalances();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadBalances() async {
    try {
      final accounts = await DatabaseHelper().getAllData(
        'TABLE_ACCOUNTSETTINGS',
      );

      Map<String, double> assets = {};
      Map<String, double> liabilities = {};

      for (String liabilityType in liabilityTypes) {
        liabilities[liabilityType] = 0.0;
      }

      Map<String, bool> accountTypeExists = {};

      for (var account in accounts) {
        try {
          String dataString = account['data']?.toString() ?? '{}';
          Map<String, dynamic> data = jsonDecode(dataString);
          String accountType = data['Accounttype']?.toString() ?? '';
          double openingBalance =
              double.tryParse(data['balance']?.toString() ?? '0') ?? 0.0;

          accountTypeExists[accountType] = true;

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

      assets.removeWhere(
        (key, value) => value == 0.0 && !accountTypeExists.containsKey(key),
      );

      setState(() {
        assetBalances = assets;
        liabilityBalances = liabilities;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading balances: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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

  double get totalAssets {
    return assetBalances.values.fold(0.0, (sum, balance) => sum + balance);
  }

  double get totalLiabilities {
    return liabilityBalances.values.fold(0.0, (sum, balance) => sum + balance);
  }

  double get networth {
    return totalAssets - totalLiabilities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A237E),
              const Color(0xFF283593),
              const Color(0xFF3949AB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context),
              Expanded(
                child:
                    isLoading
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading your wealth...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                        : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My NetWorth',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Financial Overview',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                _loadBalances();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: _loadBalances,
          color: const Color(0xFF1A237E),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildNetworthSummaryCard(),
                const SizedBox(height: 24),
                _buildAssetsSection(),
                const SizedBox(height: 24),
                _buildLiabilitiesSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworthSummaryCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated background pattern
                Positioned.fill(
                  child: CustomPaint(painter: CirclePatternPainter()),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1A237E),
                                  const Color(0xFF3949AB),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1A237E,
                                  ).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total Net Worth',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: networth),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return ShaderMask(
                            shaderCallback:
                                (bounds) => LinearGradient(
                                  colors: [
                                    const Color(0xFF1A237E),
                                    const Color(0xFF3949AB),
                                  ],
                                ).createShader(bounds),
                            child: Text(
                              '₹${value.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryItem(
                              'Assets',
                              totalAssets,
                              Icons.trending_up,
                              Colors.green,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              'Liabilities',
                              totalLiabilities,
                              Icons.trending_down,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: amount),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, animValue, child) {
                  return Text(
                    '₹${animValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssetsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'My Assets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          assetBalances.isEmpty
              ? Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No asset accounts found',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children:
                    assetBalances.entries.map((entry) {
                      int index = assetBalances.keys.toList().indexOf(
                        entry.key,
                      );
                      return _buildAccountCard(
                        entry.key,
                        entry.value,
                        true,
                        index,
                      );
                    }).toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildLiabilitiesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.credit_card, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'My Liabilities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children:
                liabilityBalances.entries.map((entry) {
                  int index = liabilityBalances.keys.toList().indexOf(
                    entry.key,
                  );
                  return _buildAccountCard(
                    entry.key,
                    entry.value,
                    false,
                    index,
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    String accountName,
    double balance,
    bool isAsset,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade50, Colors.white],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AccountTransactionsScreen(
                              accountType: accountName,
                              balance: balance,
                            ),
                      ),
                    ).then((_) => _loadBalances());
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isAsset ? Colors.green : Colors.red)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isAsset ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isAsset ? Colors.green : Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                accountName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${isAsset ? "Asset" : "Liability"} Account',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    balance >= 0
                                        ? Colors.grey.shade800
                                        : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'View',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A237E),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: const Color(0xFF1A237E),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
}

// Custom painter for background pattern
class CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.shade200.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.3),
        30.0 + (i * 20),
        paint,
      );
    }

    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.7),
        20.0 + (i * 15),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Account Transactions Screen remains the same
class AccountTransactionsScreen extends StatefulWidget {
  final String accountType;
  final double balance;

  const AccountTransactionsScreen({
    super.key,
    required this.accountType,
    required this.balance,
  });

  @override
  State<AccountTransactionsScreen> createState() =>
      _AccountTransactionsScreenState();
}

class _AccountTransactionsScreenState extends State<AccountTransactionsScreen> {
  List<Map<String, dynamic>> accounts = [];
  bool isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final allAccounts = await DatabaseHelper().getAllData(
        'TABLE_ACCOUNTSETTINGS',
      );
      final transactions = await DatabaseHelper().getAllData('TABLE_ACCOUNTS');

      Map<String, double> accountBalances = {};
      bool isLiabilityType = liabilityTypes.contains(widget.accountType);

      for (var account in allAccounts) {
        try {
          String dataString = account['data']?.toString() ?? '{}';
          Map<String, dynamic> data = jsonDecode(dataString);
          String accountType = data['Accounttype']?.toString() ?? '';
          String accountName = data['Accountname']?.toString() ?? '';

          if (accountType == widget.accountType) {
            double openingBalance =
                double.tryParse(data['balance']?.toString() ?? '0') ?? 0.0;
            accountBalances[accountName] = openingBalance;
          }
        } catch (e) {
          print('Error parsing account: $e');
        }
      }

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

          String accountName = await _getAccountNameFromSetupId(setupId);

          if (accountBalances.containsKey(accountName)) {
            if (isLiabilityType) {
              if (type == 'debit') {
                accountBalances[accountName] =
                    (accountBalances[accountName] ?? 0.0) - amount;
              } else if (type == 'credit') {
                accountBalances[accountName] =
                    (accountBalances[accountName] ?? 0.0) + amount;
              }
            } else {
              if (type == 'debit') {
                accountBalances[accountName] =
                    (accountBalances[accountName] ?? 0.0) + amount;
              } else if (type == 'credit') {
                accountBalances[accountName] =
                    (accountBalances[accountName] ?? 0.0) - amount;
              }
            }
          }
        } catch (e) {
          print('Error parsing transaction: $e');
        }
      }

      List<Map<String, dynamic>> filteredAccounts = [];
      accountBalances.forEach((name, balance) {
        filteredAccounts.add({'name': name, 'balance': balance});
      });

      setState(() {
        accounts = filteredAccounts;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading accounts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _getAccountNameFromSetupId(String setupId) async {
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
        return data['Accountname']?.toString() ?? '';
      }
      return '';
    } catch (e) {
      print('Error getting account name: $e');
      return '';
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
            colors: [
              const Color(0xFF1A237E),
              const Color(0xFF283593),
              const Color(0xFF3949AB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context),
              Expanded(
                child:
                    isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : _buildAccountsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.accountType,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Account Details',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList() {
    return Column(
      children: [
        // Balance Summary Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: widget.balance),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [
                            widget.balance >= 0 ? Colors.green : Colors.red,
                            widget.balance >= 0
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ],
                        ).createShader(bounds),
                    child: Text(
                      '₹${value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Accounts List
        Expanded(
          child:
              accounts.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${widget.accountType} accounts found',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(50 * (1 - value), 0),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.grey.shade50],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF1A237E),
                                              const Color(0xFF3949AB),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.account_balance,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              account['name'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.accountType,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(
                                          begin: 0.0,
                                          end: account['balance'],
                                        ),
                                        duration: const Duration(
                                          milliseconds: 1500,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, animValue, child) {
                                          return Text(
                                            '₹${animValue.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  account['balance'] >= 0
                                                      ? Colors.green.shade700
                                                      : Colors.red.shade700,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
