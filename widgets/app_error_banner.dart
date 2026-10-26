import 'package:flutter/material.dart';

const Color _kIconColor = Color(0xFFEF5350);
const Color _kMessageColor = Color(0xFF40556C);
const Color _kActionColor = Color(0xFF2292C7);
const Color _kBackgroundColor = Color(0xFFFFF3F3);
const Color _kBorderColor = Color(0xFFFFD9D9);

/// Single-row error for a section that could not be loaded, inside a list or
/// form. For a whole view, use `AppErrorState`.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;

  /// Hides the "Retry" button when null.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
      decoration: BoxDecoration(
        color: _kBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorderColor, width: 1.5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, size: 22, color: _kIconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: _kMessageColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: _kActionColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 36),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
