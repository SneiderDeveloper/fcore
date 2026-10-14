import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'picker_input_field.dart';

class DateInputField extends StatelessWidget {
  const DateInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.format,
    this.includeTime = false,
    this.placeholder,
    this.minDateTime,
    this.onSelectionRejected,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? format;
  final bool includeTime;
  final String? placeholder;

  final DateTime? minDateTime;

  final ValueChanged<DateTime>? onSelectionRejected;

  Future<void> openPicker(BuildContext context) async {
    final now = DateTime.now();
    final min = minDateTime;
    final first = firstDate ?? (min != null ? DateUtils.dateOnly(min) : DateTime(1900));
    final last = lastDate ?? DateTime(2100);

    var initial = value ?? (min != null && min.isAfter(now) ? min : now);
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (pickedDate == null) return;

    if (!includeTime) {
      if (min != null && pickedDate.isBefore(DateUtils.dateOnly(min))) {
        onSelectionRejected?.call(pickedDate);
        return;
      }
      onChanged(pickedDate);
      return;
    }

    if (!context.mounted) {
      if (min != null && pickedDate.isBefore(min)) {
        onSelectionRejected?.call(pickedDate);
      } else {
        onChanged(pickedDate);
      }
      return;
    }

    final initialTime = min != null && DateUtils.isSameDay(pickedDate, min)
      ? TimeOfDay.fromDateTime(min)
      : TimeOfDay.fromDateTime(initial);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    final selected = pickedTime == null
      ? pickedDate
      : DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

    if (min != null && selected.isBefore(min)) {
      onSelectionRejected?.call(selected);
      return;
    }

    onChanged(selected);
  }

  String _daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    return switch (day % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    if (format != null) {
      String valueFormat = DateFormat(format).format(date);
      return valueFormat;
    }

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final suffix = _daySuffix(date.day);
    final datePart = '${months[date.month - 1]} ${date.day}$suffix, ${date.year}';
    if (!includeTime) return datePart;
    return '$datePart - ${DateFormat('h:mm a').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return PickerInputField(
      label: label,
      icon: Icons.calendar_today_outlined,
      value: _formatDate(value),
      placeholder: placeholder ?? 'Select date',
      onTap: () => openPicker(context),
    );
  }
}
