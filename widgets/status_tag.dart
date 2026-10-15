import 'package:flutter/material.dart';
import 'app_button.dart';

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
      onTap: () => _StatusInfoDialog.show(
        context,
        title: label,
        description: description!.trim(),
      ),
      child: tag,
    );
  }
}

class _StatusInfoDialog extends StatelessWidget {
  const _StatusInfoDialog({required this.title, required this.description});

  final String title;
  final String description;

  static const Color titleColor = Color(0xFF1A2B47);
  static const Color messageColor = Color(0xFF475569);

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _StatusInfoDialog(title: title, description: description),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: titleColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: messageColor, fontSize: 16),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'Got it',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
