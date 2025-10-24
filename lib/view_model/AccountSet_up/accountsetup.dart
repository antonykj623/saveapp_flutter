import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/Modules/accounts/addaccount.dart';
import '../../app/Modules/accounts/editaccountdetails.dart';
import '../../app/Modules/accounts/global.dart' as global;

import 'Add_Acount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

queryall() async {
  var allrows = await DatabaseHelper().queryallacc();

  allrows.forEach((row) {
    List valuesList = row.values.toList();
    var a = valuesList[1];
    print(a);
  });
}

var id;

List<String> _filteredItems = [];
TextEditingController _searchController = TextEditingController();

class Accountsetup extends StatefulWidget {
  const Accountsetup({super.key});

  @override
  State<Accountsetup> createState() => _Home_ScreenState();
}

List<Map<String, dynamic>> _foundUsers = [];

class _Home_ScreenState extends State<Accountsetup> {
  int currentYear = DateTime.now().year;

  @override
  initState() {
    super.initState();
  }

  String name = "";

  // Function to refresh the list when returning from add/edit
  void _refreshAccountList() {
    setState(() {});
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
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                  ),
                  hintText: 'Search by Account Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
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
                      child: Text(
                        'No accounts found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
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
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance,
                                      color: Colors.teal,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${dat['Accountname'].toString()}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),

                                Row(
                                  children: [
                                    Text(
                                      'Account Type: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "${dat['Accounttype'] ?? 'N/A'}",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),

                                // Opening Balance
                                Row(
                                  children: [
                                    Text(
                                      'Opening Balance: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "₹${dat['balance'] ?? '0'}",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),

                                // Nature (Debit/Credit)
                                Row(
                                  children: [
                                    Text(
                                      'Nature: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            dat['Type']
                                                        .toString()
                                                        .toLowerCase() ==
                                                    'debit'
                                                ? Colors.orange.shade100
                                                : Colors.purple.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${dat['Type'] ?? 'N/A'}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              dat['Type']
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'debit'
                                                  ? Colors.orange.shade800
                                                  : Colors.purple.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),

                                // Year
                                Row(
                                  children: [
                                    Text(
                                      'Year: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '$currentYear',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),

                                // Edit Button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        Map<String, dynamic>
                                        accountsetupData = {
                                          "Accountname":
                                              dat['Accountname'].toString(),
                                          "catogory":
                                              dat['Accounttype'].toString(),
                                          "Amount":
                                              dat['balance']
                                                  .toString(), // Fixed: use 'balance' not 'Amount'
                                          "Type": dat['Type'].toString(),
                                          "year": currentYear.toString(),
                                          "keyid": item['keyid'].toString(),
                                        };

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => Editaccount(
                                                  keyid:
                                                      item['keyid'].toString(),
                                                  year: '$currentYear',
                                                  accname:
                                                      accountsetupData['Accountname'],
                                                  cat:
                                                      accountsetupData['catogory'],
                                                  obalance:
                                                      accountsetupData['Amount'],
                                                  actype:
                                                      accountsetupData['Type'],
                                                ),
                                          ),
                                        ).then(
                                          (_) => _refreshAccountList(),
                                        ); // Refresh after edit
                                      },
                                      icon: Icon(Icons.edit, size: 16),
                                      label: Text('Edit'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        print('Error displaying account: $e');
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Error displaying account data'),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        tooltip: 'Add Account',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Addaccountsdet()),
          ).then((_) => _refreshAccountList()); // Refresh after adding
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
