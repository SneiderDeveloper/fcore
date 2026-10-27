import 'package:flutter/material.dart';

import 'flight_map_style.dart';
import 'map_control_button.dart';

// Zoom in, zoom out and show-all buttons, stacked like a map's controls.
// A null callback disables its button.
class MapZoomControls extends StatelessWidget {
  const MapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MapControlButton(
          icon: Icons.add,
          tooltip: 'Zoom in',
          onPressed: onZoomIn,
        ),
        const SizedBox(height: kFlightMapControlsGap),
        MapControlButton(
          icon: Icons.remove,
          tooltip: 'Zoom out',
          onPressed: onZoomOut,
        ),
        const SizedBox(height: kFlightMapControlsGap),
        MapControlButton(
          icon: Icons.fit_screen_outlined,
          tooltip: 'Show the whole route',
          onPressed: onReset,
        ),
      ],
    );
  }
}
