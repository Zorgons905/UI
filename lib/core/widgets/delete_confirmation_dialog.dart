import 'package:dokie/features/2a_task/domain/task_helper.dart';
import 'package:flutter/material.dart' hide Notification;
import '/features/1a_notification/data/models/notification.dart';

import '/features/2a_task/data/models/task.dart';
import '/features/2_group/data/models/task_group.dart';
import '/features/4_focus/data/models/focus_timer.dart';

import '/features/2_group/domain/task_group_helper.dart';
import '/features/4_focus/domain/focus_timer_helper.dart';

Future<bool> deleteConfirmationDialog(
  BuildContext context,
  Task? task,
  TaskGroup? group,
  FocusTimer? timer,
  Notification? notification,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SizedBox(
          width: 349,
          height: 166,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Are you sure you want to delete '
                  "${task!.taskName}"
                  "${timer!.name}"
                  "${group!.name}"
                  "${notification!.title}"
                  '?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 130,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E1AD1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        await TaskHelper.deleteTask(task.id);
                        Navigator.pop(context);

                        await FocusTimerHelper.deleteFocusTimer(timer.id);
                        Navigator.pop(context, true);

                        await TaskGroupHelper.deleteTaskGroup(group.id);
                        Navigator.pop(
                          context,
                          true,
                        ); // Kembali ke TaskGroupPage, trigger refresh
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5454),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}
