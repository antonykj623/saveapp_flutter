// Add this class at the bottom of your home_screen.dart file, outside the main widget class

import 'dart:ui';

import 'package:flutter/material.dart';

class NetworthPatternPainter extends CustomPainter {
  final bool isDarkTheme;
  final double animation;

  NetworthPatternPainter({required this.isDarkTheme, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Clamp animation value for safety
    final safeAnimation = animation.clamp(0.0, 1.0);

    final paint =
        Paint()
          ..color = (isDarkTheme ? Colors.white : const Color(0xFF1976D2))
              .withOpacity(0.05 * safeAnimation)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Draw animated circles
    for (int i = 0; i < 3; i++) {
      final radius = (size.width / 4) * (i + 1) * safeAnimation;
      if (radius > 0 && radius.isFinite) {
        canvas.drawCircle(
          Offset(size.width * 0.2, size.height * 0.5),
          radius,
          paint,
        );
      }
    }

    // Draw animated diagonal lines
    paint.strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      final offset = (size.width / 5) * i + (safeAnimation * 20);
      if (offset.isFinite && (offset + size.height * 0.5).isFinite) {
        canvas.drawLine(
          Offset(offset, 0),
          Offset(offset + size.height * 0.5, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant NetworthPatternPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.isDarkTheme != isDarkTheme;
  }
}
