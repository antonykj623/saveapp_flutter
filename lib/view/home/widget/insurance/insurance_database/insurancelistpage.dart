import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

import 'addinsurance.dart';

class InsuranceListPage extends StatefulWidget {
  @override
  _InsuranceListPageState createState() => _InsuranceListPageState();
}

class _InsuranceListPageState extends State<InsuranceListPage> {
  List<Map<String, dynamic>> insuranceList = [];
  bool isLoading = true;

  Future<void> _navigateToAddInsurance() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InsuranceFormPage("0", {})),
    );

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
        "TABLE_INSURANCE",
      );

      setState(() {
        insuranceList = mpd;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading insurance: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insurances"),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : insuranceList.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No insurance records found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: insuranceList.length,
                padding: EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  try {
                    String insurance = insuranceList[index]["data"];
                    // FIXED: Use 'keyid' instead of 'id'
                    String id = insuranceList[index]["keyid"].toString();
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
                              backgroundColor: Colors.blueAccent.withOpacity(
                                0.1,
                              ),
                              child: Icon(
                                Icons.shield,
                                color: Colors.blueAccent,
                              ),
                            ),
                            title: Text(
                              "${mpd["account"] ?? 'Unknown Account'}",
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
                                  "Premium Amount: ₹${mpd["amount"] ?? '0'}",
                                  style: TextStyle(fontSize: 14),
                                ),
                                if (mpd["insurancetype"] != null)
                                  Text(
                                    "Type: ${mpd["insurancetype"]}",
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
                                    mpd["account"] ?? "this insurance",
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    print("Error displaying insurance at index $index: $e");
                    return SizedBox.shrink();
                  }
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddInsurance,
        child: Icon(Icons.add),
        tooltip: "Add Insurance",
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _navigateToEdit(String id, Map<String, dynamic> insuranceData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsuranceFormPage(id, insuranceData),
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
            "Do you want to delete the insurance for '$accountName'?\n\nThis action cannot be undone.",
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
        "TABLE_INSURANCE",
        int.parse(id),
      );

      if (result > 0) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Insurance deleted successfully"),
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
            content: Text("Failed to delete insurance"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error deleting insurance: $e");
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
