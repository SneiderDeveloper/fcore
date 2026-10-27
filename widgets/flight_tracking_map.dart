import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'flight_tracking_map/flight_map_image.dart';
import 'flight_tracking_map/flight_map_style.dart';
import 'flight_tracking_map/flight_tracking_map_viewer.dart';
import 'flight_tracking_map/map_control_button.dart';

// FlightAware map of a tracked flight. It is a static picture, so the inline
// preview shows the whole route and opens a full screen viewer with zoom.
class FlightTrackingMap extends StatelessWidget {
  const FlightTrackingMap({
    super.key,
    required this.image,
    this.errorMessage = 'Flight map not available',
    this.fullScreenTitle = 'Flight Map',
  });

  final Uint8List image;
  final String errorMessage;
  final String fullScreenTitle;

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlightTrackingMapViewer(
          image: image,
          errorMessage: errorMessage,
          title: fullScreenTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Semantics(
          button: true,
          label: 'Open the flight map in full screen',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openFullScreen(context),
            child: FlightMapImage(image: image, errorMessage: errorMessage),
          ),
        ),
        Positioned(
          right: kFlightMapControlsInset,
          bottom: kFlightMapControlsInset,
          child: MapControlButton(
            icon: Icons.open_in_full,
            tooltip: 'Expand map',
            onPressed: () => _openFullScreen(context),
          ),
        ),
      ],
    );
  }
}
