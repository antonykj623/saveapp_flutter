import 'dart:convert';
import 'package:flutter/material.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'assetpage.dart';

class Asset {
  final String name;
  final String balance;
  final DateTime purchaseDate;

  Asset({
    required this.name,
    required this.balance,
    required this.purchaseDate,
  });
}

class AssetListPage extends StatefulWidget {
  @override
  _AssetListPageState createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  List<Map<String, dynamic>> assetList = [];
  bool isLoading = false;

  void _navigateToAddAsset() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AssetFormPage("0", {})),
    );

    if (result != null || result == null) {
      getAllAccounts();
    }
  }

  getAllAccounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> mpd = await DatabaseHelper().getAllData(
        "TABLE_ASSET",
      );

      setState(() {
        assetList = mpd;
        isLoading = false;
      });

      print("✅ Loaded ${assetList.length} assets");
    } catch (e) {
      print("❌ Error loading assets: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllAccounts();
  }

  Future<void> deleteAssetData(String id) async {
    try {
      print("🗑️ Starting delete process for ID: $id");

      // Parse the ID to integer
      int assetId = int.parse(id);

      // Call the delete method from DatabaseHelper
      int result = await DatabaseHelper().deleteData("TABLE_ASSET", assetId);

      if (result > 0) {
        print("✅ Asset deleted successfully from database");

        // Refresh the list
        await getAllAccounts();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Asset deleted successfully"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print("⚠️ Delete operation returned 0 - asset may not exist");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete asset - not found"),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error in deleteAssetData: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting asset: $e"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assets"),
        actions: [
          if (assetList.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  "${assetList.length} assets",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : assetList.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No assets found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap + to add your first asset",
                        
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: () async {
                  await getAllAccounts();
                },
                child: ListView.builder(
                  itemCount: assetList.length,
                  itemBuilder: (context, index) {
                    final a = assetList[index];
                    Map<String, dynamic> asset = jsonDecode(a["data"]);

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Colors.green.shade700,
                              ),
                            ),
                            title: Text(
                              asset["assetname"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "Balance: ₹${asset["amount"]}\n"
                              "Purchased: ${asset["purchase_date"]}",
                              style: TextStyle(fontSize: 13),
                            ),
                            isThreeLine: true,
                            onTap: () {
                              // Optional: view asset details
                            },
                          ),
                          Divider(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AssetFormPage(
                                            a["keyid"].toString(),
                                            asset,
                                          ),
                                    ),
                                  );

                                  if (result != null || result == null) {
                                    getAllAccounts();
                                  }
                                },
                                icon: Icon(Icons.edit, size: 18),
                                label: Text("Edit"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                              ),
                              Container(
                                height: 30,
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  showDeleteConfirmationDialog(
                                    context,
                                    "Delete Asset",
                                    "Are you sure you want to delete '${asset["assetname"]}'?",
                                    assetList[index]["keyid"].toString(),
                                  );
                                },
                                icon: Icon(Icons.delete, size: 18),
                                label: Text("Delete"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAsset,
        child: Icon(Icons.add),
        tooltip: "Add Asset",
        backgroundColor: Colors.green,
      ),
    );
  }

  void showDeleteConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    String id,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Delete"),
              onPressed: () async {
                // Close the dialog first
                Navigator.of(dialogContext).pop();

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(child: CircularProgressIndicator());
                  },
                );

                // Perform the delete operation
                await deleteAssetData(id);

                // Close loading indicator
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
