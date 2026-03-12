import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class MapTileInfo {
  final String digest;
  final String publishedAt;
  final int size;

  const MapTileInfo({
    required this.digest,
    required this.publishedAt,
    required this.size,
  });

  factory MapTileInfo.fromJson(Map<String, dynamic> json) => MapTileInfo(
        digest: json['digest'] as String,
        publishedAt: json['publishedAt'] as String,
        size: json['size'] as int,
      );

  Map<String, dynamic> toJson() => {
        'digest': digest,
        'publishedAt': publishedAt,
        'size': size,
      };
}

class MapMetadata {
  final String region;
  final MapTileInfo? displayTiles;
  final MapTileInfo? valhallaTiles;

  const MapMetadata({
    required this.region,
    this.displayTiles,
    this.valhallaTiles,
  });

  factory MapMetadata.fromJson(Map<String, dynamic> json) => MapMetadata(
        region: json['region'] as String,
        displayTiles: json['displayTiles'] != null
            ? MapTileInfo.fromJson(json['displayTiles'] as Map<String, dynamic>)
            : null,
        valhallaTiles: json['valhallaTiles'] != null
            ? MapTileInfo.fromJson(
                json['valhallaTiles'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'region': region,
        if (displayTiles != null) 'displayTiles': displayTiles!.toJson(),
        if (valhallaTiles != null) 'valhallaTiles': valhallaTiles!.toJson(),
      };

  static Future<String> _metadataPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/maps/metadata.json';
  }

  static Future<MapMetadata?> load() async {
    try {
      final path = await _metadataPath();
      final file = File(path);
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return MapMetadata.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> save() async {
    final path = await _metadataPath();
    final file = File(path);
    await file.parent.create(recursive: true);
    final tmpFile = File('$path.tmp');
    await tmpFile.writeAsString(jsonEncode(toJson()));
    await tmpFile.rename(path);
  }
}
