import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../navigation_app_bar.dart';
import 'flight_map_image.dart';
import 'flight_map_style.dart';
import 'map_zoom_controls.dart';

// Full screen FlightAware map with pinch, pan, double tap and button zoom.
class FlightTrackingMapViewer extends StatefulWidget {
  const FlightTrackingMapViewer({
    super.key,
    required this.image,
    required this.errorMessage,
    required this.title,
  });

  final Uint8List image;
  final String errorMessage;
  final String title;

  @override
  State<FlightTrackingMapViewer> createState() =>
      _FlightTrackingMapViewerState();
}

class _FlightTrackingMapViewerState extends State<FlightTrackingMapViewer>
    with SingleTickerProviderStateMixin {
  static const double _minScale = 1;
  static const double _maxScale = 6;
  static const double _doubleTapScale = 2.5;
  static const double _zoomStep = 1.75;
  // Tolerance for the scale read back from the matrix.
  static const double _scaleEpsilon = 0.01;

  final TransformationController _transformation = TransformationController();
  late final AnimationController _zoomController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..addListener(_onZoomTick);
  late final CurvedAnimation _zoomCurve = CurvedAnimation(
    parent: _zoomController,
    curve: Curves.easeOutCubic,
  );
  Animation<Matrix4>? _zoomAnimation;

  // Size of the area the image is laid out in, the child of the viewer.
  Size _viewport = Size.zero;
  Offset? _doubleTapPosition;

  double get _scale => _transformation.value.getMaxScaleOnAxis();

  Offset get _viewportCenter => _viewport.center(Offset.zero);

  @override
  void dispose() {
    _zoomCurve.dispose();
    _zoomController.dispose();
    _transformation.dispose();
    super.dispose();
  }

  void _onZoomTick() {
    final Animation<Matrix4>? animation = _zoomAnimation;
    if (animation != null) _transformation.value = animation.value;
  }

  // Matrix that scales to [scale] keeping [focalPoint] (viewport coordinates)
  // in place, clamped so the image always covers the viewport.
  Matrix4 _zoomedTo(double scale, Offset focalPoint) {
    final double target = scale.clamp(_minScale, _maxScale);
    final Matrix4 current = _transformation.value;
    final double ratio = target / _scale;
    final double dx =
        focalPoint.dx - (focalPoint.dx - current.entry(0, 3)) * ratio;
    final double dy =
        focalPoint.dy - (focalPoint.dy - current.entry(1, 3)) * ratio;

    return Matrix4.diagonal3Values(target, target, 1)..setTranslationRaw(
      dx.clamp(_viewport.width * (1 - target), 0),
      dy.clamp(_viewport.height * (1 - target), 0),
      0,
    );
  }

  void _animateTo(Matrix4 target) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _zoomController.stop();
      _transformation.value = target;
      return;
    }

    _zoomAnimation = Matrix4Tween(
      begin: _transformation.value,
      end: target,
    ).animate(_zoomCurve);
    _zoomController.forward(from: 0);
  }

  void _zoomIn() => _animateTo(_zoomedTo(_scale * _zoomStep, _viewportCenter));

  void _zoomOut() => _animateTo(_zoomedTo(_scale / _zoomStep, _viewportCenter));

  void _reset() => _animateTo(Matrix4.identity());

  // Zooms into the tapped spot, or back to the whole route when zoomed in.
  void _onDoubleTap() {
    if (_scale > _minScale + _scaleEpsilon) {
      _reset();
      return;
    }

    _animateTo(
      _zoomedTo(_doubleTapScale, _doubleTapPosition ?? _viewportCenter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFlightMapBackgroundColor,
      appBar: NavigationAppBar(title: widget.title),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _viewport = constraints.biggest;

                  return GestureDetector(
                    onDoubleTapDown: (details) =>
                        _doubleTapPosition = details.localPosition,
                    onDoubleTap: _onDoubleTap,
                    child: InteractiveViewer(
                      transformationController: _transformation,
                      minScale: _minScale,
                      maxScale: _maxScale,
                      // A gesture takes over from a running button zoom.
                      onInteractionStart: (_) => _zoomController.stop(),
                      child: FlightMapImage(
                        image: widget.image,
                        errorMessage: widget.errorMessage,
                        // The picture is enlarged, so smooth the upscaling.
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: kFlightMapControlsInset,
              bottom: kFlightMapControlsInset,
              child: ValueListenableBuilder<Matrix4>(
                valueListenable: _transformation,
                builder: (context, matrix, _) {
                  final double scale = matrix.getMaxScaleOnAxis();
                  final bool isZoomedIn = scale > _minScale + _scaleEpsilon;
                  final bool canZoomIn = scale < _maxScale - _scaleEpsilon;

                  return MapZoomControls(
                    onZoomIn: canZoomIn ? _zoomIn : null,
                    onZoomOut: isZoomedIn ? _zoomOut : null,
                    onReset: isZoomedIn ? _reset : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
