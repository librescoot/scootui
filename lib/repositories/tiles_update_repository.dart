import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Region {
  final String name;
  final String identifier;

  const Region(this.name, this.identifier);

  String get valhallaUrl =>
      'https://github.com/librescoot/valhalla-tiles/releases/download/latest/valhalla_tiles_$identifier.tar';

  String get osmTilesUrl =>
      'https://github.com/librescoot/osm-tiles/releases/download/latest/tiles_$identifier.mbtiles';
}

const regions = [
  Region('Baden-Württemberg', 'baden-wuerttemberg'),
  Region('Bayern', 'bayern'),
  Region('Berlin', 'berlin'),
  Region('Brandenburg', 'brandenburg'),
  Region('Bremen', 'bremen'),
  Region('Hamburg', 'hamburg'),
  Region('Hessen', 'hessen'),
  Region('Mecklenburg-Vorpommern', 'mecklenburg-vorpommern'),
  Region('Niedersachsen', 'niedersachsen'),
  Region('Nordrhein-Westfalen', 'nordrhein-westfalen'),
  Region('Rheinland-Pfalz', 'rheinland-pfalz'),
  Region('Saarland', 'saarland'),
  Region('Sachsen', 'sachsen'),
  Region('Sachsen-Anhalt', 'sachsen-anhalt'),
  Region('Schleswig-Holstein', 'schleswig-holstein'),
  Region('Thüringen', 'thueringen'),
];

Region regionByName(String name) =>
    regions.firstWhere((region) => region.name == name);

/// Simplified repository for map tile downloads
/// No version tracking, no auto-updates, just URL helpers
class TilesUpdateRepository {
  Directory? _appDir;

  Future<Directory> getAppDir() async {
    _appDir ??= await getApplicationDocumentsDirectory();
    return _appDir!;
  }

  String getOsmUrl(Region region) => region.osmTilesUrl;

  String getValhallaUrl(Region region) => region.valhallaUrl;

  /// Optionally get download sizes for UI display
  Future<(String?, String?)> getDownloadSizes(Region region) async {
    // TODO: Implement size fetching from GitHub API if needed
    // For now, return null values
    return (null, null);
  }
}
