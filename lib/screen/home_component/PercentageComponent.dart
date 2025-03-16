import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../../config/colors.dart';

class PercentageComponent extends StatefulWidget {
  double percentage;

  PercentageComponent({required this.percentage, super.key});

  @override
  State<PercentageComponent> createState() => _PercentageComponentState();
}

class _PercentageComponentState extends State<PercentageComponent> {

  void triggerVibration() async {
    if(await Vibration.hasVibrator() ?? false){
      Vibration.vibrate(duration: 1);

      Vibration.vibrate(pattern: [0,2000,500,2000]);
    }
  }

  @override
  void didUpdateWidget(covariant PercentageComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.percentage < 40){
      triggerVibration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: UI_White,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: widget.percentage),
        duration: Duration(seconds: 2),
        builder: (context, value, child) {
          return CustomPaint(
            painter: CircularProgressPainter(value),
            child: SizedBox(
              width: 150,
              height: 150,
              child: Center(
                child: Text(
                  "${value.toInt()}%",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: UI_Black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double percentage;

  CircularProgressPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint =
    Paint()
      ..color = UI_White
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    Paint progressPaint =
    Paint()
      ..color = UI_Black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 20;

    canvas.drawCircle(center, radius, backgroundPaint);

    double sweepAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}