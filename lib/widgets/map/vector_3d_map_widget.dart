import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Route;
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile/vector_tile.dart' as vt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../../cubits/map_cubit.dart';
import '../../routing/models.dart';
import 'vector_3d_renderer.dart';

final distanceCalculator = Distance();

class Vector3DMapWidget extends StatefulWidget {
  final LatLng position;
  final double zoom;
  final double bearing;
  final double pitch;
  final VectorTileProvider tileProvider;
  final vtr.Theme theme;
  final Route? route;
  final LatLng? destination;

  const Vector3DMapWidget({
    super.key,
    required this.position,
    required this.zoom,
    required this.bearing,
    this.pitch = 1.2, // Default ~69 degree tilt (Google Maps style)
    required this.tileProvider,
    required this.theme,
    this.route,
    this.destination,
  });

  @override
  State<Vector3DMapWidget> createState() => _Vector3DMapWidgetState();
}

class _Vector3DMapWidgetState extends State<Vector3DMapWidget> {
  final Map<TileCoord, List<VectorFeature>> _tileCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisibleTiles();
  }

  @override
  void didUpdateWidget(Vector3DMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reload if zoom changed significantly or position moved far enough to need new tiles
    final zoomChanged = (oldWidget.zoom.floor() != widget.zoom.floor());
    final distanceMoved = distanceCalculator.distance(oldWidget.position, widget.position);
    final needsReload = zoomChanged || distanceMoved > 1000; // Reload if moved > 1km

    if (needsReload) {
      _loadVisibleTiles();
    }
  }

  Future<void> _loadVisibleTiles() async {
    setState(() => _isLoading = true);

    // Load tiles at min of requested zoom and max available (14)
    final tileZ = math.min(14, widget.zoom.floor());
    final centerTile = _latLngToTile(widget.position, tileZ);

    // Load tiles in the direction we're facing (bearing-aware)
    // With 69° pitch, we see far into the distance
    final tilesToLoad = <TileCoord>[];

    // Calculate forward direction based on bearing
    // bearing: 0 = north, π/2 = east, π = south, 3π/2 = west
    final cosB = math.cos(-widget.bearing);
    final sinB = math.sin(-widget.bearing);

    // Create a grid that extends forward in the look direction
    // Grid: 3 tiles wide (-1 to +1), 5 tiles deep (-1 to +3 forward)
    // Compact grid for overzoomed view
    for (var localX = -1; localX <= 1; localX++) {
      for (var localY = -1; localY <= 3; localY++) {
        // Rotate the local grid to world space based on bearing
        final worldDx = (localX * cosB - localY * sinB).round();
        final worldDy = (localX * sinB + localY * cosB).round();

        tilesToLoad.add(TileCoord(
          centerTile.x + worldDx,
          centerTile.y + worldDy,
          tileZ,
        ));
      }
    }

    // Load tiles that aren't cached
    for (final tileCoord in tilesToLoad) {
      if (!_tileCache.containsKey(tileCoord)) {
        await _loadTile(tileCoord);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTile(TileCoord tileCoord) async {
    try {
      final tileId = TileIdentity(
        tileCoord.z,
        tileCoord.x,
        tileCoord.y,
      );
      final tileData = await widget.tileProvider.provide(tileId);

      final tile = vt.VectorTile.fromBytes(bytes: tileData);
      final features = <VectorFeature>[];

      // Parse all layers and features
      for (final layer in tile.layers) {
        final extent = layer.extent;

        for (final feature in layer.features) {
          final decodedGeom = feature.decodeGeometry();
          if (decodedGeom == null) continue;

          final geometry = parseGeometry(feature, tileCoord, extent);
          if (geometry.isNotEmpty) {
            final geomType = _getGeometryType(decodedGeom);

            features.add(VectorFeature(
              feature: feature,
              layerName: layer.name,
              geometry: geometry,
              geometryType: geomType,
            ));
          }
        }
      }

      _tileCache[tileCoord] = features;
    } catch (e) {
      // Silently cache empty feature list for missing tiles to avoid repeated requests
      _tileCache[tileCoord] = [];
    }
  }

  TileCoord _latLngToTile(LatLng latLng, int zoom) {
    final n = math.pow(2, zoom);
    final x = ((latLng.longitude + 180.0) / 360.0 * n).floor();
    final latRad = latLng.latitude * math.pi / 180.0;
    final y = ((1.0 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) / 2.0 * n).floor();
    return TileCoord(x, y, zoom);
  }

  vt.GeometryType _getGeometryType(vt.Geometry geometry) {
    if (geometry is vt.GeometryPoint) return vt.GeometryType.Point;
    if (geometry is vt.GeometryLineString) return vt.GeometryType.LineString;
    if (geometry is vt.GeometryPolygon) return vt.GeometryType.Polygon;
    if (geometry is vt.GeometryMultiPoint) return vt.GeometryType.MultiPoint;
    if (geometry is vt.GeometryMultiLineString) return vt.GeometryType.MultiLineString;
    if (geometry is vt.GeometryMultiPolygon) return vt.GeometryType.MultiPolygon;
    // Default to Point if unknown type
    return vt.GeometryType.Point;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final camera = Camera3D(
          center: widget.position,
          zoom: widget.zoom,
          bearing: widget.bearing,
          pitch: widget.pitch,
          viewportSize: Size(constraints.maxWidth, constraints.maxHeight),
          vehicleOffset: MapCubit.mapCenterOffset, // Use same offset as vehicle marker
        );

        return CustomPaint(
          painter: Vector3DMapPainter(
            camera: camera,
            features: _getAllFeatures(),
            theme: widget.theme,
            route: widget.route,
            destination: widget.destination,
          ),
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
      },
    );
  }

  List<VectorFeature> _getAllFeatures() {
    final allFeatures = <VectorFeature>[];
    for (final features in _tileCache.values) {
      allFeatures.addAll(features);
    }
    return allFeatures;
  }
}

class Vector3DMapPainter extends CustomPainter {
  final Camera3D camera;
  final List<VectorFeature> features;
  final vtr.Theme theme;
  final Route? route;
  final LatLng? destination;

  Vector3DMapPainter({
    required this.camera,
    required this.features,
    required this.theme,
    this.route,
    this.destination,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background color (from mapdark theme: hsl(33,48%,5%))
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0D0804),
    );

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final rendered = <RenderedFeature>[];

    // Render vector tile features
    for (final feature in features) {
      final renderedFeature = _renderFeature(feature);
      if (renderedFeature != null) {
        rendered.add(renderedFeature);
      }
    }

    // Sort by depth (painter's algorithm - far to near)
    rendered.sort((a, b) => b.depth.compareTo(a.depth));

    // Draw all features in depth order
    for (final feature in rendered) {
      canvas.drawPath(feature.path, feature.paint);
    }

    // Draw route on top if available
    if (route != null && route!.waypoints.isNotEmpty) {
      _drawRoute(canvas);
    }

    // Draw destination marker if available
    if (destination != null) {
      _drawDestination(canvas);
    }
  }

  RenderedFeature? _renderFeature(VectorFeature feature) {
    // Get styling based on layer and zoom
    final paint = _getStyleForFeature(feature);
    if (paint == null) return null;

    final path = ui.Path();
    double totalDepth = 0.0;
    int depthSamples = 0;

    // Get elevation based on layer type
    final elevation = _getElevationForLayer(feature.layerName);

    for (final ring in feature.geometry) {
      if (ring.isEmpty) continue;

      final projectedPoints = ring.map((latLng) {
        final point3d = camera.project(latLng, elevation: elevation);
        totalDepth += camera.getDepth(point3d);
        depthSamples++;
        return camera.projectToScreen(point3d);
      }).toList();

      if (projectedPoints.isNotEmpty) {
        path.moveTo(projectedPoints.first.dx, projectedPoints.first.dy);
        for (var i = 1; i < projectedPoints.length; i++) {
          path.lineTo(projectedPoints[i].dx, projectedPoints[i].dy);
        }

        if (feature.geometryType == vt.GeometryType.Polygon ||
            feature.geometryType == vt.GeometryType.MultiPolygon) {
          path.close();
        }
      }
    }

    final avgDepth = depthSamples > 0 ? totalDepth / depthSamples : 0.0;

    return RenderedFeature(
      path: path,
      paint: paint,
      depth: avgDepth,
      layerName: feature.layerName,
      properties: feature.properties,
    );
  }

  Paint? _getStyleForFeature(VectorFeature feature) {
    final layerName = feature.layerName;
    final paint = Paint();

    // Match mapdark/maplight theme - only render what the theme renders
    switch (layerName) {
      case 'water_polygons':
        // Theme: "water" layer
        paint.color = const Color(0xFF2D4A5F); // hsl(205,35%,22%) dark theme color
        paint.style = PaintingStyle.fill;
        break;

      case 'land':
        // Theme: various land layers with kind filtering
        final kind = feature.properties['kind']?.toString() ?? '';

        // Forest (minzoom 7)
        if (kind == 'forest') {
          paint.color = const Color(0xFF2E3D2E); // hsl(110,30%,18%)
        }
        // Parks (minzoom 11)
        else if (['park', 'village_green', 'recreation_ground', 'playground', 'golf_course'].contains(kind)) {
          paint.color = const Color(0xFF2D3D2B); // hsl(100,25%,17%)
        }
        // Grass (minzoom 11)
        else if (['grass', 'grassland', 'meadow'].contains(kind)) {
          paint.color = const Color(0xFF2E3D2B); // hsl(95,25%,17%)
        }
        // Residential/commercial/industrial (minzoom 11)
        else if (['residential', 'garages'].contains(kind)) {
          paint.color = const Color(0xFF1F1F1F).withOpacity(0.3); // hsl(0,0%,12%) 30%
        } else if (['commercial', 'retail'].contains(kind)) {
          paint.color = const Color(0xFF2B2426).withOpacity(0.3); // hsl(330,15%,15%) 30%
        } else if (['industrial', 'quarry', 'railway'].contains(kind)) {
          paint.color = const Color(0xFF2D2B26).withOpacity(0.3); // hsl(48,20%,15%) 30%
        }
        // Skip or use base land color
        else {
          paint.color = const Color(0xFF1A1712).withOpacity(0.2); // hsla(33,18%,10%,0.2)
        }
        paint.style = PaintingStyle.fill;
        break;

      case 'streets':
        // Theme: roads with kind-based styling
        final kind = feature.properties['kind']?.toString() ?? '';

        // Major roads: motorway, trunk
        if (['motorway', 'trunk'].contains(kind)) {
          paint.color = const Color(0xFF594D2E); // hsl(48,60%,35%)
          paint.strokeWidth = 4.0;
        }
        // Main roads: primary, secondary
        else if (['primary', 'secondary'].contains(kind)) {
          paint.color = const Color(0xFF4D4026); // hsl(48,50%,30%)
          paint.strokeWidth = 3.0;
        }
        // Local roads: tertiary, unclassified, residential, living_street
        else if (['tertiary', 'unclassified', 'residential', 'living_street'].contains(kind)) {
          paint.color = const Color(0xFF403620); // hsl(48,40%,25%)
          paint.strokeWidth = 2.0;
        }
        // Railways (minzoom 13)
        else if (kind == 'rail') {
          paint.color = const Color(0xFF404040); // hsl(0,0%,25%)
          paint.strokeWidth = 1.0;
          // Note: theme uses dasharray [3, 3] which we can't easily do
        }
        // Skip other road types
        else {
          return null;
        }

        paint.style = PaintingStyle.stroke;
        paint.strokeCap = StrokeCap.round;
        paint.strokeJoin = StrokeJoin.round;
        break;

      default:
        // Skip all other layers: buildings, addresses, labels, pois, bridges, etc.
        return null;
    }

    return paint;
  }

  double _getElevationForLayer(String layerName) {
    switch (layerName) {
      case 'streets':
        return 0.5; // Roads slightly elevated above land
      default:
        return 0.0; // Ground level for water and land
    }
  }

  void _drawRoute(Canvas canvas) {
    if (route!.waypoints.length < 2) return;

    final elevation = 3.0; // Route elevated above roads

    // Draw border
    final borderPath = ui.Path();
    final firstPoint = camera.projectToScreen(
      camera.project(route!.waypoints.first, elevation: elevation),
    );
    borderPath.moveTo(firstPoint.dx, firstPoint.dy);

    for (var i = 1; i < route!.waypoints.length; i++) {
      final point = camera.projectToScreen(
        camera.project(route!.waypoints[i], elevation: elevation),
      );
      borderPath.lineTo(point.dx, point.dy);
    }

    final borderPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(borderPath, borderPaint);

    // Draw main route
    final routePath = ui.Path();
    routePath.moveTo(firstPoint.dx, firstPoint.dy);

    for (var i = 1; i < route!.waypoints.length; i++) {
      final point = camera.projectToScreen(
        camera.project(route!.waypoints[i], elevation: elevation),
      );
      routePath.lineTo(point.dx, point.dy);
    }

    final routePaint = Paint()
      ..color = Colors.blue.shade400
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(routePath, routePaint);
  }

  void _drawDestination(Canvas canvas) {
    final elevation = 15.0;
    final point3d = camera.project(destination!, elevation: elevation);
    final screenPoint = camera.projectToScreen(point3d);

    // Draw pin
    final markerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final pinPath = ui.Path();
    pinPath.moveTo(screenPoint.dx, screenPoint.dy);
    pinPath.lineTo(screenPoint.dx - 8, screenPoint.dy - 24);
    pinPath.lineTo(screenPoint.dx + 8, screenPoint.dy - 24);
    pinPath.close();

    canvas.drawPath(pinPath, markerPaint);

    // Draw pin circle
    canvas.drawCircle(
      screenPoint.translate(0, -24),
      6,
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant Vector3DMapPainter oldDelegate) {
    return camera != oldDelegate.camera ||
        features != oldDelegate.features ||
        route != oldDelegate.route ||
        destination != oldDelegate.destination;
  }
}
