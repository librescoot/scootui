import 'dart:math' as math;
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:scooter_cluster/map/display_tile.dart';
import 'package:scooter_cluster/map/map_draw_command.dart';
import 'package:scooter_cluster/protos/vector_tile.pb.dart';

class TileProvider {
  final MbTiles mbtiles;
  final int maxZoom;

  TileProvider({required this.mbtiles})
      : maxZoom = (mbtiles.getMetadata().maxZoom ?? 16).toInt();

  Future<DisplayTile?> getTile(int z, int x, int y) async {
    final tmsY = ((1 << z) - 1) - y;

    // If the requested zoom is higher than what's available,
    // we need to find a parent tile and scale it.
    if (z > maxZoom) {
      final zoomDiff = z - maxZoom;
      final factor = math.pow(2, zoomDiff);
      final parentX = (x / factor).floor();
      final parentY = (y / factor).floor();
      final parentTmsY = ((1 << maxZoom) - 1) - parentY;

      final tileBytes = mbtiles.getTile(z: maxZoom, x: parentX, y: parentTmsY);
      if (tileBytes == null) {
        return null;
      }
      final commands = _decodeTile(tileBytes);
      return DisplayTile(
          z: maxZoom, x: parentX, y: parentY, commands: commands);
    }

    // Otherwise, get the tile for the current zoom level
    final tileBytes = mbtiles.getTile(z: z, x: x, y: tmsY);
    if (tileBytes == null) {
      return null;
    }
    final commands = _decodeTile(tileBytes);
    return DisplayTile(z: z, x: x, y: y, commands: commands);
  }

  // This is the decoding logic from our POC, now part of the tile provider.
  List<MapDrawCommand> _decodeTile(Uint8List tileBytes) {
    Tile tile;
    try {
      final decompressed = GZipDecoder().decodeBytes(tileBytes);
      tile = Tile.fromBuffer(decompressed);
    } catch (e) {
      try {
        tile = Tile.fromBuffer(tileBytes);
      } catch (e2) {
        return [];
      }
    }

    final commands = <MapDrawCommand>[];
    for (final layer in tile.layers) {
      for (final feature in layer.features) {
        final styleId = _getStyleIdForFeature(layer, feature);
        if (styleId != null) {
          final geometry = _decodeGeometry(feature, layer.extent);
          if (geometry.isNotEmpty) {
            commands.add(MapDrawCommand(
              points: geometry,
              isPolygon: feature.type == Tile_GeomType.POLYGON,
              styleId: styleId,
              strokeWidth: _getStrokeWidthForStyle(styleId),
            ));
          }
        }
      }
    }
    commands.sort((a, b) => a.styleId.compareTo(b.styleId));
    return commands;
  }

  int? _getStyleIdForFeature(Tile_Layer layer, Tile_Feature feature) {
    final properties = <String, dynamic>{};
    for (int i = 0; i < feature.tags.length; i += 2) {
      final keyIndex = feature.tags[i];
      final valueIndex = feature.tags[i + 1];
      if (keyIndex < layer.keys.length && valueIndex < layer.values.length) {
        properties[layer.keys[keyIndex]] = _toValue(layer.values[valueIndex]);
      }
    }

    final layerName = layer.name;
    switch (layerName) {
      case 'water_polygons':
      case 'water_lines':
        return 2; // waterStyleId
      case 'land':
        final landuse = properties['landuse'];
        final leisure = properties['leisure'];
        if (landuse == 'grass' ||
            landuse == 'forest' ||
            landuse == 'park' ||
            leisure == 'park' ||
            leisure == 'garden') {
          return 1; // greenSpaceStyleId
        }
        return null;
      case 'buildings':
        return 3; // houseStyleId
      case 'streets':
        final roadClass = properties['class'];
        final kind = properties['kind'];
        if (roadClass == 'motorway' ||
            roadClass == 'trunk' ||
            roadClass == 'primary' ||
            kind == 'motorway' ||
            kind == 'trunk' ||
            kind == 'primary') {
          return 4; // primaryRoadStyleId
        }
        return 5; // secondaryRoadStyleId
    }
    return null;
  }

  double? _getStrokeWidthForStyle(int styleId) {
    if (styleId == 4) return 8.0;
    if (styleId == 5) return 4.0;
    return null;
  }

  dynamic _toValue(Tile_Value value) {
    if (value.hasStringValue()) return value.stringValue;
    if (value.hasFloatValue()) return value.floatValue;
    if (value.hasDoubleValue()) return value.doubleValue;
    if (value.hasIntValue()) return value.intValue;
    if (value.hasUintValue()) return value.uintValue;
    if (value.hasSintValue()) return value.sintValue;
    if (value.hasBoolValue()) return value.boolValue;
    return null;
  }

  List<List<Offset>> _decodeGeometry(Tile_Feature feature, int extent) {
    final geometry = feature.geometry;
    final lines = <List<Offset>>[];
    if (geometry.isEmpty) return lines;

    int x = 0;
    int y = 0;
    int i = 0;
    List<Offset>? currentLine;

    while (i < geometry.length) {
      final command = geometry[i];
      final id = command & 0x7;
      final count = command >> 3;
      i++;

      if (id == 1) {
        // MoveTo
        for (int j = 0; j < count; j++) {
          x += _zigzagDecode(geometry[i++]);
          y += _zigzagDecode(geometry[i++]);
          currentLine = [Offset(x.toDouble(), y.toDouble())];
          lines.add(currentLine);
        }
      } else if (id == 2) {
        // LineTo
        if (currentLine != null) {
          for (int j = 0; j < count; j++) {
            x += _zigzagDecode(geometry[i++]);
            y += _zigzagDecode(geometry[i++]);
            currentLine.add(Offset(x.toDouble(), y.toDouble()));
          }
        }
      } else if (id == 7) {
        // ClosePath
        // Implicitly handled by polygon drawing
      }
    }
    return lines;
  }

  int _zigzagDecode(int n) {
    return (n >> 1) ^ (-(n & 1));
  }
}
