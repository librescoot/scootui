import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

@immutable
class MapViewportState {
  /// The geographical coordinate at the center of the map view.
  final LatLng center;

  /// The zoom level of the map.
  final double zoom;

  /// The rotation of the map in degrees.
  final double rotation;

  const MapViewportState({
    required this.center,
    required this.zoom,
    required this.rotation,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapViewportState &&
        other.center == center &&
        other.zoom == zoom &&
        other.rotation == rotation;
  }

  @override
  int get hashCode => center.hashCode ^ zoom.hashCode ^ rotation.hashCode;
}
