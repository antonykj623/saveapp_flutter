import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
import 'package:new_project_2025/view_model/assets/assetaccount.dart';
import 'package:new_project_2025/view_model/assets/reminddates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:file_picker/file_picker.dart';

class AssetFormPage extends StatefulWidget {
  String id;
  Map map;

  AssetFormPage(this.id, this.map);

  @override
  _AssetFormPageState createState() => _AssetFormPageState(this.id, this.map);
}

class _AssetFormPageState extends State<AssetFormPage> {
  String id;
  Map map;

  _AssetFormPageState(this.id, this.map);

  List<dynamic> fileiddata = [];

  AssetAccount? selectedAsset;
  String accountsetupid = "0";
  TextEditingController openingBalanceController = TextEditingController();
  DateTime? purchaseDate;
  TextEditingController remarksController = TextEditingController();

  List<AssetAccount> assetTypes = [];
  List<RemindDates> rmdates = [];
  List<PlatformFile> _files = [];

  // Get authorization token from SharedPreferences
  Future<String> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return (token != null && token.isNotEmpty) ? token : "";
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        purchaseDate = date;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllAccounts();
    setupData();
  }

  setupData() {
    if (map.length > 0) {
      String rdate = map["remind_date"];
      List<dynamic> mps = jsonDecode(rdate);

      for (Map<String, dynamic> rm in mps) {
        RemindDates rmdates1 = new RemindDates();
        rmdates1.date = rm["date"];
        rmdates1.description = rm["description"];
        setState(() {
          rmdates.add(rmdates1);
        });
      }

      setState(() {
        fileiddata = jsonDecode(map["files"]);
        purchaseDate = new DateFormat(
          "dd/MM/yyyy",
        ).parse(map["purchase_date"].toString());
        remarksController.text = map["remarks"].toString();

        // ✅ FIX: Set the opening balance from the asset data (not from account settings)
        if (map["amount"] != null) {
          openingBalanceController.text = map["amount"].toString();
          print("✅ Opening balance set from asset data: ${map["amount"]}");
        }
      });
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _files.addAll(result.files);
      });
    }
  }

  getAllAccounts() async {
    List<Map<String, dynamic>> mpd = await new DatabaseHelper().getAllData(
      "TABLE_ACCOUNTSETTINGS",
    );
    List<AssetAccount> mapName = [];

    for (int i = 0; i < mpd.length; i++) {
      String account = mpd[i]["data"];
      Map<String, dynamic> mpp = jsonDecode(account);

      if (mpp["Accounttype"].toString().compareTo("Asset Account") == 0) {
        AssetAccount iacc = new AssetAccount();
        iacc.id =
            mpd[i]["keyid"].toString(); // ✅ FIX: Changed from "id" to "keyid"
        iacc.data = mpp["Accountname"].toString();
        iacc.jsondata = account;
        mapName.add(iacc);
      }
    }

    setState(() {
      assetTypes = mapName;
      if (assetTypes.isNotEmpty) {
        if (map.length > 0) {
          // ✅ EDITING MODE - Load asset data
          accountsetupid = map["assetid"];
          print("📝 Editing mode - Asset ID: $accountsetupid");

          bool foundAsset = false;
          for (int i = 0; i < assetTypes.length; i++) {
            if (assetTypes[i].id.toString().compareTo(accountsetupid) == 0) {
              selectedAsset = assetTypes[i];
              accountsetupid = selectedAsset!.id;
              foundAsset = true;

              // ✅ FIX: Don't override the opening balance if we're editing
              // The balance should come from the asset data, not the account settings
              if (openingBalanceController.text.isEmpty) {
                // Get balance from map first, then fallback to account settings
                if (map["amount"] != null &&
                    map["amount"].toString().isNotEmpty) {
                  openingBalanceController.text = map["amount"].toString();
                  print("✅ Opening balance from asset data: ${map["amount"]}");
                } else {
                  Map<String, dynamic> mpp = jsonDecode(
                    selectedAsset!.jsondata,
                  );
                  String amount =
                      mpp["Amount"]?.toString() ??
                      mpp["OpeningBalance"]?.toString() ??
                      "0";
                  openingBalanceController.text = amount;
                  print("✅ Opening balance from account settings: $amount");
                }
              } else {
                print(
                  "✅ Opening balance already set: ${openingBalanceController.text}",
                );
              }
              break;
            }
          }

          // ✅ If asset not found, select first one
          if (!foundAsset && assetTypes.isNotEmpty) {
            print(
              "⚠️ Asset ID $accountsetupid not found, selecting first asset",
            );
            selectedAsset = assetTypes[0];
            accountsetupid = selectedAsset!.id;
          }
        } else {
          // ✅ NEW ASSET MODE - Use account settings amount
          selectedAsset = assetTypes[0];
          accountsetupid = selectedAsset!.id;
          Map<String, dynamic> mpp = jsonDecode(selectedAsset!.jsondata);

          // Get amount from account settings - try multiple possible field names
          String amount = "0";
          if (mpp["Amount"] != null) {
            amount = mpp["Amount"].toString();
          } else if (mpp["OpeningBalance"] != null) {
            amount = mpp["OpeningBalance"].toString();
          }

          openingBalanceController.text = amount;
          print("✅ New asset - Opening balance: $amount");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(map.length > 0 ? "Edit Asset" : "Add Asset"),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<AssetAccount>(
                          value: selectedAsset,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Asset Account",
                          ),
                          hint: Text('Select Asset'),
                          items:
                              assetTypes.map((asset) {
                                return DropdownMenuItem(
                                  value: asset,
                                  child: Text(asset.data),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAsset = value;
                              accountsetupid = selectedAsset!.id;

                              // ✅ When dropdown changes, update balance only if not editing
                              if (map.length == 0) {
                                Map<String, dynamic> mpp = jsonDecode(
                                  selectedAsset!.jsondata,
                                );
                                String amount =
                                    mpp["Amount"]?.toString() ??
                                    mpp["OpeningBalance"]?.toString() ??
                                    "0";
                                openingBalanceController.text = amount;
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("account_type", "Asset Account");
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Addaccountsdet(),
                            ),
                          );
                          if (result != null || result == null) {
                            getAllAccounts();
                          }
                        },
                        child: Icon(Icons.add),
                        tooltip: "Add New Asset Account",
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: openingBalanceController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Opening Balance",
                      border: OutlineInputBorder(),
                      prefixText: "₹ ",
                      hintText: "Enter amount",
                    ),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Date of Purchase",
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            purchaseDate == null
                                ? 'Select Date of Purchase'
                                : "${purchaseDate!.day}/${purchaseDate!.month}/${purchaseDate!.year}",
                            style: TextStyle(
                              color:
                                  purchaseDate == null
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (rmdates.length > 0) {
                        _showListDialog();
                      } else {
                        _showReminderDialog(new RemindDates());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      (rmdates.length == 0)
                          ? "Set Remind Dates"
                          : "View Remind Dates (${rmdates.length})",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (map.length > 0) {
                        (fileiddata.length == 0)
                            ? _pickFiles()
                            : _pickExistingngFilesAndShowDialog();
                      } else {
                        (_files.length == 0)
                            ? _pickFiles()
                            : _pickFilesAndShowDialog();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      (fileiddata.length == 0)
                          ? ((_files.length > 0)
                              ? "View Documents (${_files.length})"
                              : "Upload Documents")
                          : "View Documents (${fileiddata.length})",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: remarksController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Enter Remarks",
                      border: OutlineInputBorder(),
                      hintText: "Add any additional notes...",
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
            flex: 3,
          ),
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: FractionalOffset.center,
                  child: Container(
                    width: 150,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal, Colors.green],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (purchaseDate != null) {
                          if (rmdates.length > 0) {
                            if (openingBalanceController.text
                                .trim()
                                .isNotEmpty) {
                              _uploadUserDocuments();
                            } else {
                              showMyAlertDialog(
                                context,
                                "Missing Information",
                                "Please enter opening balance",
                              );
                            }
                          } else {
                            showMyAlertDialog(
                              context,
                              "Missing Information",
                              "Please select remind dates",
                            );
                          }
                        } else {
                          showMyAlertDialog(
                            context,
                            "Missing Information",
                            "Please select purchase date",
                          );
                        }
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            flex: 1,
          ),
        ],
      ),
    );
  }

  void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  _uploadUserDocuments() async {
    String authToken = await getAuthToken();
    String urldata =
        "https://mysaving.in/IntegraAccount/api/uploadUserDocuments.php?timestamp=" +
        DateTime.now().microsecondsSinceEpoch.toString();

    if (map.length == 0) {
      for (int i = 0; i < _files.length; i++) {
        showProgressDialog(context);
        File file = File(_files[i].path!);
        var uri = Uri.parse(urldata);
        var request = http.MultipartRequest('POST', uri);

        request.headers.addAll({"Authorization": authToken});
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          print("Upload successful");
          String responseBody = await response.stream.bytesToString();
          var js = jsonDecode(responseBody);
          if (js["status"].toString().compareTo("1") == 0) {
            String fileid = js["fileid"].toString();
            fileiddata.add(fileid);
          }
          Navigator.pop(context);
        } else {
          print("Upload failed: ${response.statusCode}");
          Navigator.pop(context);
        }
      }

      List<Map<String, String>> mpsd = [];
      for (RemindDates rm in rmdates) {
        Map<String, String> m = new HashMap();
        m["description"] = rm.description;
        m["date"] = rm.date;
        mpsd.add(m);
      }

      Map<String, dynamic> jsonObject = {
        "assetid": selectedAsset!.id,
        "assetname": selectedAsset!.data,
        "amount": openingBalanceController.text,
        "purchase_date":
            "${purchaseDate!.day}/${purchaseDate!.month}/${purchaseDate!.year}",
        "remind_date": jsonEncode(mpsd),
        "files": jsonEncode(fileiddata),
        "remarks": remarksController.text,
      };

      String jsonString = jsonEncode(jsonObject);
      Map<String, dynamic> mm1 = {"data": jsonString};
      new DatabaseHelper().insert(mm1, "TABLE_ASSET");

      Map<String, dynamic> task = {
        "name": selectedAsset!.data,
        "date":
            "${purchaseDate!.day}/${purchaseDate!.month}/${purchaseDate!.year}",
        "time": TimeOfDay.now().format(context),
        "status": 0,
        "reminddate":
            "${purchaseDate!.day}/${purchaseDate!.month}/${purchaseDate!.year}",
        "remindPeriod": "One Time",
        "reminddateupto":
            "${purchaseDate!.day}/${purchaseDate!.month}/${purchaseDate!.year}",
      };

      Map<String, dynamic> mp = new HashMap();
      String jsonTask = jsonEncode(task);
      mp["data"] = jsonTask;
      new DatabaseHelper().insert(mp, "TABLE_TASK");

      Map<String, dynamic> mpp = jsonDecode(selectedAsset!.jsondata);
      mpp["Amount"] = openingBalanceController.text.toString();
      Map<String, dynamic> acc = {"data": jsonEncode(mpp)};
      new DatabaseHelper().update(
        acc,
        selectedAsset!.id,
        "TABLE_ACCOUNTSETTINGS",
      );

      setState(() {
        purchaseDate = null;
        remarksController.clear();
        openingBalanceController.clear();
      });

      Navigator.of(context).pop({"success": true});
    } else {
      for (int i = 0; i < _files.length; i++) {
        showProgressDialog(context);
        File file = File(_files[i].path!);
        var uri = Uri.parse(urldata);
        var request = http.MultipartRequest('POST', uri);

        request.headers.addAll({"Authorization": authToken});
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          print("Upload successful");
          String responseBody = await response.stream.bytesToString();
          var js = jsonDecode(responseBody);
          if (js["status"].toString().compareTo("1") == 0) {
            String fileid = js["fileid"].toString();
            fileiddata.add(fileid);
          }
          Navigator.pop(context);
        } else {
          print("Upload failed: ${response.statusCode}");
          Navigator.pop(context);
        }
      }

      List<Map<String, String>> mpsd = [];
      for (RemindDates rm in rmdates) {
        Map<String, String> m = new HashMap();
        m["description"] = rm.description;
        m["date"] = rm.date;
        mpsd.add(m);
      }

      Map<String, dynamic> jsonObject = {
        "assetid": selectedAsset!.id,
        "assetname": selectedAsset!.data,
        "amount": openingBalanceController.text,
        "purchase_date":
            "${purchaseDate!.day}/${purchaseDate!.month}/${purchaseDate!.year}",
        "remind_date": jsonEncode(mpsd),
        "files": jsonEncode(fileiddata),
        "remarks": remarksController.text,
      };

      String jsonString = jsonEncode(jsonObject);
      Map<String, dynamic> mm1 = {"data": jsonString};
      new DatabaseHelper().update(mm1, id, "TABLE_ASSET");

      Map<String, dynamic> mpp = jsonDecode(selectedAsset!.jsondata);
      mpp["Amount"] = openingBalanceController.text.toString();
      Map<String, dynamic> acc = {"data": jsonEncode(mpp)};
      new DatabaseHelper().update(
        acc,
        selectedAsset!.id,
        "TABLE_ACCOUNTSETTINGS",
      );

      setState(() {
        purchaseDate = null;
        remarksController.clear();
        openingBalanceController.clear();
      });

      Navigator.of(context).pop({"success": true});
    }
  }

  Future<void> _pickExistingngFilesAndShowDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Selected Files"),
              content: Container(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: fileiddata.length,
                  itemBuilder: (context, index) {
                    final file = fileiddata[index];
                    return ListTile(
                      leading: Icon(
                        Icons.insert_drive_file,
                        color: Colors.blue,
                      ),
                      title: Text(file),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setStateDialog(() {
                            fileiddata.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(allowMultiple: false, type: FileType.any);

                    if (result != null) {
                      _files.addAll(result.files);
                      for (int i = 0; i < _files.length; i++) {
                        showProgressDialog(context);

                        String authToken = await getAuthToken();
                        File file = File(_files[i].path!);
                        var uri = Uri.parse(
                          "https://mysaving.in/IntegraAccount/api/uploadUserDocuments.php?timestamp=" +
                              DateTime.now().microsecondsSinceEpoch.toString(),
                        );
                        var request = http.MultipartRequest('POST', uri);

                        request.headers.addAll({"Authorization": authToken});
                        request.files.add(
                          await http.MultipartFile.fromPath('file', file.path),
                        );

                        var response = await request.send();
                        Navigator.pop(context);

                        if (response.statusCode == 200) {
                          print("Upload successful");
                          String responseBody =
                              await response.stream.bytesToString();
                          var js = jsonDecode(responseBody);
                          if (js["status"] == 1) {
                            String fileid = js["fileid"].toString();
                            setStateDialog(() {
                              fileiddata.add(fileid);
                            });
                          }
                          Navigator.pop(context);
                        } else {
                          print("Upload failed: ${response.statusCode}");
                        }
                      }
                    }
                  },
                  child: Text("Add New"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickFilesAndShowDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Selected Files"),
              content: Container(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    return ListTile(
                      leading: Icon(
                        Icons.insert_drive_file,
                        color: Colors.blue,
                      ),
                      title: Text(file.name),
                      subtitle: Text(
                        "${(file.size / 1024).toStringAsFixed(2)} KB",
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setStateDialog(() {
                            _files.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _pickFiles();
                    setStateDialog(() {});
                  },
                  child: Text("Add New"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showReminderDialog(RemindDates reminddate) async {
    DateTime? selectedDate = null;
    if (reminddate.date.isEmpty) {
      selectedDate = DateTime.now();
    } else {
      selectedDate = DateFormat('dd-MM-yyyy').parse(reminddate.date);
    }
    final TextEditingController _descController = TextEditingController();
    if (reminddate.description.isEmpty) {
      _descController.clear();
    } else {
      _descController.text = reminddate.description;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              (reminddate.date.isEmpty)
                  ? Text("Add Reminder")
                  : Text("Edit Reminder"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Date: ${DateFormat('dd-MM-yyyy').format(selectedDate!)}",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Text("Pick Date"),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_descController.text.trim().isNotEmpty) {
                  RemindDates remindmdates = new RemindDates();
                  remindmdates.description = _descController.text;
                  remindmdates.date =
                      "${DateFormat('dd-MM-yyyy').format(selectedDate!)}";

                  setState(() {
                    if (reminddate.date.isEmpty) {
                      rmdates.add(remindmdates);
                    } else {
                      rmdates.remove(reminddate);
                      rmdates.add(remindmdates);
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showListDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Remind Dates"),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: rmdates.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      rmdates[index].date + "\n" + rmdates[index].description,
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.pop(context, rmdates[index]);
                      },
                      icon: Icon(Icons.edit),
                    ),
                    onTap: () {
                      Navigator.pop(context, rmdates[index]);
                    },
                  ),
                  elevation: 5,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showReminderDialog(new RemindDates());
              },
              child: Text("Add New"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    ).then((selectedItem) {
      if (selectedItem != null) {
        _showReminderDialog(selectedItem);
      }
    });
  }

  void showMyAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
