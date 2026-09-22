import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteMapPoint {
  const RouteMapPoint({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
    this.icon,
  });

  // Unique within the map, it identifies the marker.
  final String id;
  final LatLng position;

  // Shown in the info window when the marker is tapped.
  final String? title;
  final String? snippet;

  // Defaults to the standard Google Maps pin.
  final BitmapDescriptor? icon;

  Marker toMarker() => Marker(
    markerId: MarkerId(id),
    position: position,
    icon: icon ?? BitmapDescriptor.defaultMarker,
    infoWindow: title == null && snippet == null
        ? InfoWindow.noText
        : InfoWindow(title: title, snippet: snippet),
  );
}

// Google map that places a marker on every point, optionally joins them with
// a line, and frames the camera so all of them fit on screen.
class AppRouteMap extends StatefulWidget {
  const AppRouteMap({
    super.key,
    required this.points,
    this.drawRoute = true,
    this.routeColor = const Color(0xFF2292C7),
    this.routeWidth = 3,
    this.boundsPadding = 56,
    this.singlePointZoom = 11,
    this.initialZoom = 4,
    this.zoomControlsEnabled = false,
    this.myLocationButtonEnabled = false,
    this.placeholder,
    this.onMapCreated,
  });

  // Places to show, in travel order.
  final List<RouteMapPoint> points;

  final bool drawRoute;
  final Color routeColor;
  final int routeWidth;

  // Margin in pixels left around the points when framing the camera.
  final double boundsPadding;

  // Zoom used when there is a single point, so there is nothing to frame.
  final double singlePointZoom;

  // Zoom of the first camera position, before the points are framed.
  final double initialZoom;

  final bool zoomControlsEnabled;
  final bool myLocationButtonEnabled;

  // Shown instead of the map while there are no points.
  final Widget? placeholder;

  // Exposes the controller, e.g. to move the camera from the outside.
  final ValueChanged<GoogleMapController>? onMapCreated;

  @override
  State<AppRouteMap> createState() => _AppRouteMapState();
}

class _AppRouteMapState extends State<AppRouteMap> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(AppRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reframe when the places really changed, so a plain rebuild does
    // not undo the panning/zooming the user did.
    if (_signatureOf(widget.points) != _signatureOf(oldWidget.points)) {
      _frameCamera();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  String _signatureOf(List<RouteMapPoint> points) => points
      .map((p) => '${p.id}:${p.position.latitude},${p.position.longitude}')
      .join('|');

  LatLng get _center {
    final latitudes = widget.points.map((p) => p.position.latitude);
    final longitudes = widget.points.map((p) => p.position.longitude);

    return LatLng(
      (latitudes.reduce(math.min) + latitudes.reduce(math.max)) / 2,
      (longitudes.reduce(math.min) + longitudes.reduce(math.max)) / 2,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    widget.onMapCreated?.call(controller);
    _frameCamera();
  }

  void _frameCamera() {
    final controller = _mapController;
    if (controller == null || widget.points.isEmpty) return;

    final CameraUpdate update;
    if (widget.points.length == 1) {
      update = CameraUpdate.newLatLngZoom(
        widget.points.first.position,
        widget.singlePointZoom,
      );
    } else {
      final latitudes = widget.points.map((p) => p.position.latitude);
      final longitudes = widget.points.map((p) => p.position.longitude);
      update = CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            latitudes.reduce(math.min),
            longitudes.reduce(math.min),
          ),
          northeast: LatLng(
            latitudes.reduce(math.max),
            longitudes.reduce(math.max),
          ),
        ),
        widget.boundsPadding,
      );
    }

    // The map needs to be laid out before it can frame a bounding box.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await controller.animateCamera(update);
      } catch (_) {
        // Keep the initial camera position if the map is not ready yet.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return widget.placeholder ?? const SizedBox.shrink();
    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: widget.points.length == 1
          ? widget.singlePointZoom
          : widget.initialZoom,
      ),
      markers: widget.points.map((point) => point.toMarker()).toSet(),
      polylines: {
        if (widget.drawRoute && widget.points.length > 1)
          Polyline(
            polylineId: const PolylineId('app-route-map-route'),
            points: widget.points
              .map((point) => point.position)
              .toList(growable: false),
            color: widget.routeColor,
            width: widget.routeWidth,
          ),
      },
      zoomControlsEnabled: widget.zoomControlsEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
    );
  }
}
