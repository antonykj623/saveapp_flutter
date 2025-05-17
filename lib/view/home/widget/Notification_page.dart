import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/app_notification.dart';

class NotificationScreen extends StatelessWidget {
  final List<AppNotification> notifications = [
    AppNotification(
      title: "Order Confirmed",
      message: "Your order #1234 has been confirmed.",
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    AppNotification(
      title: "Delivery Scheduled",
      message: "Your delivery is scheduled for tomorrow at 10 AM.",
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
    ),
    AppNotification(
      title: "Welcome!",
      message: "Thanks for signing up. Enjoy our services.",
      timestamp: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications"), centerTitle: true),
      body:
          notifications.isEmpty
              ? Center(child: Text("No notifications available"))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return ListTile(
                    leading: Icon(Icons.notifications, color: Colors.blue),
                    title: Text(
                      notif.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notif.message),
                    trailing: Text(
                      DateFormat('hh:mm a').format(notif.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              ),
    );
  }
}
