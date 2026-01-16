import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
import 'package:new_project_2025/view_model/Task/notification_service/notification.dart';
import 'package:new_project_2025/services/Premium_services/Premium_services.dart';
import 'createtask.dart';

class TaskListPage extends StatefulWidget {
  final String title;
  final bool isReportPage;
  const TaskListPage({Key? key, this.isReportPage = false, this.title = "Task"})
    : super(key: key);
  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>
    with SingleTickerProviderStateMixin {
  DateTime? _fromDate;
  DateTime? _toDate;
  List<Map<String, dynamic>> tasks = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Premium state variables
  bool isCheckingPremium = false;
  PremiumStatus? premiumStatus;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Initialize dates and load tasks after checking premium
    _checkPremiumAndSetup();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPremiumAndSetup() async {
    setState(() => isCheckingPremium = true);
    try {
      final status = await PremiumService().checkPremiumStatus(
        forceRefresh: true,
      );
      setState(() {
        premiumStatus = status;
        isCheckingPremium = false;
      });
    } catch (e) {
      setState(() => isCheckingPremium = false);
    }

    // Keep the original initialization behavior regardless of premium check result
    setState(() {
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
    });

    final formatter = DateFormat("dd-MM-yyyy");
    String fromdate = formatter.format(_fromDate!);
    String todate = formatter.format(_toDate!);

    await loadFilteredTasks(fromdate, todate);
  }

  Future<void> _pickDate(Function(DateTime) onSelected) async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Select Date Properly"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
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

  Future<void> _deleteTask(String taskId, String taskName) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: const [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Delete Task',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text('Are you sure you want to delete "$taskName"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
      );

      if (confirm == true) {
        final dbHelper = DatabaseHelper();
        await TaskNotificationService.cancelTaskNotification(int.parse(taskId));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✓ Task deleted successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        final formatter = DateFormat("dd-MM-yyyy");
        String fromdate = formatter.format(_fromDate!);
        String todate = formatter.format(_toDate!);
        loadFilteredTasks(fromdate, todate);
      }
    } catch (e) {
      debugPrint("Error deleting task: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting task: $e")));
    }
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
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_active_rounded, size: 26),
              onPressed: () async {
                final pending =
                    await TaskNotificationService.getPendingNotifications();
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Row(
                          children: const [
                            Icon(
                              Icons.notifications_active,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Pending Notifications',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        content:
                            pending.isEmpty
                                ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.notifications_off,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No pending notifications',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                                : SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: pending.length,
                                    itemBuilder: (context, index) {
                                      final notif = pending[index];
                                      return Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(
                                                0.1,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.alarm,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          title: Text(
                                            notif.title ?? 'No title',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            notif.body ?? 'No description',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                );
              },
              tooltip: 'View Pending Notifications',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // PREMIUM BANNER (shows when premiumStatus != null)
                    if (premiumStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PremiumService.buildPremiumBanner(
                          context: context,
                          status: premiumStatus!,
                          isChecking: isCheckingPremium,
                          onRefresh: _checkPremiumAndSetup,
                        ),
                      ),

                    _buildDateFilterCard(),
                    const SizedBox(height: 20),
                    Expanded(
                      child:
                          tasks.isEmpty
                              ? _buildEmptyState()
                              : _buildTasksList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay during premium checks
          if (isCheckingPremium)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Verifying Access...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton:
          widget.isReportPage
              ? null
              : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () async {
                    // CHECK PREMIUM BEFORE ALLOWING TO CREATE A NEW TASK
                    setState(() => isCheckingPremium = true);
                    final canAdd = await PremiumService().canAddData(
                      forceRefresh: true,
                    );
                    final status = PremiumService().getCachedStatus();
                    setState(() {
                      isCheckingPremium = false;
                      premiumStatus = status;
                    });

                    if (status != null && status.productId == 2 && !canAdd) {
                      PremiumService.showPremiumExpiredDialog(
                        context,
                        customMessage: 'Premium required to create tasks.',
                      );
                      return;
                    }

                    if (!canAdd) {
                      PremiumService.showPremiumExpiredDialog(
                        context,
                        customMessage: 'Premium required to create tasks.',
                      );
                      return;
                    }

                    // proceed to create task
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
                  icon: const Icon(Icons.add_rounded, size: 28),
                  label: const Text(
                    "New Task",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
    );
  }

  Widget _buildDateFilterCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.deepPurple.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.filter_alt_rounded, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  "Filter Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStyledDateField(
              "From Date",
              _fromDate,
              Icons.calendar_today_rounded,
              () => _pickDate((date) => setState(() => _fromDate = date)),
            ),
            const SizedBox(height: 12),
            _buildStyledDateField(
              "To Date",
              _toDate,
              Icons.event_rounded,
              () => _pickDate((date) => setState(() => _toDate = date)),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.search_rounded, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Search Tasks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledDateField(
    String label,
    DateTime? date,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          suffixIcon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: Colors.deepPurple,
          ),
        ),
        controller: TextEditingController(
          text: date == null ? "" : "${date.day}-${date.month}-${date.year}",
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              size: 80,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first task to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      itemCount: tasks.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final task = tasks[index];
        Map<String, dynamic> mp = jsonDecode(task["data"]);

        Color statusColor =
            mp["status"] == 0
                ? const Color(0xFF4A90E2)
                : mp["status"] == 1
                ? const Color(0xFF7CB342)
                : const Color(0xFFFF7043);

        String statusText =
            mp["status"] == 0
                ? "Initial"
                : mp["status"] == 1
                ? "Completed"
                : "Postponed";

        return Dismissible(
          key: Key(task["id"].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.red, Colors.redAccent],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        SizedBox(width: 10),
                        Text('Delete Task'),
                      ],
                    ),
                    content: Text(
                      'Are you sure you want to delete "${mp["name"]}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
            );
          },
          onDismissed: (direction) async {
            final dbHelper = DatabaseHelper();
            await TaskNotificationService.cancelTaskNotification(
              int.parse(task["id"].toString()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✓ ${mp["name"]} deleted'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          child: GestureDetector(
            onTap: () async {
              // CHECK PREMIUM BEFORE ALLOWING TO EDIT/OPEN TASK (editing may schedule notifications)
              setState(() => isCheckingPremium = true);
              final canAdd = await PremiumService().canAddData(
                forceRefresh: true,
              );
              final status = PremiumService().getCachedStatus();
              setState(() {
                isCheckingPremium = false;
                premiumStatus = status;
              });

              if (status != null && status.productId == 2 && !canAdd) {
                PremiumService.showPremiumExpiredDialog(
                  context,
                  customMessage: 'Premium required to edit tasks.',
                );
                return;
              }

              if (!canAdd) {
                PremiumService.showPremiumExpiredDialog(
                  context,
                  customMessage: 'Premium required to edit tasks.',
                );
                return;
              }

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskFormPage(mp, task["id"].toString()),
                ),
              );

              if (result != null) {
                final formatter = DateFormat("dd-MM-yyyy");
                String fromdate = formatter.format(_fromDate!);
                String todate = formatter.format(_toDate!);
                loadFilteredTasks(fromdate, todate);
              }
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shadowColor: statusColor.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white, statusColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              mp["status"] == 1
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_actions_rounded,
                              color: statusColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mp["name"]!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor.withOpacity(0.8),
                                  statusColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      _buildInfoRow(
                        Icons.calendar_today_rounded,
                        "Date",
                        mp["date"]!,
                        Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.access_time_rounded,
                        "Time",
                        mp["time"]!,
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.notifications_active_rounded,
                        "Remind",
                        mp["reminddate"]!,
                        Colors.purple,
                      ),
                      if (mp.containsKey("remindPeriod") &&
                          mp["remindPeriod"] != "One Time") ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.repeat_rounded,
                          "Repeat",
                          mp["remindPeriod"]!,
                          Colors.green,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
