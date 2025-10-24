import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class TaskFormPage extends StatefulWidget {
  final Map<String, dynamic> mpp;
  final String tid;

  TaskFormPage(this.mpp, this.tid);

  @override
  State<TaskFormPage> createState() => _TaskFormPageState(mpp, tid);
}

class _TaskFormPageState extends State<TaskFormPage> {
  final Map<String, dynamic> mpp;
  final String tid;

  _TaskFormPageState(this.mpp, this.tid);

  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _remindDate;
  String _repeat = "One Time";
  DateTime? _remindDateUpto;
  String status = "Initial";

  final List<String> statusData = ["Initial", "Postponed", "Completed"];
  final List<String> repeatOptions = [
    "One Time",
    "Daily",
    "Weekly",
    "Monthly",
    "Quarterly",
    "Half yearly",
    "Yearly",
  ];

  @override
  void initState() {
    super.initState();
    if (mpp.isNotEmpty) {
      setState(() {
        final formatter = DateFormat("dd-MM-yyyy");
        _selectedDate = formatter.parse(mpp["date"].toString());
        _nameController.text = mpp["name"];
        _remindDate = formatter.parse(mpp["reminddate"].toString());

        if (mpp.containsKey("reminddateupto")) {
          _remindDateUpto = formatter.parse(mpp["reminddateupto"].toString());
        }

        _repeat = mpp["remindPeriod"].toString();
        status = mpp["status"] == 0
            ? "Initial"
            : mpp["status"] == 1
                ? "Completed"
                : "Postponed";

        DateTime dtf = DateFormat("hh:mm a").parse(mpp["time"]);
        _selectedTime = TimeOfDay(hour: dtf.hour, minute: dtf.minute);
      });
    }
  }

  Future<void> _pickDate(
    BuildContext context,
    Function(DateTime) onSelected,
  ) async {
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

  Future<void> _pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  bool validateData() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter name")));
      return false;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select date")));
      return false;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select time")));
      return false;
    }
    if (_remindDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select remind date")));
      return false;
    }
    if (_repeat != "One Time" && _remindDateUpto == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select remind date up to")));
      return false;
    }
    if (_repeat != "One Time" && _remindDateUpto!.isBefore(_remindDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Remind date up to must be after remind date"),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _insertTasks(DatabaseHelper dbHelper, DateFormat formatter) async {
    Map<String, dynamic> task = {
      "name": _nameController.text,
      "date": formatter.format(_selectedDate!),
      "time": _selectedTime!.format(context),
      "reminddate": formatter.format(_remindDate!),
      "remindPeriod": _repeat,
      "status": 0,
    };

    if (_repeat != "One Time" && _remindDateUpto != null) {
      task["reminddateupto"] = formatter.format(_remindDateUpto!);
    }

    Map<String, dynamic> mp = {"data": jsonEncode(task)};
    await dbHelper.insert(mp, "TABLE_TASK");

    if (_repeat != "One Time") {
      DateTime calendar1 = _remindDate!;
      DateTime calendarTaskDate = _selectedDate!;
      const Map<String, Duration> repeatDurations = {
        "Daily": Duration(days: 1),
        "Weekly": Duration(days: 7),
        "Monthly": Duration(days: 30),
        "Quarterly": Duration(days: 90),
        "Half yearly": Duration(days: 180),
        "Yearly": Duration(days: 365),
      };

      while (calendar1.isBefore(_remindDateUpto!)) {
        calendar1 = calendar1.add(repeatDurations[_repeat]!);
        calendarTaskDate = calendarTaskDate.add(repeatDurations[_repeat]!);

        if (calendar1.isAfter(_remindDateUpto!)) break;

        Map<String, dynamic> recurringTask = {
          "name": _nameController.text,
          "date": formatter.format(calendarTaskDate),
          "time": _selectedTime!.format(context),
          "reminddate": formatter.format(calendar1),
          "reminddateupto": formatter.format(_remindDateUpto!),
          "remindPeriod": _repeat,
          "status": 0,
        };

        Map<String, dynamic> recurringMp = {"data": jsonEncode(recurringTask)};
        await dbHelper.insert(recurringMp, "TABLE_TASK");
      }
    }

    setState(() {
      _nameController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _remindDate = null;
      _remindDateUpto = null;
      _repeat = "One Time";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Tasks"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop({}),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Select Date",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _pickDate(context, (date) {
                setState(() {
                  _selectedDate = date;
                });
              }),
              controller: TextEditingController(
                text: _selectedDate == null
                    ? ""
                    : DateFormat("dd-MM-yyyy").format(_selectedDate!),
              ),
            ),
            const SizedBox(height: 12),
            if (mpp.isNotEmpty)
              DropdownButtonFormField<String>(
                value: status,
                items: statusData
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Select Time",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () => _pickTime(context),
              controller: TextEditingController(
                text: _selectedTime == null ? "" : _selectedTime!.format(context),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Remind Date",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _pickDate(context, (date) {
                setState(() {
                  _remindDate = date;
                });
              }),
              controller: TextEditingController(
                text: _remindDate == null
                    ? ""
                    : DateFormat("dd-MM-yyyy").format(_remindDate!),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _repeat,
              items: repeatOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _repeat = value!;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            if (_repeat != "One Time")
              TextField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Remind date up to",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(context, (date) {
                  setState(() {
                    _remindDateUpto = date;
                  });
                }),
                controller: TextEditingController(
                  text: _remindDateUpto == null
                      ? ""
                      : DateFormat("dd-MM-yyyy").format(_remindDateUpto!),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.teal,
              ),
              onPressed: () async {
                if (!validateData()) return;

                try {
                  final formatter = DateFormat("dd-MM-yyyy");
                  final dbHelper = DatabaseHelper();

                  if (mpp.isNotEmpty && tid != "0") {
                    // Update existing task
                    Map<String, dynamic> task = {
                      "name": _nameController.text,
                      "date": formatter.format(_selectedDate!),
                      "time": _selectedTime!.format(context),
                      "reminddate": formatter.format(_remindDate!),
                      "remindPeriod": _repeat,
                      "status": status == "Initial"
                          ? 0
                          : status == "Completed"
                              ? 1
                              : 2,
                    };

                    if (_repeat != "One Time" && _remindDateUpto != null) {
                      task["reminddateupto"] = formatter.format(_remindDateUpto!);
                    }

                    Map<String, dynamic> mp = {"data": jsonEncode(task)};
                    int result = await dbHelper.update(mp, tid, "TABLE_TASK");

                    if (result > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Task Updated Successfully"),
                        ),
                      );
                      Navigator.of(context).pop({"updated": true});
                    } else {
                      throw Exception("Failed to update task with ID: $tid");
                    }
                  } else {
                    // Insert new task(s)
                    await _insertTasks(dbHelper, formatter);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Task(s) Saved Successfully"),
                      ),
                    );
                    Navigator.of(context).pop({"inserted": true});
                  }
                } catch (e, stackTrace) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error saving task: $e")),
                  );
                  debugPrint("Error saving task: $e");
                  debugPrint("Stack trace: $stackTrace");
                }
              },
              child: const Text("Save", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}