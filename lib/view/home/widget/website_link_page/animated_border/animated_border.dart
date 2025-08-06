// animated_border_widget.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBorderWidget extends StatefulWidget {
  final Widget child;
  final String borderType; // 'electric', 'rainbow', 'fire', 'ocean', 'custom'
  final List<Color>? customColors;
  final double borderWidth;
  final double glowSize;
  final int animationDuration; // in milliseconds
  final BorderRadius? borderRadius;
  final bool isActive; // Controls when animation starts/stops

  const AnimatedBorderWidget({
    Key? key,
    required this.child,
    this.borderType = 'electric',
    this.customColors,
    this.borderWidth = 3.0,
    this.glowSize = 20.0,
    this.animationDuration = 2500,
    this.borderRadius,
    this.isActive = true,
  }) : super(key: key);

  @override
  _AnimatedBorderWidgetState createState() => _AnimatedBorderWidgetState();
}

class _AnimatedBorderWidgetState extends State<AnimatedBorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration),
      vsync: this,
    );

    if (widget.isActive) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedBorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Color> _getGradientColors() {
    if (widget.customColors != null) {
      return widget.customColors!;
    }

    switch (widget.borderType) {
      case 'electric':
        return [
          Colors.transparent,
          Color(0xFF00D4FF).withOpacity(0.3),
          Color(0xFF0099FF).withOpacity(0.6),
          Color(0xFF0066FF),
          Color(0xFF3366FF),
          Color(0xFF6633FF),
          Color(0xFF9933FF),
          Color(0xFFCC33FF),
          Color(0xFF9933FF),
          Color(0xFF6633FF),
          Color(0xFF3366FF),
          Color(0xFF0066FF),
          Colors.transparent,
        ];
      case 'rainbow':
        return [
          Colors.transparent,
          Colors.red.withOpacity(0.3),
          Colors.orange.withOpacity(0.6),
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.indigo,
          Colors.purple,
          Colors.pink,
          Colors.purple,
          Colors.indigo,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.orange.withOpacity(0.6),
          Colors.red.withOpacity(0.3),
          Colors.transparent,
        ];
      case 'fire':
        return [
          Colors.transparent,
          Color(0xFFFF6B35).withOpacity(0.3),
          Color(0xFFFF8C42).withOpacity(0.6),
          Color(0xFFFFA500),
          Color(0xFFFFD700),
          Color(0xFFFF6347),
          Color(0xFFFF4500),
          Color(0xFFDC143C),
          Color(0xFFB22222),
          Color(0xFFDC143C),
          Color(0xFFFF4500),
          Color(0xFFFF6347),
          Color(0xFFFFD700),
          Color(0xFFFFA500),
          Colors.transparent,
        ];
      case 'ocean':
        return [
          Colors.transparent,
          Color(0xFF00CED1).withOpacity(0.3),
          Color(0xFF20B2AA).withOpacity(0.6),
          Color(0xFF008B8B),
          Color(0xFF00FFFF),
          Color(0xFF40E0D0),
          Color(0xFF48D1CC),
          Color(0xFF00CED1),
          Color(0xFF5F9EA0),
          Color(0xFF00CED1),
          Color(0xFF48D1CC),
          Color(0xFF40E0D0),
          Color(0xFF00FFFF),
          Color(0xFF008B8B),
          Colors.transparent,
        ];
      case 'neon':
        return [
          Colors.transparent,
          Color(0xFFFF073A).withOpacity(0.3),
          Color(0xFFFF073A).withOpacity(0.6),
          Color(0xFFFF073A),
          Color(0xFF39FF14),
          Color(0xFF00FFFF),
          Color(0xFFFF1493),
          Color(0xFFFFFF00),
          Color(0xFF9400D3),
          Color(0xFFFFFF00),
          Color(0xFFFF1493),
          Color(0xFF00FFFF),
          Color(0xFF39FF14),
          Color(0xFFFF073A),
          Colors.transparent,
        ];
      default:
        return [Colors.grey.shade300];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomAnimatedBorder(
          borderSize: widget.isActive ? widget.borderWidth : 1.0,
          glowSize: widget.isActive ? widget.glowSize : 0.0,
          gradientColors:
              widget.isActive ? _getGradientColors() : [Colors.grey.shade300],
          animationProgress: _animationController.value,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          child: widget.child,
        );
      },
    );
  }
}

// Custom Animated Border Implementation
class CustomAnimatedBorder extends StatelessWidget {
  final Widget child;
  final double borderSize;
  final double glowSize;
  final List<Color> gradientColors;
  final double animationProgress;
  final BorderRadius borderRadius;

  const CustomAnimatedBorder({
    Key? key,
    required this.child,
    required this.borderSize,
    required this.glowSize,
    required this.gradientColors,
    required this.animationProgress,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow:
            glowSize > 0
                ? [
                  BoxShadow(
                    color:
                        gradientColors.isNotEmpty
                            ? gradientColors[gradientColors.length ~/ 2]
                                .withOpacity(0.8)
                            : Colors.blue.withOpacity(0.8),
                    blurRadius: glowSize,
                    spreadRadius: glowSize / 4,
                  ),
                  BoxShadow(
                    color:
                        gradientColors.isNotEmpty
                            ? gradientColors[gradientColors.length ~/ 3]
                                .withOpacity(0.5)
                            : Colors.blue.withOpacity(0.5),
                    blurRadius: glowSize * 1.5,
                    spreadRadius: glowSize / 3,
                  ),
                  BoxShadow(
                    color:
                        gradientColors.isNotEmpty
                            ? gradientColors[gradientColors.length ~/ 4]
                                .withOpacity(0.3)
                            : Colors.blue.withOpacity(0.3),
                    blurRadius: glowSize * 2,
                    spreadRadius: glowSize / 2,
                  ),
                ]
                : null,
      ),
      child: CustomPaint(
        painter: AnimatedBorderPainter(
          borderSize: borderSize,
          gradientColors: gradientColors,
          animationProgress: animationProgress,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

class AnimatedBorderPainter extends CustomPainter {
  final double borderSize;
  final List<Color> gradientColors;
  final double animationProgress;
  final BorderRadius borderRadius;

  AnimatedBorderPainter({
    required this.borderSize,
    required this.gradientColors,
    required this.animationProgress,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (gradientColors.length <= 1) {
      // Static border for inactive state
      final paint =
          Paint()
            ..color =
                gradientColors.isNotEmpty ? gradientColors.first : Colors.grey
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderSize;

      final rect = Rect.fromLTWH(
        borderSize / 2,
        borderSize / 2,
        size.width - borderSize,
        size.height - borderSize,
      );
      final rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);
      canvas.drawRRect(rrect, paint);
      return;
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, borderRadius.topLeft);
    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics().toList();

    if (pathMetrics.isNotEmpty) {
      final pathMetric = pathMetrics.first;
      final totalLength = pathMetric.length;

      if (totalLength > 0) {
        final trainLength = totalLength * 0.4;
        final trainPosition = (animationProgress * totalLength) % totalLength;

        // Draw main gradient train
        _drawGradientTrain(
          canvas,
          pathMetric,
          totalLength,
          trainLength,
          trainPosition,
        );

        // Draw sparkle effects
        _drawSparkleEffects(
          canvas,
          pathMetric,
          totalLength,
          trainPosition,
          trainLength,
        );

        // Draw trailing glow
        _drawTrailingGlow(
          canvas,
          pathMetric,
          totalLength,
          trainPosition,
          trainLength,
        );
      }
    }
  }

  void _drawGradientTrain(
    Canvas canvas,
    PathMetric pathMetric,
    double totalLength,
    double trainLength,
    double trainPosition,
  ) {
    for (int i = 0; i < gradientColors.length; i++) {
      final segmentLength = trainLength / gradientColors.length;
      final segmentStart =
          (trainPosition - trainLength / 2 + i * segmentLength) % totalLength;
      final segmentEnd = (segmentStart + segmentLength) % totalLength;

      final paint =
          Paint()
            ..color = gradientColors[i]
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderSize
            ..strokeCap = StrokeCap.round;

      try {
        if (segmentStart < segmentEnd && segmentEnd <= totalLength) {
          final segmentPath = pathMetric.extractPath(segmentStart, segmentEnd);
          canvas.drawPath(segmentPath, paint);
        } else if (segmentStart >= 0 && segmentStart < totalLength) {
          if (segmentStart < totalLength) {
            final segmentPath1 = pathMetric.extractPath(
              segmentStart,
              totalLength,
            );
            canvas.drawPath(segmentPath1, paint);
          }
          if (segmentEnd > 0) {
            final segmentPath2 = pathMetric.extractPath(
              0,
              math.min(segmentEnd, totalLength),
            );
            canvas.drawPath(segmentPath2, paint);
          }
        }
      } catch (e) {
        continue;
      }
    }
  }

  void _drawSparkleEffects(
    Canvas canvas,
    PathMetric pathMetric,
    double totalLength,
    double trainPosition,
    double trainLength,
  ) {
    final sparklePositions = [
      (trainPosition + trainLength * 0.2) % totalLength,
      (trainPosition + trainLength * 0.5) % totalLength,
      (trainPosition + trainLength * 0.8) % totalLength,
    ];

    final sparklePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.fill;

    final sparkleGlowPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < sparklePositions.length; i++) {
      final pos = sparklePositions[i];
      try {
        if (pos >= 0 && pos <= totalLength) {
          final tangent = pathMetric.getTangentForOffset(pos);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 5, sparkleGlowPaint);
            canvas.drawCircle(tangent.position, 2, sparklePaint);
          }
        }
      } catch (e) {
        continue;
      }
    }
  }

  void _drawTrailingGlow(
    Canvas canvas,
    PathMetric pathMetric,
    double totalLength,
    double trainPosition,
    double trainLength,
  ) {
    final trailStart = (trainPosition - trainLength * 0.6) % totalLength;
    final trailEnd = (trainPosition - trainLength * 0.3) % totalLength;

    final trailPaint =
        Paint()
          ..color =
              gradientColors.isNotEmpty
                  ? gradientColors[gradientColors.length ~/ 2].withOpacity(0.3)
                  : Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderSize * 1.5
          ..strokeCap = StrokeCap.round;

    try {
      if (trailStart < trailEnd && trailEnd <= totalLength) {
        final trailPath = pathMetric.extractPath(trailStart, trailEnd);
        canvas.drawPath(trailPath, trailPaint);
      }
    } catch (e) {
      // Continue if there's an error
    }
  }

  @override
  bool shouldRepaint(AnimatedBorderPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.borderSize != borderSize ||
        oldDelegate.gradientColors != gradientColors;
  }
}

// Focus-Based Animated TextField Widget
class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String borderType;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const AnimatedTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.borderType = 'electric',
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.keyboardType, required int borderRadius, required Icon prefixIcon, required Color backgroundColor,
  }) : super(key: key);

  @override
  _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBorderWidget(
      borderType: widget.borderType,
      isActive: _isFocused,
      borderWidth: _isFocused ? 3.0 : 1.0,
      glowSize: _isFocused ? 15.0 : 0.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _isFocused ? Colors.white.withOpacity(0.95) : Colors.white,
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(
              color: _isFocused ? Colors.blue[700] : Colors.grey[600],
              fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          style: TextStyle(color: Colors.grey[800], fontSize: 16),
          validator: widget.validator,
        ),
      ),
    );
  }
}
