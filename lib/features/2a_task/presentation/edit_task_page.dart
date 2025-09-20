import "package:dokie/core/widgets/interfaces.dart";
import "package:flutter/material.dart";

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

  String selectedReminder = "Once";
  double progressValue = 80.0;

  List<Map<String, String>> attachments = [
    {"name": "Drive Untuk Data Mining", "link": "https://drive.google.com/..."},
  ];

  void _addAttachment() {
    if (attachmentNameController.text.isNotEmpty &&
        attachmentLinkController.text.isNotEmpty) {
      setState(() {
        attachments.add({
          "name": attachmentNameController.text,
          "link": attachmentLinkController.text,
        });
      });
      attachmentNameController.clear();
      attachmentLinkController.clear();
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
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
            buildTextFormField(
              label: "Task Name",
              controller: taskNameController,
              hintText: "Enter task name",
              required: true,
            ),
            SizedBox(height: 12),

            // Deadline field (Date + Time)
            buildDeadlineField(
              label: "Deadline",
              dateController: dateController,
              timeController: timeController,
              required: true,
            ),
            SizedBox(height: 12),

            // Progress slider
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

            // Reminder dropdown
            buildDropdown(
              label: "Reminder",
              value: selectedReminder,
              options: ["Repeat", "Once", "Daily", "Weekly"],
              onChanged: (value) {
                setState(() {
                  selectedReminder = value;
                });
              },
            ),
            SizedBox(height: 12),

            buildTextFormField(
              label: "Notes",
              controller: notesController,
              hintText: "Add notes...",
              maxLines: 4,
            ),
            SizedBox(height: 12),

            // Attachment section
            buildAttachmentSection(
              attachments: attachments,
              attachmentNameController: attachmentNameController,
              attachmentLinkController: attachmentLinkController,
              onAddAttachment: _addAttachment,
              onRemoveAttachment: _removeAttachment,
            ),
            SizedBox(height: 16),

            // Save button
            buildButton(
              text: "Save Changes",
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task updated successfully!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              backgroundColor: Colors.purple,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
