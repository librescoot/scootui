import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

class CoordinateUtils {
  /// Converts geographical coordinates to tile coordinates for a given zoom level.
  static math.Point<int> geoToTile(LatLng latlng, int zoom) {
    final latRad = latlng.latitudeInRad;
    final n = math.pow(2, zoom);
    final x = (n * ((latlng.longitude + 180) / 360)).floor();
    final y = (n *
            (1 -
                (math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi)) /
            2)
        .floor();
    return math.Point<int>(x, y);
  }

  /// Converts tile coordinates to the top-left geographical coordinate of that tile.
  static LatLng tileToGeo(math.Point<int> tile, int zoom) {
    final n = math.pow(2, zoom);
    final lon = tile.x / n * 360.0 - 180.0;

    // Calculate sinh using exp
    final sinh_val = (math.exp(math.pi * (1 - 2 * tile.y / n)) -
            math.exp(-math.pi * (1 - 2 * tile.y / n))) /
        2;

    final latRad = math.atan(sinh_val);
    final lat = latRad * 180 / math.pi;
    return LatLng(lat, lon);
  }
}
