import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'app_map_placeholder.dart';

class FlightTrackingMap extends StatelessWidget {
  const FlightTrackingMap({
    super.key,
    required this.image,
    this.errorMessage = 'Flight map not available',
  });

  final Uint8List image;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEFF4F8),
      child: Image.memory(
        image,
        // The picture holds the whole route, so it has to be shown complete
        // even if that leaves bands on the sides.
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) => AppMapPlaceholder(
          icon: Icons.map_outlined,
          message: errorMessage,
        ),
      ),
    );
  }
}
