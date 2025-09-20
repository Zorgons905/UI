import "package:dokie/core/widgets/interfaces.dart";
import "package:dokie/core/widgets/calendar.dart";
import "package:dokie/core/widgets/clock.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController taskNameController = TextEditingController(
    text: "PPT Multiperceptron",
  );
  final TextEditingController dateController = TextEditingController(
    text: "Thu, 17 Sep 2025",
  );
  final TextEditingController timeController = TextEditingController(
    text: "23:59",
  );
  final TextEditingController notesController = TextEditingController(
    text:
        "Dikumpulkan dalam bentuk PPT disertai link google collab, di sethol diberi nama file (nrp_nama_tugas10)",
  );
  final TextEditingController attachmentNameController =
      TextEditingController();
  final TextEditingController attachmentLinkController =
      TextEditingController();

  String selectedReminder = "No Reminder";
  String selectedRepeat = "No Repeat";
  double progressValue = 80.0;

  // Calendar and Clock visibility states
  bool showCalendar = false;
  bool showClock = false;
  DateTime? selectedDate;
  String? selectedTime;

  // Error states for validation
  String? taskNameError;
  String? deadlineError;
  String? attachmentNameError;
  String? attachmentLinkError;

  List<Map<String, String>> attachments = [
    {"name": "Drive Untuk Data Mining", "link": "https://drive.google.com/..."},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize selected date from initial text
    _parseInitialDate();
    _parseInitialTime();
  }

  void _parseInitialDate() {
    try {
      // Parse "Thu, 17 Sep 2025" format
      String dateText = dateController.text;
      if (dateText.isNotEmpty) {
        // Simple parsing - you might want to use more robust date parsing
        List<String> parts = dateText.split(' ');
        if (parts.length >= 4) {
          int day = int.parse(parts[1].replaceAll(',', ''));
          String monthStr = parts[2];
          int year = int.parse(parts[3]);

          Map<String, int> months = {
            'Jan': 1,
            'Feb': 2,
            'Mar': 3,
            'Apr': 4,
            'May': 5,
            'Jun': 6,
            'Jul': 7,
            'Aug': 8,
            'Sep': 9,
            'Oct': 10,
            'Nov': 11,
            'Dec': 12,
          };

          int month = months[monthStr] ?? 1;
          selectedDate = DateTime(year, month, day);
        }
      }
    } catch (e) {
      selectedDate = DateTime.now();
    }
  }

  void _parseInitialTime() {
    selectedTime = timeController.text.isNotEmpty ? timeController.text : null;
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      dateController.text = _formatDate(date);
      // Clear deadline error when date is selected
      deadlineError = null;
    });
  }

  void _onTimeChanged(String time) {
    setState(() {
      selectedTime = time;
      timeController.text = time;
      // Clear deadline error when time is selected
      deadlineError = null;
    });
  }

  void _onDateFieldTap() {
    setState(() {
      showCalendar = !showCalendar;
      if (showCalendar) {
        showClock = false; // Hide clock if calendar is shown
      }
    });
  }

  void _onTimeFieldTap() {
    setState(() {
      showClock = !showClock;
      if (showClock) {
        showCalendar = false; // Hide calendar if clock is shown
      }
    });
  }

  void _addAttachment() {
    // Reset error states
    setState(() {
      attachmentNameError = null;
      attachmentLinkError = null;
    });

    // Validate attachment fields
    if (attachmentNameController.text.trim().isEmpty) {
      setState(() {
        attachmentNameError = "Attachment name is required";
      });
      return;
    }

    if (attachmentLinkController.text.trim().isEmpty) {
      setState(() {
        attachmentLinkError = "Link is required";
      });
      return;
    }

    // Add attachment if validation passes
    setState(() {
      attachments.add({
        "name": attachmentNameController.text.trim(),
        "link": attachmentLinkController.text.trim(),
      });
    });

    attachmentNameController.clear();
    attachmentLinkController.clear();
  }

  void _removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      // Reset all errors
      taskNameError = null;
      deadlineError = null;

      // Validate task name
      if (taskNameController.text.trim().isEmpty) {
        taskNameError = "Task name is required";
        isValid = false;
      }

      // Validate deadline
      if (dateController.text.trim().isEmpty ||
          timeController.text.trim().isEmpty) {
        deadlineError = "Both date and time are required";
        isValid = false;
      }
    });

    return isValid;
  }

  void _saveTask() {
    if (_validateForm()) {
      // Hide calendar and clock
      setState(() {
        showCalendar = false;
        showClock = false;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task saved successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Add Task",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Name Field
            buildTextFormField(
              label: "Task Name",
              controller: taskNameController,
              hintText: "Enter task name",
              required: true,
              errorText: taskNameError,
              onChanged: () {
                // Clear error when user types
                if (taskNameError != null) {
                  setState(() {
                    taskNameError = null;
                  });
                }
              },
            ),
            SizedBox(height: 12),

            // Deadline Field
            buildDeadlineField(
              label: "Deadline",
              dateController: dateController,
              timeController: timeController,
              required: true,
              onDateTap: _onDateFieldTap,
              onTimeTap: _onTimeFieldTap,
              errorText: deadlineError,
            ),
            SizedBox(height: 12),

            // Calendar Widget (conditional)
            if (showCalendar) ...[
              Calendar(isHomePage: false, onDateSelected: _onDateSelected),
              SizedBox(height: 12),
            ],

            // Clock Widget (conditional)
            if (showClock) ...[
              Clock(onTimeChanged: _onTimeChanged, initialTime: selectedTime),
              SizedBox(height: 12),
            ],

            buildSlider(
              label: "Progress",
              value: progressValue,
              onChanged: (value) {
                setState(() {
                  progressValue = value;
                });
              },
              context: context,
            ),
            SizedBox(height: 12),

            buildDropdown(
              label: "Reminder",
              value: selectedReminder,
              options: [
                "No Reminder",
                "5 Minutes Before",
                "1 Hour Before",
                "1 Day Before",
              ],
              onChanged: (value) {
                setState(() {
                  selectedReminder = value;
                });
              },
            ),
            SizedBox(height: 12),

            // Repeat Dropdown
            buildDropdown(
              label: "Repeat",
              value: selectedRepeat,
              options: ["No Repeat", "Daily", "Weekly", "Monthly", "Yearly"],
              onChanged: (value) {
                setState(() {
                  selectedRepeat = value;
                });
              },
            ),
            SizedBox(height: 12),

            // Notes Field
            buildTextFormField(
              label: "Notes",
              controller: notesController,
              hintText: "Add notes...",
              maxLines: 4,
            ),
            SizedBox(height: 12),

            // Updated Attachment Section with validation
            buildAttachmentSection(
              attachments: attachments,
              attachmentNameController: attachmentNameController,
              attachmentLinkController: attachmentLinkController,
              onAddAttachment: _addAttachment,
              onRemoveAttachment: _removeAttachment,
              nameErrorText: attachmentNameError,
              linkErrorText: attachmentLinkError,
            ),
            SizedBox(height: 16),

            buildButton(
              text: "Save Changes",
              onPressed: _saveTask,
              backgroundColor: Color(0xFF7B6EF2),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
