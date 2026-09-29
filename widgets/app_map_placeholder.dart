import 'package:flutter/material.dart';

const Color _kMapBackgroundColor = Color(0xFFEFF4F8);
const Color _kMessageColor = Color(0xFF718499);

// Fills the space of a map while it loads or when it can't be shown.
class AppMapPlaceholder extends StatelessWidget {
  const AppMapPlaceholder({
    super.key,
    required IconData this.icon,
    required String this.message,
  }) : isLoading = false;

  const AppMapPlaceholder.loading({super.key})
    : icon = null,
      message = null,
      isLoading = true;

  final IconData? icon;
  final String? message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _kMapBackgroundColor,
      child: Center(
        child: isLoading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: _kMessageColor),
                const SizedBox(height: 12),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _kMessageColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
