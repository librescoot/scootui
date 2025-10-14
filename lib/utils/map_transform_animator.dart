import 'dart:math' show cos, sin, pi, Point;
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/map/controller/map_controller_impl.dart';
import 'package:flutter_map/src/map/camera/camera.dart';
import 'package:latlong2/latlong.dart';

/// Represents the complete transformation state of the map.
class MapTransform {
  final LatLng center;
  final double zoom;
  final double rotation;
  final Offset offset;

  const MapTransform({
    required this.center,
    required this.zoom,
    required this.rotation,
    required this.offset,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapTransform &&
          runtimeType == other.runtimeType &&
          center == other.center &&
          zoom == other.zoom &&
          rotation == other.rotation &&
          offset == other.offset;

  @override
  int get hashCode =>
      center.hashCode ^ zoom.hashCode ^ rotation.hashCode ^ offset.hashCode;

  @override
  String toString() =>
      'MapTransform(center: $center, zoom: $zoom, rotation: $rotation, offset: $offset)';
}

/// Tween for interpolating between two MapTransform states.
class MapTransformTween extends Tween<MapTransform> {
  MapTransformTween({required super.begin, required super.end});

  @override
  MapTransform lerp(double t) {
    final beginTransform = begin!;
    final endTransform = end!;

    // Interpolate GPS position smoothly (this is the vehicle's actual position)
    final lat = lerpDouble(
      beginTransform.center.latitude,
      endTransform.center.latitude,
      t,
    )!;
    final lng = lerpDouble(
      beginTransform.center.longitude,
      endTransform.center.longitude,
      t,
    )!;

    // Interpolate zoom
    final zoom = lerpDouble(beginTransform.zoom, endTransform.zoom, t)!;

    // Interpolate rotation (handle wrapping around 360 degrees)
    final rotation = _lerpRotation(
      beginTransform.rotation,
      endTransform.rotation,
      t,
    );

    // Interpolate offset
    final offset = Offset.lerp(beginTransform.offset, endTransform.offset, t)!;

    return MapTransform(
      center: LatLng(lat, lng),  // Interpolated GPS position
      zoom: zoom,
      rotation: rotation,
      offset: offset,
    );
  }

  /// Interpolates rotation taking the shortest path around the circle.
  double _lerpRotation(double begin, double end, double t) {
    // Normalize angles to [-180, 180]
    double normalizeAngle(double angle) {
      while (angle > 180) angle -= 360;
      while (angle < -180) angle += 360;
      return angle;
    }

    final normalizedBegin = normalizeAngle(begin);
    final normalizedEnd = normalizeAngle(end);

    double delta = normalizedEnd - normalizedBegin;

    // Take the shortest path
    if (delta > 180) {
      delta -= 360;
    } else if (delta < -180) {
      delta += 360;
    }

    return normalizedBegin + delta * t;
  }
}

/// Animator that applies complete map transformations atomically.
class MapTransformAnimator {
  final MapController mapController;
  final TickerProvider tickerProvider;
  final Duration duration;
  final Curve curve;

  AnimationController? _animationController;
  Animation<MapTransform>? _animation;

  MapTransformAnimator({
    required this.mapController,
    required this.tickerProvider,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  /// Animates to a new map transformation state.
  void animateTo(MapTransform target) {
    // If animation is running, smoothly transition by using current animated value as start
    final isAnimating = _animationController?.isAnimating ?? false;

    MapTransform currentTransform;
    if (isAnimating && _animation != null) {
      // Use current animated state as starting point for smooth continuation
      currentTransform = _animation!.value;
      _animationController?.stop();
      _animationController?.dispose();
    } else {
      // No animation running, start from actual camera state
      final currentCamera = mapController.camera;
      currentTransform = MapTransform(
        center: currentCamera.center,
        zoom: currentCamera.zoom,
        rotation: currentCamera.rotation,
        offset: Offset.zero,
      );
    }

    // Create animation controller
    _animationController = AnimationController(
      duration: duration,
      vsync: tickerProvider,
    );

    // Create tween with curve
    final tween = MapTransformTween(
      begin: currentTransform,
      end: target,
    );

    _animation = tween.animate(CurvedAnimation(
      parent: _animationController!,
      curve: curve,
    ));

    // Listen to animation updates and apply to map
    _animation!.addListener(_updateMap);

    // Start the animation
    _animationController!.forward();
  }

  void _updateMap() {
    if (_animation == null) return;

    final transform = _animation!.value;
    final impl = mapController as MapControllerImpl;
    final camera = mapController.camera;

    // Calculate map center so GPS stays at vehicle icon position (screen_center + offset)
    // as rotation changes. GPS is the pivot point - center orbits around it.
    //
    // Math: screen_pos = screen_center + rotate(point_px - center_px, R)
    // We want GPS at: screen_center + offset = screen_center + rotate(gps_px - center_px, R)
    // Therefore: offset = rotate(gps_px - center_px, R)
    // Inverting: gps_px - center_px = rotate(offset, -R)
    // So: center_px = gps_px - rotate(offset, -R)
    //
    // For offset = (0, 120) and rotation R:
    // Rotating (0, 120) by -R gives (120*sin(R), 120*cos(R))
    // Thus: center = gps - (120*sin(R), 120*cos(R))

    LatLng centerPosition = transform.center;

    if (transform.offset != Offset.zero) {
      // Project GPS position to pixel coordinates at target zoom
      final gpsPixel = camera.project(transform.center, transform.zoom);

      // Calculate where center should be by rotating around GPS position
      final rotationRad = transform.rotation * pi / 180.0;

      // Rotating offset (0, 120) by -R:
      // x' = 0*cos(R) + 120*sin(R) = 120*sin(R)
      // y' = -0*sin(R) + 120*cos(R) = 120*cos(R)
      final centerPixel = Point(
        gpsPixel.x - transform.offset.dy * sin(rotationRad),  // offset.dy = 140
        gpsPixel.y - transform.offset.dy * cos(rotationRad),
      );

      centerPosition = camera.unproject(centerPixel, transform.zoom);
    }

    // Use moveAndRotateRaw to update camera and emit events to all layers
    // This ensures VectorTileLayer receives camera change notifications and loads new tiles
    // We calculate the final center ourselves (above) accounting for target rotation,
    // then pass offset: Offset.zero since moveRaw's offset uses current rotation
    impl.moveAndRotateRaw(
      centerPosition,
      camera.clampZoom(transform.zoom),
      transform.rotation,
      offset: Offset.zero,
      hasGesture: false,
      source: MapEventSource.mapController,
    );
  }

  /// Stops any ongoing animations.
  void stopAnimations() {
    _animationController?.stop();
  }

  /// Disposes of resources.
  void dispose() {
    _animationController?.dispose();
    _animationController = null;
    _animation = null;
  }
}
