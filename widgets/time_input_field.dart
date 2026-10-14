import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'picker_input_field.dart';

/// Time-only counterpart of `DateInputField`.
class TimeInputField extends StatelessWidget {
  const TimeInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.placeholder,
  });

  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final String? placeholder;

  Future<void> openPicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    onChanged(picked);
  }

  String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    return DateFormat('h:mm a').format(DateTime(2000, 1, 1, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return PickerInputField(
      label: label,
      icon: Icons.access_time_outlined,
      value: _formatTime(value),
      placeholder: placeholder ?? 'Select time',
      onTap: () => openPicker(context),
    );
  }
}
