import 'package:flutter/material.dart';
import 'app_confirm_dialog.dart';

class StatusTag extends StatelessWidget {
  const StatusTag({
    super.key,
    required this.label,
    required this.color,
    this.description,
  });

  final String label;
  final Color color;
  final String? description;

  bool get _hasDescription => description?.trim().isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    final tag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    if (!_hasDescription) return tag;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => AppConfirmDialog.show(
        context,
        title: label,
        message: description!.trim(),
        confirmLabel: 'Got it',
        showCancel: false,
      ),
      child: tag,
    );
  }
}
