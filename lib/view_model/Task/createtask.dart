import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/Task/notification_service/notification.dart';

class TaskFormPage extends StatefulWidget {
  final Map<String, dynamic> mpp;
  final String tid;

  const TaskFormPage(this.mpp, this.tid);

  @override
  State<TaskFormPage> createState() => _TaskFormPageState(mpp, tid);
}

class _TaskFormPageState extends State<TaskFormPage>
    with SingleTickerProviderStateMixin {
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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

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
        status =
            mpp["status"] == 0
                ? "Initial"
                : mpp["status"] == 1
                ? "Completed"
                : "Postponed";

        DateTime dtf = DateFormat("hh:mm a").parse(mpp["time"]);
        _selectedTime = TimeOfDay(hour: dtf.hour, minute: dtf.minute);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  bool validateData() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar("Please enter task name", Colors.red);
      return false;
    }
    if (_selectedDate == null) {
      _showSnackBar("Please select task date", Colors.red);
      return false;
    }
    if (_selectedTime == null) {
      _showSnackBar("Please select task time", Colors.red);
      return false;
    }
    if (_remindDate == null) {
      _showSnackBar("Please select remind date", Colors.red);
      return false;
    }
    if (_repeat != "One Time" && _remindDateUpto == null) {
      _showSnackBar("Please select remind date up to", Colors.red);
      return false;
    }
    if (_repeat != "One Time" && _remindDateUpto!.isBefore(_remindDate!)) {
      _showSnackBar("Remind date up to must be after remind date", Colors.red);
      return false;
    }
    return true;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _scheduleNotificationForTask(
    int taskId,
    String taskName,
    DateTime remindDate,
    TimeOfDay remindTime,
  ) async {
    try {
      final notificationDateTime = DateTime(
        remindDate.year,
        remindDate.month,
        remindDate.day,
        remindTime.hour,
        remindTime.minute,
      );

      if (notificationDateTime.isAfter(DateTime.now())) {
        final success = await TaskNotificationService.scheduleTaskNotification(
          taskId: taskId,
          taskName: taskName,
          remindDateTime: notificationDateTime,
        );

        if (success) {
          debugPrint(
            '✅ Notification scheduled for Task ID: $taskId at $notificationDateTime',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }

  Future<void> _insertTasks(
    DatabaseHelper dbHelper,
    DateFormat formatter,
  ) async {
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
    int insertedId = await dbHelper.insert(mp, "TABLE_TASK");

    await _scheduleNotificationForTask(
      insertedId,
      _nameController.text,
      _remindDate!,
      _selectedTime!,
    );

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
        int recurringId = await dbHelper.insert(recurringMp, "TABLE_TASK");

        await _scheduleNotificationForTask(
          recurringId, 
          _nameController.text,
          calendar1,
          _selectedTime!,
        );
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          mpp.isEmpty ? "Create Task" : "Edit Task",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop({}),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[50]!, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            "Task Details",
                            Icons.task_alt_rounded,
                            Colors.deepPurple,
                          ),
                          const SizedBox(height: 16),
                          _buildStyledTextField(
                            controller: _nameController,
                            label: "Task Name",
                            icon: Icons.edit_note_rounded,
                            hint: "Enter task name",
                          ),
                          const SizedBox(height: 16),
                          _buildStyledDateField(
                            label: "Task Date",
                            date: _selectedDate,
                            icon: Icons.calendar_today_rounded,
                            onTap:
                                () => _pickDate(context, (date) {
                                  setState(() => _selectedDate = date);
                                }),
                          ),
                          const SizedBox(height: 16),
                          _buildStyledTimeField(
                            label: "Task Time",
                            time: _selectedTime,
                            icon: Icons.access_time_rounded,
                            onTap: () => _pickTime(context),
                          ),
                          if (mpp.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildStyledDropdown(
                              value: status,
                              items: statusData,
                              label: "Status",
                              icon: Icons.flag_rounded,
                              onChanged:
                                  (value) => setState(() => status = value!),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            "Reminder Settings",
                            Icons.notifications_active_rounded,
                            Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          _buildStyledDateField(
                            label: "Remind Date",
                            date: _remindDate,
                            icon: Icons.notification_add_rounded,
                            onTap:
                                () => _pickDate(context, (date) {
                                  setState(() => _remindDate = date);
                                }),
                          ),
                          const SizedBox(height: 16),
                          _buildStyledDropdown(
                            value: _repeat,
                            items: repeatOptions,
                            label: "Repeat",
                            icon: Icons.repeat_rounded,
                            onChanged:
                                (value) => setState(() => _repeat = value!),
                          ),
                          if (_repeat != "One Time") ...[
                            const SizedBox(height: 16),
                            _buildStyledDateField(
                              label: "Remind Until",
                              date: _remindDateUpto,
                              icon: Icons.event_repeat_rounded,
                              onTap:
                                  () => _pickDate(context, (date) {
                                    setState(() => _remindDateUpto = date);
                                  }),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.9), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledDateField({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          suffixIcon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: Colors.deepPurple,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        controller: TextEditingController(
          text: date == null ? "" : DateFormat("dd-MM-yyyy").format(date),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStyledTimeField({
    required String label,
    required TimeOfDay? time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          suffixIcon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: Colors.deepPurple,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        controller: TextEditingController(
          text: time == null ? "" : time.format(context),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStyledDropdown({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.arrow_drop_down_rounded,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          if (!validateData()) return;

          try {
            final formatter = DateFormat("dd-MM-yyyy");
            final dbHelper = DatabaseHelper();

            if (mpp.isNotEmpty && tid != "0") {
              Map<String, dynamic> task = {
                "name": _nameController.text,
                "date": formatter.format(_selectedDate!),
                "time": _selectedTime!.format(context),
                "reminddate": formatter.format(_remindDate!),
                "remindPeriod": _repeat,
                "status":
                    status == "Initial"
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
                await TaskNotificationService.cancelTaskNotification(
                  int.parse(tid),
                );

                if (status != "Completed") {
                  await _scheduleNotificationForTask(
                    int.parse(tid),
                    _nameController.text,
                    _remindDate!,
                    _selectedTime!,
                  );
                }

                _showSnackBar("✓ Task Updated Successfully", Colors.green);
                Navigator.of(context).pop({"updated": true});
              }
            } else {
              await _insertTasks(dbHelper, formatter);
              _showSnackBar(
                _repeat == "One Time"
                    ? "✓ Task Saved Successfully"
                    : "✓ Tasks Saved with Reminders",
                Colors.green,
              );
              Navigator.of(context).pop({"inserted": true});
            }
          } catch (e, stackTrace) {
            _showSnackBar("Error: $e", Colors.red);
            debugPrint("Error: $e\n$stackTrace");
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save_rounded, size: 28),
            const SizedBox(width: 12),
            Text(
              mpp.isEmpty ? "Save Task" : "Update Task",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
