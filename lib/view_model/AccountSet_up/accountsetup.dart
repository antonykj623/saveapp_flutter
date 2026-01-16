import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/Modules/accounts/addaccount.dart';
import '../../app/Modules/accounts/editaccountdetails.dart';
import '../../app/Modules/accounts/global.dart' as global;

import 'Add_Acount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/services/Premium_services/Premium_services.dart';

queryall() async {
  var allrows = await DatabaseHelper().queryallacc();

  allrows.forEach((row) {
    List valuesList = row.values.toList();
    var a = valuesList[1];
    print(a);
  });
}

class Accountsetup extends StatefulWidget {
  const Accountsetup({super.key});

  @override
  State<Accountsetup> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Accountsetup> {
  int currentYear = DateTime.now().year;
  TextEditingController _searchController = TextEditingController();
  String name = "";

  // Premium check states
  bool isCheckingPremium = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to refresh the list when returning from add/edit
  void _refreshAccountList() {
    setState(() {});
  }

  // Handle Add Account with premium check
  Future<void> _handleAddAccount() async {
    setState(() => isCheckingPremium = true);

    final canAdd = await PremiumService().canAddData(forceRefresh: true);
    final status = PremiumService().getCachedStatus();

    setState(() => isCheckingPremium = false);

    // Check if product_id is 2 and premium is not active
    if (status != null && status.productId == 2 && !canAdd) {
      PremiumService.showPremiumExpiredDialog(
        context,
        customMessage:
            status.isPremium
                ? 'Your premium subscription has expired.'
                : 'Your trial period has ended.\nPlease upgrade to continue.',
      );
      return;
    }

    if (!canAdd) {
      PremiumService.showPremiumExpiredDialog(
        context,
        customMessage:
            status?.isPremium == true
                ? 'Your premium subscription has expired.'
                : 'Your trial period has ended.\nPlease upgrade to continue.',
      );
      return;
    }

    // Premium is active - navigate to add account
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Addaccountsdet()),
    ).then((_) => _refreshAccountList());
  }

  // Handle Edit Account with premium check
  Future<void> _handleEditAccount({
    required String keyid,
    required String year,
    required String accname,
    required String cat,
    required String obalance,
    required String actype,
  }) async {
    setState(() => isCheckingPremium = true);

    final canAdd = await PremiumService().canAddData(forceRefresh: true);
    final status = PremiumService().getCachedStatus();

    setState(() => isCheckingPremium = false);

    // Check if product_id is 2 and premium is not active
    if (status != null && status.productId == 2 && !canAdd) {
      PremiumService.showPremiumExpiredDialog(
        context,
        customMessage: 'Premium required to edit account.',
      );
      return;
    }

    if (!canAdd) {
      PremiumService.showPremiumExpiredDialog(
        context,
        customMessage: 'Premium required to edit account.',
      );
      return;
    }

    // Premium is active - navigate to edit account
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Editaccount(
              keyid: keyid,
              year: year,
              accname: accname,
              cat: cat,
              obalance: obalance,
              actype: actype,
            ),
      ),
    ).then((_) => _refreshAccountList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text('Account Setup', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by Account Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().getAllData('TABLE_ACCOUNTSETTINGS'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    List<Map<String, dynamic>> items = [];

                    if (name.isEmpty) {
                      items = snapshot.data ?? [];
                    } else {
                      final items1 = snapshot.data ?? [];

                      for (var i in items1) {
                        try {
                          Map<String, dynamic> dat = jsonDecode(i["data"]);
                          if (dat['Accountname']
                              .toString()
                              .toLowerCase()
                              .contains(name.toLowerCase())) {
                            items.add(i);
                          }
                        } catch (e) {
                          print('Error parsing account data: $e');
                        }
                      }
                    }

                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              name.isEmpty
                                  ? 'No accounts found'
                                  : 'No matching accounts',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        try {
                          Map<String, dynamic> dat = jsonDecode(item["data"]);

                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 4.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Account Name with Icon
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.account_balance,
                                          color: Colors.teal,
                                          size: 24,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "${dat['Accountname']?.toString() ?? 'Unnamed Account'}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),

                                  // Account Details Container
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        // Account Type
                                        _buildInfoRow(
                                          'Account Type',
                                          "${dat['Accounttype'] ?? 'N/A'}",
                                          Colors.blue.shade700,
                                        ),
                                        Divider(height: 16),

                                        // Opening Balance
                                        _buildInfoRow(
                                          'Opening Balance',
                                          "₹${dat['balance'] ?? '0'}",
                                          Colors.green.shade700,
                                          isBold: true,
                                        ),
                                        Divider(height: 16),

                                        // Nature
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Nature',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade700,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    dat['Type']
                                                                ?.toString()
                                                                .toLowerCase() ==
                                                            'debit'
                                                        ? Colors.orange.shade100
                                                        : Colors
                                                            .purple
                                                            .shade100,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                "${dat['Type'] ?? 'N/A'}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      dat['Type']
                                                                  ?.toString()
                                                                  .toLowerCase() ==
                                                              'debit'
                                                          ? Colors
                                                              .orange
                                                              .shade800
                                                          : Colors
                                                              .purple
                                                              .shade800,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(height: 16),

                                        // Year
                                        _buildInfoRow(
                                          'Year',
                                          '$currentYear',
                                          Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  // Edit Button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        // Call premium check method before editing
                                        _handleEditAccount(
                                          keyid:
                                              item['keyid']?.toString() ?? '',
                                          year: '$currentYear',
                                          accname:
                                              dat['Accountname']?.toString() ??
                                              '',
                                          cat:
                                              dat['Accounttype']?.toString() ??
                                              '',
                                          obalance:
                                              dat['balance']?.toString() ?? '0',
                                          actype: dat['Type']?.toString() ?? '',
                                        );
                                      },
                                      icon: Icon(Icons.edit, size: 18),
                                      label: Text('Edit Account'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } catch (e) {
                          print('Error displaying account: $e');
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Error displaying account data',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Loading overlay - only shows when checking premium
          if (isCheckingPremium)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.teal),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Verifying Access...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        tooltip: 'Add Account',
        onPressed: _handleAddAccount, // Changed to call premium check method
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Account', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
