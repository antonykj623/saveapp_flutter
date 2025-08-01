import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/view/home/widget/delete_account/conformAcccount.dart';
import 'package:new_project_2025/view/home/widget/delete_account/customAlertbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertToConfirmScreen extends StatefulWidget {
  @override
  _AlertToConfirmScreenState createState() => _AlertToConfirmScreenState();
}

class _AlertToConfirmScreenState extends State<AlertToConfirmScreen>
    with TickerProviderStateMixin {
  bool showConfirmScreen = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDeleteAlert();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _showDeleteAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return CustomAlertDialog(
          onYesPressed: () {
            setState(() {
              showConfirmScreen = true;
            });
            _slideController.forward();
            Navigator.of(context).pop();
          },
          onNoPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          if (showConfirmScreen)
            SlideTransition(
              position: _slideAnimation,
              child: ConfirmAccountScreen(),
            ),
        ],
      ),
    );
  }
}
