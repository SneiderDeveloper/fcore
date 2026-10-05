import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteMapPoint {
  const RouteMapPoint({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
  });

  // Unique within the map, it identifies the marker.
  final String id;
  final LatLng position;

  // Shown in the info window when the marker is tapped.
  final String? title;
  final String? snippet;

  Marker toMarker() => Marker(
    markerId: MarkerId(id),
    position: position,
    infoWindow: InfoWindow(title: title, snippet: snippet),
  );
}

// Google map that places a marker on every point, joins them with a line in
// travel order and frames the camera so all of them fit on screen.
class AppRouteMap extends StatelessWidget {
  const AppRouteMap({
    super.key,
    required this.points,
    this.routeColor = const Color(0xFF2292C7),
  }) : assert(points.length > 0, 'AppRouteMap needs at least one point');

  static const double _singlePointZoom = 11;
  static const double _boundsPadding = 56;

  // Places to show, in travel order.
  final List<RouteMapPoint> points;
  final Color routeColor;

  LatLngBounds get _bounds {
    final latitudes = points.map((p) => p.position.latitude);
    final longitudes = points.map((p) => p.position.longitude);

    return LatLngBounds(
      southwest: LatLng(latitudes.reduce(math.min), longitudes.reduce(math.min)),
      northeast: LatLng(latitudes.reduce(math.max), longitudes.reduce(math.max)),
    );
  }

  Future<void> _frameRoute(GoogleMapController controller) async {
    // A single point is already centered by the initial camera.
    if (points.length == 1) return;

    // The map needs to be laid out before it can frame a bounding box.
    await WidgetsBinding.instance.endOfFrame;
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(_bounds, _boundsPadding),
      );
    } catch (_) {
      // Keep the initial camera if the map was disposed meanwhile.
    }
  }

  @override
  Widget build(BuildContext context) {
    final bounds = _bounds;

    return GoogleMap(
      onMapCreated: _frameRoute,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
          (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
        ),
        zoom: points.length == 1 ? _singlePointZoom : 3,
      ),
      markers: points.map((point) => point.toMarker()).toSet(),
      polylines: {
        if (points.length > 1)
          Polyline(
            polylineId: const PolylineId('route'),
            points: points.map((point) => point.position).toList(),
            color: routeColor,
            width: 3,
            geodesic: true,
          ),
      },
      // Claims the gestures so the map pans even inside a scroll view.
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
      },
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
