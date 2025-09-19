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

        title: Text(' Account Setup', style: TextStyle(color: Colors.white)),
      ),

      body: Container(
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.search),
                ),
                hintText: 'Search by Account Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              // calls the _searchChanged on textChange
              //   onChanged: (search) =>
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
                      Map<String, dynamic> dat = jsonDecode(i["data"]);
                      if (dat['Accountname'].toString().contains(name)) {
                        items.add(i);
                      }
                    }
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      Map<String, dynamic> dat = jsonDecode(item["data"]);

                      // Map<String,dynamic>id=jsonDecode(item['keyid'])  ;

                      // print(item['keyid']);
                      return Card(
                        elevation: 5,
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //  Text('AccountName    '),
                                    //  Text('  :  '),
                                    Text("${dat['Accountname'].toString()}"),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Text('Catogory '),
                                    // Text('              :   '),
                                    Text("${dat['Accounttype'] ?? "0"}"),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   'opening'
                                    //   'balance ',
                                    // ),
                                    // Text('   :   '),
                                    Text("${dat['Amount'] ?? "0"}"),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('AccountType      '),
                                    Text('   :   '),

                                    Text("${dat['Accounttype'] ?? "0"}"),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Year             '),
                                    Text('           :   '),
                                    Text('$currentYear'),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 280.0,
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          Map<String, dynamic>
                                          accountsetupData = {
                                            // "id":items[0],
                                            "Accountname":
                                                dat['Accountname'].toString(),

                                            "catogory":
                                                dat['Accounttype'].toString(),
                                            "Amount": dat['Amount'].toString(),
                                            "Type": dat['Type'].toString(),
                                            "year": dat['year'].toString(),
                                            "keyid": item['keyid'].toString(),
                                          };
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Editaccount(
                                                    keyid:
                                                        item['keyid']
                                                            .toString(),
                                                    year: '${currentYear}',
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
                                          );
                                        },
                                        child: Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 40.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Spacer(),
            Container(
              height: 65,

              child: FloatingActionButton(
                backgroundColor: Colors.red,
                tooltip: 'Increment',
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Addaccountsdet()),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white, size: 25),
              ),
            ),
            //  Text('Home'),
            Spacer(),
          ],
        ),
      ),
    );

    //  return   Placeholder();
  }
}
