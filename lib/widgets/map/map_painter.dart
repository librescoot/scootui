import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scooter_cluster/map/map_draw_command.dart';
import 'package:scooter_cluster/map/map_viewport_state.dart';
import 'dart:math' as math;
import 'package:scooter_cluster/map/coordinate_utils.dart';
import 'package:scooter_cluster/map/display_tile.dart';
import 'package:scooter_cluster/map/map_calculator.dart';
import 'package:latlong2/latlong.dart' hide Path;

class MapPainter extends CustomPainter {
  final Map<math.Point<int>, DisplayTile> tiles;
  final MapCalculator calculator;
  final List<LatLng> route;
  final bool isDarkTheme;

  // Theme colors
  static const Map<int, Color> _lightThemeColors = {
    1: Color(0xFFE0F0E0), // greenSpace
    2: Color(0xFFA0C0F0), // water
    3: Color(0xFFD0B0A0), // house
    4: Color(0xFFFFFFFF), // primaryRoad
    5: Color(0xFFF0F0F0), // secondaryRoad
  };

  static const Map<int, Color> _darkThemeColors = {
    1: Color(0xFF2C382C), // greenSpace
    2: Color(0xFF1A2D4A), // water
    3: Color(0xFF4A3C32), // house
    4: Color(0xFF3D3D3D), // primaryRoad
    5: Color(0xFF2E2E2E), // secondaryRoad
  };

  MapPainter({
    required this.tiles,
    required this.calculator,
    required this.route,
    required this.isDarkTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = isDarkTheme ? _darkThemeColors : _lightThemeColors;
    final viewport = calculator.viewport;
    final zoom = viewport.zoom;
    final center = size / 2;
    final centerGeo = viewport.center;

    final scale = calculator.scale / 4096.0;

    // Get the world pixel coordinate of the map's center.
    final centerWorldPixel = calculator.geoToWorldPixel(centerGeo);

    canvas.save();

    // Move canvas origin to the center of the screen for rotation and scaling.
    canvas.translate(center.width, center.height);
    canvas.rotate(viewport.rotation * math.pi / 180.0);
    canvas.scale(scale);

    // Translate the canvas so the map's center aligns with the screen's center.
    canvas.translate(-centerWorldPixel.dx, -centerWorldPixel.dy);

    for (final entry in tiles.entries) {
      final paint = Paint();
      final displayTile = entry.value;
      if (displayTile.commands.isEmpty) continue;

      final dx = displayTile.x * 4096.0;
      final dy = displayTile.y * 4096.0;

      canvas.save();
      canvas.translate(dx, dy);

      for (final command in displayTile.commands) {
        final color = colors[command.styleId];
        if (color == null) continue;

        paint.color = color;
        if (command.strokeWidth != null) {
          paint.strokeWidth = command.strokeWidth!.toDouble() / scale;
          paint.style = PaintingStyle.stroke;
        } else {
          paint.style = PaintingStyle.fill;
        }

        final path = Path();
        for (final line in command.points) {
          if (line.isNotEmpty) {
            path.moveTo(line.first.dx, line.first.dy);
            for (int i = 1; i < line.length; i++) {
              path.lineTo(line[i].dx, line[i].dy);
            }
            if (command.isPolygon) {
              path.close();
            }
          }
        }
        canvas.drawPath(path, paint);
      }
      canvas.restore();
    }

    _drawRoute(canvas, size, scale);
    canvas.restore();
  }

  void _drawRoute(Canvas canvas, Size size, double scale) {
    if (route.isEmpty) return;

    final pixels = route.map((p) => calculator.geoToWorldPixel(p)).toList();

    if (pixels.length < 2) return;

    // Draw each segment with a fresh Paint object
    for (int i = 0; i < pixels.length - 1; i++) {
      final paint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 10.0 / scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()
        ..moveTo(pixels[i].dx, pixels[i].dy)
        ..lineTo(pixels[i + 1].dx, pixels[i + 1].dy);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) {
    if (oldDelegate.isDarkTheme != isDarkTheme) {
      return true;
    }
    if (!listEquals(oldDelegate.route, route)) {
      return true;
    }
    if (oldDelegate.calculator.viewport != calculator.viewport) {
      return true;
    }

    if (oldDelegate.tiles.length != tiles.length) {
      return true;
    }
    for (final key in tiles.keys) {
      if (!oldDelegate.tiles.containsKey(key) ||
          oldDelegate.tiles[key] != tiles[key]) {
        return true;
      }
    }

    return false;
  }
}
