import '../../features/4_focus/presentation/focus_timer_page.dart';
import 'package:flutter/material.dart';

class FocusModeCard extends StatelessWidget {
  final String title;
  final String focusTimeValue;
  final String breakTimeValue;
  final String sectionValue;

  const FocusModeCard({
    super.key,
    required this.title,
    required this.focusTimeValue,
    required this.breakTimeValue,
    required this.sectionValue,
  });

  int _parseNumberString(String numberString) {
    try {
      final String numericPart = numberString.split(' ')[0];
      return int.parse(numericPart);
    } catch (e) {
      debugPrint("ERROR PARSING '$numberString': $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final int focusDuration = _parseNumberString(focusTimeValue);
        final int breakDuration = _parseNumberString(breakTimeValue);
        final int totalSections = _parseNumberString(sectionValue);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FocusTimerPage(
                  focusModeTitle: title,
                  focusDuration: focusDuration,
                  breakDuration: breakDuration,
                  totalSections: totalSections,
                ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7E1AD1),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTimeIndicator(Colors.deepPurple, focusTimeValue),
                ),
                Expanded(
                  child: _buildTimeIndicator(Colors.green, breakTimeValue),
                ),
                Expanded(child: _buildTimeIndicator(Colors.blue, sectionValue)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeIndicator(Color color, String time) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 5),
        Text(time, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}
