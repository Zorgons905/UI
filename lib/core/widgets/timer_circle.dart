import 'dart:math';
import 'package:flutter/material.dart';

class TimerCircle extends StatelessWidget {
  final double progress;
  final String timeText;
  final Color color;

  const TimerCircle({
    super.key,
    required this.progress,
    required this.timeText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: Size(200, 200),
        painter: TimerPainter(
          progress: progress,
          color: color,
        ),
        child: Center(
          child: Text(
            timeText,
            style: TextStyle(
              fontSize: 60,
            ),
          ),
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color color;

  TimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint baseCircle = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final Paint progressCircle = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;

    canvas.drawCircle(center, radius, baseCircle);

    final double sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressCircle,
    );

    final double angle = -pi / 2 + sweepAngle;
    final Offset orbitDotPosition = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    final Paint orbitDot = Paint()..color = color;
    canvas.drawCircle(orbitDotPosition, 10, orbitDot);
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}