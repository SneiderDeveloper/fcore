import 'package:flutter/material.dart';

import '../app_button.dart';

// Icon button laid over a map, same look as the back button of
// NavigationAppBar.
class MapControlButton extends StatelessWidget {
  const MapControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  static const double _size = 45;

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AppButton(
        leadingIcon: icon,
        iconSize: 24,
        onPressed: onPressed,
        variant: AppButtonVariant.filledLight,
        backgroundColor: Colors.white,
        width: _size,
        height: _size,
      ),
    );
  }
}
