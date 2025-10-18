import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Route;
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile/vector_tile.dart' as vt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

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
    this.pitch = 1.0, // Default ~60 degree tilt
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

    final tileZ = widget.zoom.floor().clamp(0, 20);
    final centerTile = _latLngToTile(widget.position, tileZ);

    // Load 3x3 grid of tiles around center
    final tilesToLoad = <TileCoord>[];
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        tilesToLoad.add(TileCoord(
          centerTile.x + dx,
          centerTile.y + dy,
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
      if (features.isNotEmpty) {
        debugPrint('Loaded tile $tileCoord with ${features.length} features');
      }
    } catch (e) {
      // Silently cache empty feature list for missing tiles to avoid repeated requests
      _tileCache[tileCoord] = [];
      // Only log actual errors, not just missing tiles
      if (!e.toString().contains('Tile not found')) {
        debugPrint('Failed to load tile $tileCoord: $e');
      }
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

  static bool _hasLoggedLayers = false;

  Vector3DMapPainter({
    required this.camera,
    required this.features,
    required this.theme,
    this.route,
    this.destination,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final rendered = <RenderedFeature>[];
    final layerCounts = <String, int>{};
    int filteredCount = 0;

    // Render vector tile features
    for (final feature in features) {
      layerCounts[feature.layerName] = (layerCounts[feature.layerName] ?? 0) + 1;
      final renderedFeature = _renderFeature(feature);
      if (renderedFeature != null) {
        rendered.add(renderedFeature);
      } else {
        filteredCount++;
      }
    }

    if (features.isNotEmpty && !_hasLoggedLayers) {
      _hasLoggedLayers = true;
      debugPrint('Rendering ${features.length} features: ${rendered.length} visible, $filteredCount filtered');
      debugPrint('Available layers: ${layerCounts.keys.join(", ")}');
      debugPrint('Layer counts: $layerCounts');
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

    // Styling based on actual MBTiles layer names
    switch (layerName) {
      case 'water_polygons':
        paint.color = const Color(0xFF4A90E2).withOpacity(0.6);
        paint.style = PaintingStyle.fill;
        break;

      case 'water_lines':
        paint.color = const Color(0xFF4A90E2).withOpacity(0.8);
        paint.strokeWidth = 2.0;
        paint.style = PaintingStyle.stroke;
        break;

      case 'land':
        final kind = feature.properties['class']?.toString() ?? '';
        if (kind.contains('park') || kind.contains('grass')) {
          paint.color = const Color(0xFF8BC34A).withOpacity(0.4);
        } else if (kind.contains('wood') || kind.contains('forest')) {
          paint.color = const Color(0xFF4CAF50).withOpacity(0.5);
        } else {
          paint.color = const Color(0xFFE0E0E0).withOpacity(0.3);
        }
        paint.style = PaintingStyle.fill;
        break;

      case 'streets':
        final roadClass = feature.properties['class']?.toString() ?? '';
        if (roadClass.contains('motorway')) {
          paint.color = const Color(0xFFE06666);
          paint.strokeWidth = 6.0;
        } else if (roadClass.contains('primary')) {
          paint.color = const Color(0xFFFFA726);
          paint.strokeWidth = 5.0;
        } else if (roadClass.contains('secondary')) {
          paint.color = const Color(0xFFFFD54F);
          paint.strokeWidth = 4.0;
        } else {
          paint.color = const Color(0xFFBDBDBD);
          paint.strokeWidth = 3.0;
        }
        paint.style = PaintingStyle.stroke;
        paint.strokeCap = StrokeCap.round;
        paint.strokeJoin = StrokeJoin.round;
        break;

      case 'bridges':
        paint.color = const Color(0xFF757575);
        paint.strokeWidth = 4.0;
        paint.style = PaintingStyle.stroke;
        paint.strokeCap = StrokeCap.round;
        break;

      case 'buildings':
        paint.color = const Color(0xFF90A4AE).withOpacity(0.7);
        paint.style = PaintingStyle.fill;
        break;

      case 'street_polygons':
        paint.color = const Color(0xFFBDBDBD).withOpacity(0.5);
        paint.style = PaintingStyle.fill;
        break;

      case 'pier_polygons':
        paint.color = const Color(0xFF8D6E63).withOpacity(0.6);
        paint.style = PaintingStyle.fill;
        break;

      default:
        return null; // Don't render labels, pois, addresses, etc.
    }

    return paint;
  }

  double _getElevationForLayer(String layerName) {
    switch (layerName) {
      case 'buildings':
        return 10.0; // Buildings elevated
      case 'streets':
      case 'bridges':
        return 1.0; // Roads slightly elevated
      case 'street_polygons':
        return 0.5; // Road areas slightly above ground
      default:
        return 0.0; // Ground level
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
