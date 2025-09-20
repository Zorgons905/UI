import 'package:dokie/features/2a_task/data/models/task.dart';
import 'package:dokie/features/2a_task/domain/task_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'delete_confirmation_dialog.dart';

class EditTaskBottomSheet extends StatefulWidget {
  final Task task;
  const EditTaskBottomSheet({super.key, required this.task});

  @override
  State<EditTaskBottomSheet> createState() => _EditTaskBottomSheetState();
}

class _EditTaskBottomSheetState extends State<EditTaskBottomSheet> {
  double _progressValue = 0.0;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? taskId;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _attachmentController = TextEditingController();

  late String _initialTitle;
  late String _initialDesc;
  late String _initialAttachment;
  late double _initialProgress;
  late DateTime _initialDate;
  late TimeOfDay _initialTime;

  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    taskId = widget.task.id;

    _progressValue = widget.task.progress / 100;

    // Menggunakan property yang benar dari Task model
    _titleController.text = widget.task.taskName;
    _notesController.text = widget.task.taskDesc ?? '';
    _attachmentController.text = widget.task.taskAttachment ?? '';

    // parsing tanggal & waktu
    _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.task.date);
    final timeParts = widget.task.time.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    _initialTitle = widget.task.taskName;
    _initialDesc = widget.task.taskDesc ?? '';
    _initialAttachment = widget.task.taskAttachment ?? '';
    _initialProgress = _progressValue;
    _initialDate = _selectedDate!;
    _initialTime = _selectedTime!;

    _titleController.addListener(_checkForChanges);
    _notesController.addListener(_checkForChanges);
    _attachmentController.addListener(_checkForChanges);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _checkForChanges();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      _checkForChanges();
    }
  }

  String getFormattedDateTime() {
    if (_selectedDate == null || _selectedTime == null) {
      return 'EEE, dd MMM yyyy\nHH:mm AM';
    }
    final date = DateFormat('EEE, dd MMM yyyy').format(_selectedDate!);
    final hour = _selectedTime!.hourOfPeriod.toString().padLeft(2, '0');
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$date\n$hour:$minute $period';
  }

  Future<bool> saveTaskUpdate() async {
    try {
      final updatedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final hour = _selectedTime!.hour.toString().padLeft(2, '0');
      final minute = _selectedTime!.minute.toString().padLeft(2, '0');
      final time24H = '$hour:$minute';
      final progressPercent = (_progressValue * 100).round();

      final updatedTask = Task(
        id: widget.task.id,
        taskName: _titleController.text,
        taskDesc: _notesController.text.isEmpty ? null : _notesController.text,
        taskGroupId: widget.task.taskGroupId, // Tetap sama
        date: updatedDate,
        time: time24H,
        progress: progressPercent,
        taskAttachment:
            _attachmentController.text.isEmpty
                ? null
                : _attachmentController.text,
      );

      await TaskHelper.updateTask(updatedTask);
      return true;
    } catch (e) {
      debugPrint("Error update task: $e");
      return false;
    }
  }

  void _checkForChanges() {
    final titleChanged = _titleController.text != _initialTitle;
    final descChanged = _notesController.text != _initialDesc;
    final attachmentChanged = _attachmentController.text != _initialAttachment;
    final progressChanged = _progressValue != _initialProgress;
    final dateChanged = _selectedDate != _initialDate;
    final timeChanged = _selectedTime != _initialTime;

    final changed =
        titleChanged ||
        descChanged ||
        attachmentChanged ||
        progressChanged ||
        dateChanged ||
        timeChanged;

    if (_hasChanged != changed) {
      setState(() {
        _hasChanged = changed;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Task Title", // appString.taskTitle
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final confirmed = await deleteConfirmationDialog(
                      context,
                      widget.task,
                      null,
                      null,
                      null,
                    );

                    if (confirmed) {
                      await TaskHelper.deleteTask(widget.task.id);
                      Navigator.of(context).pop({'action': 'delete'});
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today),
              title: Text("Deadline"), // appString.deadline
              trailing: Text(
                getFormattedDateTime(),
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () async {
                await _selectDate(context);
                await _selectTime(context);
              },
            ),

            // Notes
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.note),
              title: TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: "Add notes...", // appString.addNotesHint
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),

            // Attachment
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_file),
              title: TextField(
                controller: _attachmentController,
                decoration: InputDecoration(
                  hintText: "Add your link...", // appString.addYourLinkHint
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
              trailing:
                  _attachmentController.text.isNotEmpty
                      ? InkWell(
                        onTap: () => _launchURL(_attachmentController.text),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xff7E1AD1),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.link,
                            size: 16,
                            color: Color(0xff7E1AD1),
                          ),
                        ),
                      )
                      : null,
            ),

            const SizedBox(height: 16),

            // Progress
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Progress", // appString.progress
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.green.withAlpha(51),
                      thumbColor: Colors.green,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _progressValue,
                      min: 0,
                      max: 1,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() {
                          _progressValue = value;
                        });
                        _checkForChanges();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(_progressValue * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      "Cancel", // appString.cancel
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _hasChanged
                            ? () async {
                              if (_selectedDate != null &&
                                  _selectedTime != null) {
                                final success = await saveTaskUpdate();
                                if (success) {
                                  Navigator.of(
                                    context,
                                  ).pop({'action': 'update'});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Failed to update task", // appString.failedUpdatingTaskNotifier
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Please select deadline", // appString.selectDeadlineNotifier
                                    ),
                                  ),
                                );
                              }
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _hasChanged
                              ? const Color.fromARGB(255, 126, 26, 209)
                              : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      "Save", // appString.save
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
  }
}
