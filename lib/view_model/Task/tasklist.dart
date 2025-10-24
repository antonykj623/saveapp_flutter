import 'dart:collection';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

import 'createtask.dart';

class TaskListPage extends StatefulWidget {
  final String title;
  final bool isReportPage;
  const TaskListPage({Key? key, this.isReportPage = false, this.title = "Task"})
    : super(key: key);
  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  DateTime? _fromDate;
  DateTime? _toDate;
  List<Map<String, dynamic>> tasks = [];

  Future<void> _pickDate(Function(DateTime) onSelected) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
    });

    final formatter = DateFormat("dd-MM-yyyy");
    String fromdate = formatter.format(_fromDate!);
    String todate = formatter.format(_toDate!);

    loadFilteredTasks(fromdate, todate);
  }

  Future<void> loadFilteredTasks(
    String currentDateStr,
    String endDateStr,
  ) async {
    List<Map<String, dynamic>> mp = await DatabaseHelper().getAllData(
      "TABLE_TASK",
    );
    List<Map<String, dynamic>> commonDataSelected = [];
    final formatter = DateFormat("dd-MM-yyyy");

    DateTime currentDate = formatter.parse(currentDateStr);
    DateTime endDate = formatter.parse(endDateStr);

    for (Map<String, dynamic> cm in mp) {
      try {
        Map<String, dynamic> jsonObject = jsonDecode(cm["data"]);
        String date1 = jsonObject["date"];
        DateTime cmDate = formatter.parse(date1);

        if (endDate.isAfter(currentDate) ||
            endDate.isAtSameMomentAs(currentDate)) {
          if (cmDate.isAtSameMomentAs(currentDate) &&
              cmDate.isBefore(endDate)) {
            commonDataSelected.add({"id": cm["keyid"], "data": cm["data"]});
          } else if (cmDate.isAfter(currentDate) &&
              cmDate.isAtSameMomentAs(endDate)) {
            commonDataSelected.add({"id": cm["keyid"], "data": cm["data"]});
          } else if (cmDate.isAtSameMomentAs(currentDate) &&
              cmDate.isAtSameMomentAs(endDate)) {
            commonDataSelected.add({"id": cm["keyid"], "data": cm["data"]});
          } else if (cmDate.isAfter(currentDate) && cmDate.isBefore(endDate)) {
            commonDataSelected.add({"id": cm["keyid"], "data": cm["data"]});
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Select Date Properly")));
        }
      } catch (e) {
        debugPrint("Error parsing task: $e");
      }
    }

    if (commonDataSelected.isNotEmpty) {
      commonDataSelected.sort((lhs, rhs) {
        try {
          DateTime cmdate1 = formatter.parse(jsonDecode(lhs["data"])["date"]);
          DateTime cmdate2 = formatter.parse(jsonDecode(rhs["data"])["date"]);
          return cmdate1.compareTo(cmdate2);
        } catch (e) {
          return 0;
        }
      });
    }

    setState(() {
      tasks = commonDataSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              readOnly: true,
              decoration: const InputDecoration(
                hintText: "Select From Date",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text:
                    _fromDate == null
                        ? ""
                        : "${_fromDate!.day}-${_fromDate!.month}-${_fromDate!.year}",
              ),
              onTap:
                  () => _pickDate((date) {
                    setState(() {
                      _fromDate = date;
                    });
                  }),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              decoration: const InputDecoration(
                hintText: "Select To Date",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text:
                    _toDate == null
                        ? ""
                        : "${_toDate!.day}-${_toDate!.month}-${_toDate!.year}",
              ),
              onTap:
                  () => _pickDate((date) {
                    setState(() {
                      _toDate = date;
                    });
                  }),
            ),
            const SizedBox(height: 20),
            Container(
              width: 150,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.green],
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  final formatter = DateFormat("dd-MM-yyyy");
                  String fromdate = formatter.format(_fromDate!);
                  String todate = formatter.format(_toDate!);
                  loadFilteredTasks(fromdate, todate);
                },
                child: const Text("Search", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  Map<String, dynamic> mp = jsonDecode(task["data"]);

                  return GestureDetector(
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRow("Task", mp["name"]!),
                            _buildRow("Date", mp["date"]!),
                            _buildRow("Time", mp["time"]!),
                            _buildRow("Remind Date", mp["reminddate"]!),
                            _buildRow(
                              "Status",
                              (mp["status"] == 0)
                                  ? "Initial"
                                  : (mp["status"] == 1)
                                  ? "Completed"
                                  : "Postponed",
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  TaskFormPage(mp, task["id"].toString()),
                        ),
                      );

                      if (result != null) {
                        final formatter = DateFormat("dd-MM-yyyy");
                        String fromdate = formatter.format(_fromDate!);
                        String todate = formatter.format(_toDate!);
                        loadFilteredTasks(fromdate, todate);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          widget.isReportPage
              ? null // hide button if opened from report page
              : FloatingActionButton(
                backgroundColor: Colors.pink,
                child: const Icon(Icons.add),
                onPressed: () async {
                  Map<String, dynamic> mp = {};
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskFormPage(mp, "0"),
                    ),
                  );

                  if (result != null) {
                    final formatter = DateFormat("dd-MM-yyyy");
                    String fromdate = formatter.format(_fromDate!);
                    String todate = formatter.format(_toDate!);
                    loadFilteredTasks(fromdate, todate);
                  }
                },
              ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            "$label : ",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
