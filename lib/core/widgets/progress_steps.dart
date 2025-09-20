import 'package:flutter/material.dart';

class ProgressSteps extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressSteps({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: ProgressStepsPainter(
            currentStep: currentStep,
            totalSteps: totalSteps,
          ),
          size: Size(constraints.maxWidth, 24),
        );
      },
    );
  }
}

class ProgressStepsPainter extends CustomPainter {
  final int currentStep;
  final int totalSteps;

  ProgressStepsPainter({required this.currentStep, required this.totalSteps});

  @override
  void paint(Canvas canvas, Size size) {
    final double stepRadius = 6;
    final Paint inactivePaint = Paint()..color = Colors.grey;
    final Paint activePaint = Paint()..color = Colors.deepPurple;
    final Paint linePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;

    if (totalSteps <= 1) return;

    final double totalWidth = size.width;
    final double spacing = (totalWidth - (totalSteps * stepRadius * 2)) / (totalSteps - 1);

    List<Offset> stepCenters = List.generate(totalSteps, (i) {
      return Offset(stepRadius + i * (2 * stepRadius + spacing), size.height / 2);
    });

    for (int i = 0; i < stepCenters.length - 1; i++) {
      canvas.drawLine(stepCenters[i], stepCenters[i + 1], linePaint);
    }

    for (int i = 0; i < stepCenters.length; i++) {
      canvas.drawCircle(
        stepCenters[i],
        stepRadius,
        i <= currentStep ? activePaint : inactivePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ProgressStepsPainter oldDelegate) {
    return oldDelegate.currentStep != currentStep || oldDelegate.totalSteps != totalSteps;
  }
}
