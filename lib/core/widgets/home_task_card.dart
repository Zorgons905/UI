import 'package:dokie/features/2a_task/data/models/task.dart';
import 'package:flutter/material.dart';

class HomeTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const HomeTaskCard({super.key, required this.task, required this.onTap});

  Color getProgressColor() {
    if (task.progress <= 0.2) {
      return Color(0xFFFF5454);
    } else if (task.progress <= 0.6) {
      return Color(0xFFF2B900);
    } else {
      return Color(0xFF38D300);
    }
  }

  String checkDay(String date) {
    final today = DateTime.now();
    final unknownDay = DateTime.parse(date);
    String dayCategories = "";

    if ((today.year == unknownDay.year) && (today.month == unknownDay.month)) {
      if (today.day == unknownDay.day) {
        dayCategories = "Today";
      } else if ((today.day + 1) == unknownDay.day) {
        dayCategories = "Tomorrow";
      } else if ((today.day - 1) == unknownDay.day) {
        dayCategories = "Yesterday";
      } else {
        dayCategories = date;
      }
    } else {
      dayCategories = date;
    }

    return dayCategories;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.taskName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B6EF2),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${checkDay(task.date)}, ${task.time}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (task.taskDesc != null) ...[
                    SizedBox(height: 4),
                    Text(
                      task.taskDesc!,
                      style: TextStyle(color: Colors.black87, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (task.taskAttachment != null) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Attachment',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: task.progress / 100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              getProgressColor(),
                            ),
                            backgroundColor: Colors.grey[300],
                            minHeight: 8,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${task.progress}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
