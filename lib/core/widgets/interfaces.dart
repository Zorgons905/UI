import 'package:flutter/material.dart';

Widget buildTextFormField({
  String label = '',
  required TextEditingController controller,
  required String hintText,
  bool required = false,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  String? Function(String?)? validator,
  VoidCallback? onTap,
  bool readOnly = false,
  Widget? suffixIcon,
  Widget? prefixIcon,
  String? errorText,
  VoidCallback? onChanged,
  VoidCallback? onFocusLost,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty)
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (required)
              Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
            SizedBox(height: 8),
          ],
        ),

      Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus && onFocusLost != null) {
            onFocusLost();
          }
        },
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onTap: onTap,
          style: TextStyle(fontSize: 12),
          onChanged: onChanged != null ? (_) => onChanged() : null,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            prefixIcon: prefixIcon,
            prefixStyle: TextStyle(fontSize: 12),
            suffixIcon: suffixIcon,
            suffixStyle: TextStyle(fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.blue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey[300]!,
                width: 1,
              ),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          validator: validator,
        ),
      ),
      if (errorText != null)
        Padding(
          padding: EdgeInsets.only(top: 4, left: 4),
          child: Text(
            errorText,
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
    ],
  );
}

Widget buildTextField({
  required ValueChanged<String> controller,
  required String hintText,
  String label = '',
  bool required = false,
  Icon? prefixIcon,
  Icon? suffixIcon,
  String? errorText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty)
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (required) Text(' *', style: TextStyle(color: Colors.red)),
            SizedBox(height: 8),
          ],
        ),
      TextField(
        onChanged: controller,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
          prefixIcon: prefixIcon,
          prefixStyle: TextStyle(fontSize: 12),
          suffixIcon: suffixIcon,
          suffixStyle: TextStyle(fontSize: 12),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: errorText != null ? Colors.red : Colors.blue,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: errorText != null ? Colors.red : Colors.grey[300]!,
              width: 1,
            ),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    ],
  );
}

Widget buildDropdown({
  required String label,
  required String value,
  required List<String> options,
  required ValueChanged<String> onChanged,
  bool required = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty)
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (required) Text(' *', style: TextStyle(color: Colors.red)),
            SizedBox(height: 8),
          ],
        ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            iconSize: 24,
            elevation: 8,
            style: TextStyle(fontSize: 12, color: Colors.black),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items:
                options.asMap().entries.map<DropdownMenuItem<String>>((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: index == 0 ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ),
    ],
  );
}

Widget buildButton({
  required String text,
  required VoidCallback onPressed,
  Color backgroundColor = const Color(0xFF7B6EF2),
  Color textColor = Colors.white,
  Color borderColor = Colors.transparent,
  double borderRadius = 8,
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16),
  bool isFilled = true,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFilled ? backgroundColor : textColor,
        foregroundColor: isFilled ? textColor : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: backgroundColor, width: 2),
        ),
        padding: padding,
        elevation: 2,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

Widget buildSlider({
  required double value,
  required ValueChanged<double> onChanged,
  String label = "",
  double min = 0,
  double max = 100,
  required BuildContext context,
  bool required = false,
}) {
  Color getSliderColor(double val) {
    if (val >= 0 && val <= 30) {
      return Colors.red;
    } else if (val > 30 && val <= 70) {
      return Colors.orange;
    } else if (val > 70 && val <= 100) {
      return Colors.green;
    }
    return Colors.grey;
  }

  Color currentColor = getSliderColor(value);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (required)
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),

          SizedBox(height: 8),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8,
                trackShape: const RoundedRectSliderTrackShape(),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                activeColor: currentColor,
                inactiveColor: Colors.grey.shade300,
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${value.round()}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget buildDeadlineField({
  required String label,
  required TextEditingController dateController,
  required TextEditingController timeController,
  bool required = false,
  VoidCallback? onDateTap,
  VoidCallback? onTimeTap,
  String? errorText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (required)
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),

          SizedBox(height: 8),
        ],
      ),

      Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              style: TextStyle(fontSize: 12),
              controller: dateController,
              readOnly: true,
              onTap: onDateTap,
              decoration: InputDecoration(
                isDense: true,
                hintText: "Select date",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: Colors.grey[600],
                  size: 16,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 16,
                ),
                prefixStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: errorText != null ? Colors.red : Colors.blue,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: errorText != null ? Colors.red : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: timeController,
              readOnly: true,
              style: TextStyle(fontSize: 12),
              onTap: onTimeTap,
              decoration: InputDecoration(
                isDense: true,
                hintText: "Time",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                prefixIcon: Icon(
                  Icons.access_time,
                  color: Colors.grey[600],
                  size: 16,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 16,
                ),
                prefixStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: errorText != null ? Colors.red : Colors.blue,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: errorText != null ? Colors.red : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
        ],
      ),
      if (errorText != null)
        Padding(
          padding: EdgeInsets.only(top: 4, left: 4),
          child: Text(
            errorText,
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
    ],
  );
}

Widget buildAttachmentSection({
  required List<Map<String, String>> attachments,
  required TextEditingController attachmentNameController,
  required TextEditingController attachmentLinkController,
  required VoidCallback onAddAttachment,
  required Function(int) onRemoveAttachment,
  String label = "Attachment",
  String nameHint = "Add Attachment Name",
  String linkHint = "Add link (Google Drive, GitHub, etc.)",
  String addButtonText = "Add",
  String listTitle = "List of Attachment(s)",
  bool required = false,
  String? nameErrorText,
  String? linkErrorText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty)
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (required) Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      SizedBox(height: 8),

      Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              style: TextStyle(fontSize: 12),
              controller: attachmentNameController,
              decoration: InputDecoration(
                isDense: true,
                hintText: nameHint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: nameErrorText != null ? Colors.red : Colors.blue,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color:
                        nameErrorText != null ? Colors.red : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            if (nameErrorText != null)
              Padding(
                padding: EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  nameErrorText,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        style: TextStyle(fontSize: 12),
                        controller: attachmentLinkController,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: linkHint,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: onAddAttachment,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color:
                                  linkErrorText != null
                                      ? Colors.red
                                      : Colors.blue,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color:
                                  linkErrorText != null
                                      ? Colors.red
                                      : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      if (linkErrorText != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            linkErrorText,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            if (attachments.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  listTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 8),
              ...attachments.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> attachment = entry.value;

                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Transform.rotate(
                        angle: -0.785398,
                        child: Icon(
                          Icons.attachment,
                          color: Colors.blue[300],
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment["name"]!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            if (attachment["link"]!.isNotEmpty)
                              Text(
                                attachment["link"]!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[400],
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue[400],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => onRemoveAttachment(index),
                        icon: Icon(Icons.close, color: Colors.red, size: 20),
                        constraints: BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    ],
  );
}
