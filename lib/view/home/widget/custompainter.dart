import 'package:flutter/material.dart';

class SaveLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path path = Path();
    
   
    path.moveTo(size.width * 0.3, size.height * 0.2);
    path.lineTo(size.width * 0.7, size.height * 0.2);
    path.lineTo(size.width * 0.7, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.3, size.height * 0.4);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}