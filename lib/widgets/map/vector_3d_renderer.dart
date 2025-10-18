import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_tile/vector_tile.dart' as vt;

/// 3D Camera for perspective projection
class Camera3D {
  final LatLng center;
  final double zoom;
  final double bearing; // Rotation in radians
  final double pitch; // Tilt in radians (0 = top-down, PI/2 = horizon)
  final Size viewportSize;
  final Offset vehicleOffset; // Offset of vehicle marker from screen center

  const Camera3D({
    required this.center,
    required this.zoom,
    required this.bearing,
    required this.pitch,
    required this.viewportSize,
    this.vehicleOffset = const Offset(0, 140), // Default: vehicle at bottom-center
  });

  /// Get the scale factor (pixels per world unit at zoom level)
  double get scale => 256.0 * math.pow(2, zoom).toDouble();

  /// Project lat/lng to 3D world coordinates
  Point3D project(LatLng latLng, {double elevation = 0.0}) {
    // Web Mercator projection
    final x = _longitudeToMercatorX(latLng.longitude);
    final y = _latitudeToMercatorY(latLng.latitude);

    // Convert to world coordinates relative to camera center
    final centerX = _longitudeToMercatorX(center.longitude);
    final centerY = _latitudeToMercatorY(center.latitude);

    final worldX = (x - centerX) * scale;
    final worldY = (y - centerY) * scale;

    return Point3D(worldX, worldY, elevation);
  }

  /// Apply 3D transformation and perspective projection to screen coordinates
  Offset projectToScreen(Point3D point) {
    // Apply bearing rotation around Z axis
    final cosB = math.cos(-bearing);
    final sinB = math.sin(-bearing);
    final x1 = point.x * cosB - point.y * sinB;
    final y1 = point.x * sinB + point.y * cosB;
    final z1 = point.z;

    // Apply pitch rotation around X axis (negate to look down at ground, not up at ceiling)
    final cosP = math.cos(-pitch);
    final sinP = math.sin(-pitch);
    final y2 = y1 * cosP - z1 * sinP;
    final z2 = y1 * sinP + z1 * cosP;

    // Perspective projection
    final perspectiveDistance = 1200.0; // Distance to "camera"
    final depth = perspectiveDistance + z2;
    final scale = depth > 0.1 ? perspectiveDistance / depth : 1.0;

    // Project with vehicle position as origin (vehicle is offset down from center)
    final screenX = x1 * scale + viewportSize.width / 2 + vehicleOffset.dx;
    final screenY = y2 * scale + viewportSize.height / 2 + vehicleOffset.dy;

    return Offset(screenX, screenY);
  }

  /// Get depth value for z-sorting (larger = farther away)
  double getDepth(Point3D point) {
    final cosB = math.cos(-bearing);
    final sinB = math.sin(-bearing);
    final y1 = point.x * sinB + point.y * cosB;

    final cosP = math.cos(-pitch);
    final sinP = math.sin(-pitch);
    final z2 = y1 * sinP + point.z * cosP;

    return z2;
  }

  double _longitudeToMercatorX(double longitude) {
    return (longitude + 180.0) / 360.0;
  }

  double _latitudeToMercatorY(double latitude) {
    final latRad = latitude * math.pi / 180.0;
    return (1.0 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) / 2.0;
  }
}

/// Simple 3D point
class Point3D {
  final double x;
  final double y;
  final double z;

  const Point3D(this.x, this.y, this.z);
}

/// Rendered feature with depth for sorting
class RenderedFeature {
  final ui.Path path;
  final Paint paint;
  final Paint? outlinePaint; // Optional outline drawn first
  final double depth;
  final String layerName;
  final Map<String, dynamic> properties;
  final int roadHierarchy; // 0 = not a road, higher = more important road

  RenderedFeature({
    required this.path,
    required this.paint,
    this.outlinePaint,
    required this.depth,
    required this.layerName,
    required this.properties,
    this.roadHierarchy = 0,
  });
}

/// Vector tile feature with full property access
class VectorFeature {
  final vt.VectorTileFeature feature;
  final String layerName;
  final List<List<LatLng>> geometry;
  final vt.GeometryType geometryType;

  VectorFeature({
    required this.feature,
    required this.layerName,
    required this.geometry,
    required this.geometryType,
  });

  /// Get property value (including maxspeed, name, etc.)
  dynamic getProperty(String key) {
    final props = feature.properties;
    if (props == null) return null;

    final value = props[key];
    if (value == null) return null;
    // VectorTileValue has different types, extract the actual value
    if (value.stringValue != null) return value.stringValue;
    if (value.doubleValue != null) return value.doubleValue;
    if (value.intValue != null) return value.intValue;
    if (value.boolValue != null) return value.boolValue;
    return null;
  }

  /// Get all properties as simple map
  Map<String, dynamic> get properties {
    final result = <String, dynamic>{};
    final props = feature.properties;
    if (props != null) {
      props.forEach((key, value) {
        result[key] = getProperty(key);
      });
    }
    return result;
  }

  /// Get maxspeed if available
  String? get maxSpeed => getProperty('maxspeed')?.toString();

  /// Get name if available
  String? get name => getProperty('name')?.toString();
}

/// Tile coordinates
class TileCoord {
  final int x;
  final int y;
  final int z;

  const TileCoord(this.x, this.y, this.z);

  @override
  bool operator ==(Object other) =>
      other is TileCoord && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'TileCoord($z/$x/$y)';

  /// Get tile bounds in lat/lng
  TileBounds getBounds() {
    final n = math.pow(2, z).toDouble();
    final lonMin = x / n * 360.0 - 180.0;
    final lonMax = (x + 1) / n * 360.0 - 180.0;

    final latMin = _tile2lat(y + 1, z);
    final latMax = _tile2lat(y, z);

    return TileBounds(
      west: lonMin,
      east: lonMax,
      south: latMin,
      north: latMax,
    );
  }

  double _tile2lat(int y, int z) {
    final n = math.pow(2, z).toDouble();
    final latRad = math.atan(_sinh(math.pi * (1 - 2 * y / n)));
    return latRad * 180.0 / math.pi;
  }

  // Hyperbolic sine function
  static double _sinh(double x) {
    return (math.exp(x) - math.exp(-x)) / 2.0;
  }
}

class TileBounds {
  final double west;
  final double east;
  final double south;
  final double north;

  const TileBounds({
    required this.west,
    required this.east,
    required this.south,
    required this.north,
  });
}

/// Parse vector tile geometry to lat/lng coordinates
List<List<LatLng>> parseGeometry(
  vt.VectorTileFeature feature,
  TileCoord tileCoord,
  int extent,
) {
  final result = <List<LatLng>>[];
  final bounds = tileCoord.getBounds();
  final tileSizeLng = bounds.east - bounds.west;
  final tileSizeLat = bounds.north - bounds.south;

  // Decode the geometry
  final geometry = feature.decodeGeometry();

  if (geometry is vt.GeometryPoint) {
    // Point geometry
    final coords = geometry.coordinates;
    final lng = bounds.west + (coords[0] / extent) * tileSizeLng;
    final lat = bounds.north - (coords[1] / extent) * tileSizeLat;
    result.add([LatLng(lat, lng)]);
  } else if (geometry is vt.GeometryLineString) {
    // LineString geometry
    final ring = <LatLng>[];
    for (final coord in geometry.coordinates) {
      final lng = bounds.west + (coord[0] / extent) * tileSizeLng;
      final lat = bounds.north - (coord[1] / extent) * tileSizeLat;
      ring.add(LatLng(lat, lng));
    }
    if (ring.isNotEmpty) {
      result.add(ring);
    }
  } else if (geometry is vt.GeometryMultiLineString) {
    // MultiLineString geometry
    for (final line in geometry.coordinates) {
      final ring = <LatLng>[];
      for (final coord in line) {
        final lng = bounds.west + (coord[0] / extent) * tileSizeLng;
        final lat = bounds.north - (coord[1] / extent) * tileSizeLat;
        ring.add(LatLng(lat, lng));
      }
      if (ring.isNotEmpty) {
        result.add(ring);
      }
    }
  } else if (geometry is vt.GeometryPolygon) {
    // Polygon geometry
    for (final ring in geometry.coordinates) {
      final coords = <LatLng>[];
      for (final coord in ring) {
        final lng = bounds.west + (coord[0] / extent) * tileSizeLng;
        final lat = bounds.north - (coord[1] / extent) * tileSizeLat;
        coords.add(LatLng(lat, lng));
      }
      if (coords.isNotEmpty) {
        result.add(coords);
      }
    }
  } else if (geometry is vt.GeometryMultiPolygon) {
    // MultiPolygon geometry
    final polygons = geometry.coordinates;
    if (polygons != null) {
      for (final polygon in polygons) {
        for (final ring in polygon) {
          final coords = <LatLng>[];
          for (final coord in ring) {
            final lng = bounds.west + (coord[0] / extent) * tileSizeLng;
            final lat = bounds.north - (coord[1] / extent) * tileSizeLat;
            coords.add(LatLng(lat, lng));
          }
          if (coords.isNotEmpty) {
            result.add(coords);
          }
        }
      }
    }
  }

  return result;
}
