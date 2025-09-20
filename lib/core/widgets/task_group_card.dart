import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TaskGroupCard extends StatelessWidget {
  final String name;
  final String description;
  final int notStartedCount;
  final int ongoingCount;
  final int completedCount;
  final DateTime createdAt;

  const TaskGroupCard({
    super.key,
    required this.name,
    required this.description,
    required this.notStartedCount,
    required this.ongoingCount,
    required this.completedCount,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: 136,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(top: 4, left: 16),
              child: CircularPercentIndicator(
                radius: 30.0,
                lineWidth: 12.0,
                percent: _calculateProgress(),
                animation: true,
                animationDuration: 1200,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.deepPurple,
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      margin: EdgeInsets.only(top: 12, bottom: 4),
                      width: double.infinity,
                      child: AutoSizeText(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7E1AD1),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: Text(
                        description,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.red),
                            SizedBox(width: 4),
                            Text(
                              "${notStartedCount.toString()} Not Started",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.yellow),
                            SizedBox(width: 4),
                            Text(
                              "${ongoingCount.toString()} On Going",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              "${completedCount.toString()} Completed",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.fromLTRB(0, 6, 16, 0),
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Last Updated ${_formatDate()}",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateProgress() {
    final total = notStartedCount + ongoingCount + completedCount;
    if (total == 0) {
      return 0.0;
    }

    final progress = (ongoingCount * 0.5 + completedCount) / total;
    return progress.clamp(0.0, 1.0);
  }

  String _formatDate() {
    final date = DateFormat('d MMMM yyyy HH:mm:ss');
    return date.format(createdAt);
  }
}
