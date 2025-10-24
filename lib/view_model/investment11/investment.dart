import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_project_2025/view_model/investment11/addinvestment.dart';
import '../../app/Modules/accounts/addaccount.dart';
import '../../app/Modules/accounts/editaccountdetails.dart';
import '../../services/dbhelper/dbhelper.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import '../AccountSet_up/Add_Acount.dart';
import 'dart:convert';

final dbhelper = DatabaseHelper();

class Investment extends StatefulWidget {
  const Investment({super.key});

  @override
  State<Investment> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Investment> {
  @override
  void initState() {
    super.initState();
    queryall();
  }

  void queryall() async {
    List<Map<String, dynamic>> allrows = await dbhelper.getAllInvestmentNames();
    allrows.forEach((k) {
      print("Investment Name: ${k['investname']}");
    });
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Investment', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getInvestmentAccountsWithDetails(),
                builder: (
                  context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading investments'),
                    );
                  }
                  List<Map<String, dynamic>> dat = snapshot.data ?? [];
                  double totalAmount = dat.fold(
                    0.0,
                    (sum, item) => sum + (item['balance'] as double),
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: dat.length,
                          itemBuilder: (BuildContext context, int index) {
                            String name = dat[index]['name'];
                            double balance = dat[index]['balance'];

                            return Card(
                              elevation: 5,
                              child: Container(
                                height: 120,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Text('Name          '),
                                          const Text('         :'),
                                          Text(name),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Text('Amount '),
                                          const Text('              :   '),
                                          Text(balance.toStringAsFixed(2)),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 180.0,
                                        top: 25,
                                      ),
                                      child: Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          AddInvestment(
                                                            accountName: name,
                                                          ),
                                                ),
                                              ).then((_) => setState(() {}));
                                            },
                                            child: const Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await showDeleteConfirmation(
                                                context,
                                                name,
                                              );
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 20,
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
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Spacer(),
                            Container(
                              height: 105,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 70.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Amount:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      totalAmount.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 18.0,
                                right: 20,
                              ),
                              child: FloatingActionButton(
                                backgroundColor: Colors.red,
                                tooltip: 'Add Investment',
                                shape: const CircleBorder(),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const AddInvestment(),
                                    ),
                                  ).then((_) => setState(() {}));
                                },
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fixed method to get investment accounts with proper details
  Future<List<Map<String, dynamic>>> getInvestmentAccountsWithDetails() async {
    try {
      List<Map<String, dynamic>> investments = [];

      // Get all investment names from INVESTNAMES_TABLE
      List<Map<String, dynamic>> investmentNames =
          await dbhelper.getAllInvestmentNames();

      for (var investName in investmentNames) {
        String name = investName['investname'];

        // Get investment details and calculate actual balance
        double balance = 0.0;

        // First try to get from account setup
        try {
          Map<String, dynamic>? accountDetails = await dbhelper
              .getInvestmentDetailsByName(name);
          if (accountDetails != null) {
            Map<String, dynamic> data = jsonDecode(accountDetails['data']);
            // Get target amount as the balance to show
            balance =
                double.tryParse(data['target_amount']?.toString() ?? '0') ??
                0.0;
          }
        } catch (e) {
          print('Error getting investment details for $name: $e');
        }

        investments.add({'name': name, 'balance': balance});
      }

      return investments;
    } catch (e) {
      print('Error getting investment accounts with details: $e');  
      return [];
    }
  }

  // Enhanced delete confirmation with proper cleanup
  Future<void> showDeleteConfirmation(BuildContext context, String name) async {
    if (name == 'My Savings') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete My Savings'), 
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete "$name"?\n\nThis will remove all investment data and settings for this account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteInvestmentCompletely(name);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Complete investment deletion including all related data
  Future<void> deleteInvestmentCompletely(String name) async {
    try {
      // 1. Delete from INVESTNAMES_TABLE
      final investNames = await dbhelper.getAllInvestmentNames();
      final investName = investNames.firstWhere(
        (item) => item['investname'] == name,
        orElse: () => {'keyid': 0},
      );

      if (investName['keyid'] != 0) {
        await dbhelper.deleteInvestmentName(investName['keyid']);
        print('Deleted from INVESTNAMES_TABLE: $name');
      }

      // 2. Delete from TABLE_ACCOUNTSETTINGS
      final accounts = await dbhelper.getAllData("TABLE_ACCOUNTSETTINGS");
      for (var account in accounts) {
        try {
          Map<String, dynamic> accountData = jsonDecode(account["data"]);
          if (accountData['Accountname'].toString().toLowerCase() ==
                  name.toLowerCase() &&
              accountData['Accounttype'].toString().toLowerCase() ==
                  'investment') {
            await dbhelper.deleteData(
              'TABLE_ACCOUNTSETTINGS',
              account['keyid'],
            );
            print('Deleted from TABLE_ACCOUNTSETTINGS: $name');
            break;
          }
        } catch (e) {
          print('Error checking account data: $e');
        }
      }

      // 3. Delete related transactions from TABLE_ACCOUNTS if any
      // Get setup ID and delete related transactions
      String setupId = await dbhelper.getAccountSetupId(name);
      if (setupId != '0') {
        final db = await dbhelper.database;
        await db.delete(
          'TABLE_ACCOUNTS',
          where: 'ACCOUNTS_setupid = ?',
          whereArgs: [setupId],
        );
        print('Deleted transactions for: $name');
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Investment "$name" deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting investment completely: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting investment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
