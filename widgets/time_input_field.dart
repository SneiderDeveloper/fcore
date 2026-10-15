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
    this.validator,
  });

  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final String? placeholder;

  /// When set, the field joins the enclosing [Form] and shows the
  /// validation message under it.
  final FormFieldValidator<TimeOfDay>? validator;

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

  Widget _buildPicker(BuildContext context, {String? errorText}) {
    return PickerInputField(
      label: label,
      icon: Icons.access_time_outlined,
      value: _formatTime(value),
      placeholder: placeholder ?? 'Select time',
      errorText: errorText,
      onTap: () => openPicker(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validator = this.validator;
    if (validator == null) return _buildPicker(context);

    return FormField<TimeOfDay>(
      // Keeps the validator in sync with the value picked outside the form.
      key: ValueKey(value),
      initialValue: value,
      validator: validator,
      builder: (field) => _buildPicker(context, errorText: field.errorText),
    );
  }
}
