import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view_model/liability_lists/addliability.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class LiabilityListPage extends StatefulWidget {
  @override
  _LiabilityListPageState createState() => _LiabilityListPageState();
}

class _LiabilityListPageState extends State<LiabilityListPage> {
  List<Map<String, dynamic>> liabilityList = [];
  bool isLoading = true;

  void _navigateToAddLiability() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LiabilityFormPage("0", {})),
    );

    // Refresh list if any result is returned
    if (result != null) {
      getAllAccounts();
    }
  }

  @override
  void initState() {
    super.initState();
    getAllAccounts();
  }

  Future<void> getAllAccounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> mpd = await DatabaseHelper().getAllData(
        "TABLE_LIABILITY",
      );
      setState(() {
        liabilityList = mpd;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading liabilities: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liabilities"),
        backgroundColor: Colors.redAccent,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : liabilityList.isEmpty
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
                      "No liabilities found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: liabilityList.length,
                padding: EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  try {
                    String insurance = liabilityList[index]["data"];
                    // CORRECTED: Use 'keyid' instead of 'id'
                    String id = liabilityList[index]["keyid"].toString();
                    Map<String, dynamic> mpd = jsonDecode(insurance);

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.redAccent.withOpacity(
                                0.1,
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: Colors.redAccent,
                              ),
                            ),
                            title: Text(
                              "${mpd["loan_account"] ?? 'Unknown Account'}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  "Amount: ₹${mpd["amount"] ?? '0'}",
                                  style: TextStyle(fontSize: 14),
                                ),
                                if (mpd["loantype"] != null)
                                  Text(
                                    "Type: ${mpd["loantype"]}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                if (mpd["Closingdate"] != null)
                                  Text(
                                    "Closing Date: ${mpd["Closingdate"]}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () {
                              _navigateToEdit(id, mpd);
                            },
                          ),
                          Divider(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                icon: Icon(Icons.edit, size: 18),
                                label: Text("Edit"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  _navigateToEdit(id, mpd);
                                },
                              ),
                              TextButton.icon(
                                icon: Icon(Icons.delete, size: 18),
                                label: Text("Delete"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  _showDeleteConfirmation(
                                    id,
                                    mpd["loan_account"] ?? "this liability",
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    print("Error displaying liability at index $index: $e");
                    return SizedBox.shrink();
                  }
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddLiability,
        child: Icon(Icons.add),
        tooltip: "Add Liability",
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _navigateToEdit(String id, Map<String, dynamic> liabilityData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiabilityFormPage(id, liabilityData),
      ),
    );

    if (result != null) {
      getAllAccounts();
    }
  }

  void _showDeleteConfirmation(String id, String accountName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text(
            "Do you want to delete the liability for '$accountName'?\n\nThis action cannot be undone.",
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first
                await _deleteLiability(id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteLiability(String id) async {
    try {
      // CORRECTED: Use deleteData with correct parameter order (tableName, id)
      int result = await DatabaseHelper().deleteData(
        "TABLE_LIABILITY",
        int.parse(id),
      );

      if (result > 0) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Liability deleted successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Refresh the list
        getAllAccounts();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete liability"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error deleting liability: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
        );
    }
  }
}
