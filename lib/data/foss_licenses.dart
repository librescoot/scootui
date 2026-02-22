class FossLicense {
  final String name;
  final String version;
  final String license;
  final String copyright;
  final String? licenseUrl;

  const FossLicense({
    required this.name,
    required this.version,
    required this.license,
    required this.copyright,
    this.licenseUrl,
  });
}

final List<FossLicense> fossLicenses = [
  // Flutter SDK
  FossLicense(
    name: 'Flutter',
    version: 'SDK',
    license: 'BSD 3-Clause',
    copyright: 'The Flutter Authors',
    licenseUrl: 'https://github.com/flutter/flutter/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'Flutter SDK',
    version: 'SDK',
    license: 'BSD 3-Clause',
    copyright: 'The Flutter Authors',
    licenseUrl: 'https://github.com/flutter/flutter/blob/master/LICENSE',
  ),

  // State Management
  FossLicense(
    name: 'bloc',
    version: '9.0.0',
    license: 'MIT',
    copyright: 'Brian Egan',
    licenseUrl: 'https://github.com/felangel/bloc/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'flutter_bloc',
    version: '9.1.1',
    license: 'MIT',
    copyright: 'Brian Egan',
    licenseUrl: 'https://github.com/felangel/bloc/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'equatable',
    version: '2.0.7',
    license: 'MIT',
    copyright: 'Felix Angelov',
    licenseUrl: 'https://github.com/felangel/equatable/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'nested',
    version: '1.0.0',
    license: 'MIT',
    copyright: 'Ryan C. McClish',
    licenseUrl: 'https://github.com/rxlabz/nested/blob/master/LICENSE',
  ),

  // Data Serialization
  FossLicense(
    name: 'freezed_annotation',
    version: '3.0.0',
    license: 'MIT',
    copyright: 'Rémi Rousselet',
    licenseUrl: 'https://github.com/rrousselGit/freezed/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'json_annotation',
    version: '4.9.0',
    license: 'MIT',
    copyright: 'Hans-Peter Siebenhaar',
    licenseUrl: 'https://github.com/google/json_serializable.dart/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'json_serializable',
    version: '6.9.0',
    license: 'MIT',
    copyright: 'Dart Team',
    licenseUrl: 'https://github.com/google/json_serializable.dart/blob/master/LICENSE',
  ),

  // Map & Geospatial
  FossLicense(
    name: 'flutter_map',
    version: '7.0.0',
    license: 'MIT',
    copyright: 'Flutter Map Team',
    licenseUrl: 'https://github.com/fleaflet/flutter_map/blob/main/LICENSE',
  ),
  FossLicense(
    name: 'vector_map_tiles',
    version: '8.0.0',
    license: 'MIT',
    copyright: 'Flutter Map Team',
    licenseUrl: 'https://github.com/fleaflet/vector_map_tiles/blob/main/LICENSE',
  ),
  FossLicense(
    name: 'vector_map_tiles_mbtiles',
    version: '1.1.0',
    license: 'MIT',
    copyright: 'Flutter Map Team',
    licenseUrl: 'https://github.com/fleaflet/vector_map_tiles/blob/main/LICENSE',
  ),
  FossLicense(
    name: 'vector_tile_renderer',
    version: '5.2.1',
    license: 'MIT',
    copyright: 'Flutter Map Team',
    licenseUrl: 'https://github.com/fleaflet/vector_map_tiles/blob/main/LICENSE',
  ),
  FossLicense(
    name: 'mbtiles',
    version: '0.4.0',
    license: 'MIT',
    copyright: 'Flutter Map Team',
    licenseUrl: 'https://github.com/fleaflet/vector_map_tiles/blob/main/LICENSE',
  ),
  FossLicense(
    name: 'latlong2',
    version: '0.9.0',
    license: 'MIT',
    copyright: 'Simon Lightfoot',
    licenseUrl: 'https://github.com/justinthomson/latlong2/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'flutter_map_animations',
    version: '0.8.0+rotationfix',
    license: 'MIT',
    copyright: 'GitHub: ligustah',
    licenseUrl: 'https://github.com/ligustah/flutter_map_animations/blob/main/LICENSE',
  ),
  FossLicense(
    name: 'flutter_map_marker_cluster',
    version: '1.4.0',
    license: 'MIT',
    copyright: 'Flutter Map Team',
    licenseUrl: 'https://github.com/fleaflet/flutter_map_marker_cluster/blob/main/LICENSE',
  ),
  FossLicense(
    name: 'rbush',
    version: '1.1.1',
    license: 'MIT',
    copyright: 'Vladimir Agafonkin',
    licenseUrl: 'https://github.com/mourner/rbush/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'vector_tile',
    version: '2.0.0',
    license: 'MIT',
    copyright: 'Flutter Map Team',
    licenseUrl: 'https://github.com/fleaflet/vector_map_tiles/blob/main/LICENSE',
  ),
  FossLicense(
    name: 'geojson_vi',
    version: '2.2.5',
    license: 'MIT',
    copyright: 'GitHub: vi',
    licenseUrl: 'https://github.com/vi/geojson_vi/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'google_polyline_algorithm',
    version: '3.1.0',
    license: 'MIT',
    copyright: 'Dart Team',
    licenseUrl: 'https://github.com/rodydavis/google_polyline_algorithm/blob/master/LICENSE',
  ),

  // Networking & HTTP
  FossLicense(
    name: 'redis',
    version: '4.0.0',
    license: 'MIT',
    copyright: 'Dart Redis Client Authors',
    licenseUrl: 'https://github.com/redis/redis-dart/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'dio',
    version: '5.8.0+1',
    license: 'MIT',
    copyright: 'brian@fishtown.io',
    licenseUrl: 'https://github.com/flutterchina/dio/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'http',
    version: '1.3.0',
    license: 'MIT',
    copyright: 'Dart Team',
    licenseUrl: 'https://github.com/dart-lang/http/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'crypto',
    version: '3.0.6',
    license: 'Apache 2.0',
    copyright: 'Dart Team',
    licenseUrl: 'https://github.com/dart-lang/crypto/blob/master/LICENSE',
  ),

  // UI & Animation
  FossLicense(
    name: 'flutter_svg',
    version: '2.0.17',
    license: 'MIT',
    copyright: 'Jonah Williams',
    licenseUrl: 'https://github.com/dnfield/flutter_svg/blob/main/LICENSE',
  ),
  FossLicense(
    name: 'simple_animations',
    version: '5.1.0',
    license: 'MIT',
    copyright: 'Felix Angelov',
    licenseUrl: 'https://github.com/felangel/simple_animations/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'google_fonts',
    version: '6.2.1',
    license: 'Apache 2.0',
    copyright: 'Google Inc.',
    licenseUrl: 'https://github.com/flutter/packages/blob/main/packages/google_fonts/LICENSE',
  ),
  FossLicense(
    name: 'oktoast',
    version: '3.4.0',
    license: 'MIT',
    copyright: 'yangyang',
    licenseUrl: 'https://github.com/OpenFlutter/flutter_toast/blob/master/LICENSE',
  ),

  // Platform & System
  FossLicense(
    name: 'path_provider',
    version: '2.1.5',
    license: 'BSD 3-Clause',
    copyright: 'The Flutter Team',
    licenseUrl: 'https://github.com/flutter/packages/blob/main/packages/path_provider/path_provider/LICENSE',
  ),
  FossLicense(
    name: 'sqlite3_flutter_libs',
    version: '0.5.32',
    license: 'BSD 3-Clause',
    copyright: 'Tencent',
    licenseUrl: 'https://github.com/tencent/sqlite3_flutter_libs/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'window_manager',
    version: '0.4.3',
    license: 'MIT',
    copyright: 'Window Manager Authors',
    licenseUrl: 'https://github.com/leanflutter/window_manager/blob/main/LICENSE',
  ),

  // Internationalization
  FossLicense(
    name: 'intl',
    version: '0.19.0',
    license: 'BSD 3-Clause',
    copyright: 'Dart Team',
    licenseUrl: 'https://github.com/dart-lang/intl/blob/master/LICENSE',
  ),

  // Build Tools
  FossLicense(
    name: 'build_runner',
    version: '2.4.15',
    license: 'MIT',
    copyright: 'Dart Team',
    licenseUrl: 'https://github.com/dart-lang/build/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'source_gen',
    version: '2.0.0',
    license: 'MIT',
    copyright: 'Dart Team',
    licenseUrl: 'https://github.com/dart-lang/source_gen/blob/master/LICENSE',
  ),
  FossLicense(
    name: 'analyzer',
    version: '7.3.0',
    license: 'BSD 3-Clause',
    copyright: 'Dart Team',
    licenseUrl: 'https://github.com/dart-lang/sdk/blob/master/LICENSE',
  ),
];
