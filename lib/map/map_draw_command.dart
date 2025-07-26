import 'package:flutter/material.dart';

/// A class representing a single drawing command for our custom renderer.
class MapDrawCommand {
  const MapDrawCommand({
    required this.points,
    required this.isPolygon,
    required this.styleId,
    this.strokeWidth,
  });

  final List<List<Offset>> points;
  final bool isPolygon;
  final int styleId;
  final double? strokeWidth;
}
