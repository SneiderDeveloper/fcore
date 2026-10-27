import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../app_map_placeholder.dart';
import 'flight_map_style.dart';

class FlightMapImage extends StatelessWidget {
  const FlightMapImage({
    super.key,
    required this.image,
    required this.errorMessage,
    this.filterQuality = FilterQuality.medium,
  });

  final Uint8List image;
  final String errorMessage;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kFlightMapBackgroundColor,
      child: Image.memory(
        image,
        // The picture holds the whole route, so it has to be shown complete
        // even if that leaves bands on the sides.
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        filterQuality: filterQuality,
        // The bytes don't change, so keep the decoded frame between rebuilds.
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => AppMapPlaceholder(
          icon: Icons.map_outlined,
          message: errorMessage,
        ),
      ),
    );
  }
}
