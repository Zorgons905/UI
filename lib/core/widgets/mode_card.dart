import 'package:flutter/material.dart';

class ModeCard extends StatelessWidget {
  final bool isRunning;
  final bool isBreak;
  final int focusDurationMinutes;
  final int breakDurationMinutes;
  final int totalSections;

  const ModeCard({
    super.key,
    required this.isRunning,
    required this.isBreak,
    required this.focusDurationMinutes,
    required this.breakDurationMinutes,
    required this.totalSections,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRunning) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoItem('$focusDurationMinutes min', Colors.deepPurple),
              _infoItem('$breakDurationMinutes min', Colors.green),
              _infoItem('$totalSections intervals', Colors.blue),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isBreak ? 'Break' : 'Focus Mode',
              style: TextStyle(
                color: isBreak? Colors.green : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: isBreak ? Colors.green : Colors.deepPurple,
                  size: 12,
                ),
                SizedBox(width: 8),
                Text(
                  '${isBreak ? breakDurationMinutes : focusDurationMinutes} min',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}