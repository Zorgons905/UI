import '/features/4_focus/data/models/focus_timer.dart';
import '/features/4_focus/domain/focus_timer_helper.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class EditFocus extends StatefulWidget {
  final FocusTimer timer;
  const EditFocus({super.key, required this.timer});

  @override
  State<EditFocus> createState() => _EditFocusState();
}

class _EditFocusState extends State<EditFocus> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController timerNameController;

  int focusTime = 0;
  int breakTime = 0;
  int? selectedSection;
  final List<int> sections = [2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    final timer = widget.timer;
    timerNameController = TextEditingController(text: timer.name);
    focusTime = timer.focusTime;
    breakTime = timer.breakTime;
    selectedSection = timer.section;
  }

  void _decrementTime(String type) {
    setState(() {
      if (type == 'focus' && focusTime > 5) focusTime -= 5;
      if (type == 'break' && breakTime > 5) breakTime -= 5;
    });
  }

  void _incrementTime(String type) {
    setState(() {
      if (type == 'focus' && focusTime < 60) focusTime += 5;
      if (type == 'break' && breakTime < 60) breakTime += 5;
    });
  }

  void _saveData() async {
    if (_formKey.currentState!.validate() && selectedSection != null) {
      final updatedTimer = FocusTimer(
        id: widget.timer.id,
        name: timerNameController.text,
        focusTime: focusTime,
        breakTime: breakTime,
        section: selectedSection!,
        createdAt: widget.timer.createdAt,
      );

      await FocusTimerHelper.updateFocusTimer(updatedTimer);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Timer updated!")));

      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill in all fields")));
    }
  }

  void _discardData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Discard Changes?'),
            content: Text('Are you sure you want to discard your changes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes, Discard'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      Navigator.pop(context, false);
    }
  }

  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTimerNameField() {
    return _buildCardWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Timer Name", style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: timerNameController,
              textAlign: TextAlign.right,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? "Please enter a name"
                          : null,
              decoration: InputDecoration(
                hintText: "Add Name",
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    int time,
    VoidCallback onAdd,
    VoidCallback onRemove,
  ) {
    return _buildCardWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              IconButton(
                onPressed: time > 5 ? onRemove : null,
                icon: Icon(
                  Icons.remove,
                  color: time > 5 ? Colors.black : Colors.grey.shade400,
                ),
              ),
              Text("$time min", style: TextStyle(fontWeight: FontWeight.w500)),
              IconButton(
                onPressed: time < 60 ? onAdd : null,
                icon: Icon(
                  Icons.add,
                  color: time < 60 ? Colors.black : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineDropdownSelector() {
    return _buildCardWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Interval", style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<int>(
                    value: selectedSection,
                    items:
                        sections
                            .map(
                              (e) => DropdownMenuItem<int>(
                                value: e,
                                child: Text("$e intervals"),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() => selectedSection = value),
                    buttonStyleData: ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      height: 40,
                      decoration: BoxDecoration(color: Colors.transparent),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      iconSize: 24,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 30,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: Color(0xFF7E1AD1),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x807E1AD1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Edit Your Focus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTimerNameField(),
                      _buildTimeSelector(
                        "Focus Time",
                        focusTime,
                        () => _incrementTime('focus'),
                        () => _decrementTime('focus'),
                      ),
                      _buildTimeSelector(
                        "Break Time",
                        breakTime,
                        () => _incrementTime('break'),
                        () => _decrementTime('break'),
                      ),
                      _buildInlineDropdownSelector(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _discardData,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text("Discard"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF4D107F),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text("Save"),
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
}
