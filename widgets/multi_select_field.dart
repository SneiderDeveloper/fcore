import 'package:flutter/material.dart';

import 'app_button.dart';
import 'app_checkbox.dart';
import 'app_chip.dart';

class SelectOption {
  const SelectOption({required this.value, required this.label});

  final String value;
  final String label;
}

class MultiSelectField extends StatelessWidget {
  const MultiSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.values,
    required this.onChanged,
    this.hintText,
    this.enabled = true,
  });

  final String label;
  final List<SelectOption> options;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String? hintText;
  final bool enabled;

  static const Color _borderColor = Color(0xFFC6D2DE);

  List<String> get _selectedLabels => options
    .where((option) => values.contains(option.value))
    .map((option) => option.label)
    .toList();

  Future<void> _openOptions(BuildContext context) async {
    final selection = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (_) => _MultiSelectSheet(
        title: label,
        options: options,
        values: values,
      ),
    );

    if (selection != null) {
      onChanged(selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = values.isEmpty;

    return InkWell(
      onTap: enabled ? () => _openOptions(context) : null,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        isEmpty: isEmpty,
        decoration: InputDecoration(
          enabled: enabled,
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF40556C), fontSize: 13),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF8A9BB0),
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF40556C),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _borderColor, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E5ED)),
          ),
        ),
        child: isEmpty
            ? const SizedBox(height: 24)
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final selectedLabel in _selectedLabels)
                      AppChip(
                        label: selectedLabel,
                        backgroundColor: const Color(0xFFE5F6FF),
                        textColor: const Color(0xFF215783),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MultiSelectSheet extends StatefulWidget {
  const _MultiSelectSheet({
    required this.title,
    required this.options,
    required this.values,
  });

  final String title;
  final List<SelectOption> options;
  final List<String> values;

  @override
  State<_MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<_MultiSelectSheet> {
  late final Set<String> _selected = {...widget.values};

  void _toggle(String value) {
    setState(() {
      if (!_selected.remove(value)) {
        _selected.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC6D2DE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Color(0xFF162F48),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_selected.isNotEmpty)
                TextButton(
                  onPressed: () => setState(_selected.clear),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Color(0xFF2292C7)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (_, index) {
                final option = widget.options[index];
                return InkWell(
                  onTap: () => _toggle(option.value),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: AppCheckbox(
                      value: _selected.contains(option.value),
                      title: option.label,
                      onChanged: (_) => _toggle(option.value),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop(_selected.toList()),
          ),
        ],
      ),
    );
  }
}
