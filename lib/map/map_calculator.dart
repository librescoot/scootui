import 'dart:math' as math;
import 'dart:ui';
import 'package:latlong2/latlong.dart';
import 'package:scooter_cluster/map/map_viewport_state.dart';

class MapCalculator {
  final MapViewportState viewport;
  final double scale;
  final int tileZoom;

  MapCalculator(this.viewport)
      : scale = math.pow(2.0, viewport.zoom).toDouble(),
        tileZoom = viewport.zoom.round();

  Offset geoToWorldPixel(LatLng latlng) {
    final n = scale;
    final x = n * ((latlng.longitude + 180.0) / 360.0) * 4096.0;
    final latRad = latlng.latitudeInRad;
    final y = n *
        (1.0 -
            (math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi)) /
        2.0 *
        4096.0;
    return Offset(x, y);
  }
}
