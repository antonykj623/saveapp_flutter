import 'package:flutter/material.dart';

extension SnackbarExtension on BuildContext {
  void replaceSnackbar({required Widget content, Color? color}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: content,
          backgroundColor: color ?? Colors.black87,
          duration: Duration(seconds: 2),
        ),
      );
  }
}